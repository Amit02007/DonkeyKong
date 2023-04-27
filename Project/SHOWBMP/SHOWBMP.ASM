IDEAL
MODEL small
 
 

STACK 0f500h
 
BMP_WIDTH = 320
BMP_HEIGHT = 200

SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40



 

DATASEG

    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileName 	db "XXXXXXXX.bmp", 0
 
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)

	Screens db 	0, "open.bmp"	
			db	1, "game.bmp"
			db	2, "help.bmp"
	
	ScreensLenght db $ - Screens
									
	CurrentScreen db ?
	SelectedScreen db ?
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File', 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	; array for mouse int 33 ax=09 (not a must) 64 bytes
	
	 
	 
	Color db ?
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	 
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
	 
CODESEG
 


 
start:
	mov ax, @data
	mov ds, ax
	
	call SetGraphic
	mov [SelectedScreen], 0
	call SwitchScreen
	
	openA:
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	
	call OpenShowBmp
	cmp [ErrorFile],1
	je exitError 
	jmp exit
	
exitError:
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
	
		
exit:
	mov dx, offset BB
	mov ah,9
	;int 21h
	
	mov ah,0
	int 16h
	sub al, "0"
	mov [SelectedScreen], al
	call SwitchScreen
	jmp openA
	
	mov ax,2
	int 10h

	
	mov ax, 4c00h
	int 21h
	

	
;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================

; A procedure that changes the current screen to the selected screen.
proc SwitchScreen
	push ax
	push bx
	push cx
	push si

	; if the current screen is the selected screen -> exit the proc
	mov al, [SelectedScreen]
	cmp al, [CurrentScreen]
	je @@ExitProc

	xor cx, cx
	mov cl, [ScreensLenght] ; max
	xor bx, bx ; for checking the screen
	@@FindSelectedScreen:
		cmp [Screens + bx], al
		je @@SwitchTheScreen

		@@ContinueToNextScreen:
			inc bx
			cmp [Screens + bx], "."
			jne @@ContinueToNextScreen

			; checking if it is the last screen
			add bx, 4 ; bx = screen index
			cmp bx, cx
			je @@ExitProc
			
			jmp @@FindSelectedScreen



	@@SwitchTheScreen:
		mov [CurrentScreen], al
		inc bx
		xor si, si
		@@ChangeFileName:
			cmp [Screens + bx], "."
			je @@AddBmp

			mov al, [Screens + bx]
			mov [FileName + si],  al

			inc bx
			inc si
			jmp @@ChangeFileName
		
		@@AddBmp:
			mov [FileName + si], "."
			inc si
			mov [FileName + si], "b"
			inc si
			mov [FileName + si], "m"
			inc si
			mov [FileName + si], "p"

			@@FillZero:
				; checking if it is the last char in the 'FileName' if not, fill with zero's
				cmp si, 11 
				je @@ExitProc

				inc si
				mov [FileName + si], 0
				jmp @@FillZero


	@@ExitProc:
		pop si
		pop cx
		pop bx
		pop ax
		ret
endp SwitchScreen


proc OpenShowBmp near

	call CloseBmpFile
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 
 
	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile
 
 
 



proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


 
 
proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine



; cx = col dx= row al = color si = height di = width 
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect



proc DrawSquare
	push si
	push ax
	push cx
	push dx
	
	mov al,[Color]
	mov si,[SquareSize]  ; line Length
 	mov cx,[Xp]
	mov dx,[Yp]
	call DrawHorizontalLine

	 
	
	call DrawVerticalLine
	 
	
	add dx ,si
	dec dx
	call DrawHorizontalLine
	 
	
	
	sub  dx ,si
	inc dx
	add cx,si
	dec cx
	call DrawVerticalLine
	
	
	 pop dx
	 pop cx
	 pop ax
	 pop si
	 
	ret
endp DrawSquare




 
   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

 

 
 
 


proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	dec di
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 


 
END start


