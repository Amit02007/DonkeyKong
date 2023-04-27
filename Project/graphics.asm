IDEAL

MODEL small
STACK 256


DATASEG

    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileName 	db "XXXXXXXX.bmp", 0
 
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)

	Screens db 	0, "menu.bmp"	
			db	1, "game254.bmp"
			db	2, "help.bmp"
			db	3, "pause.bmp"
	
	ScreensLenght db $ - Screens

	; The current screen and the selected screen must initialize different
	CurrentScreen db 2
	SelectedScreen db 1
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File', 0dh, 0ah,'$'
	ErrorFile           db 0
	
	Matrix dw ?

	Color db ? 
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	 
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?

	FloorColor db ?

CODESEG

;================================================
; Description - Initialize the graphics
; INPUT: None
; OUTPUT: None
;================================================
proc InitGraphics
	call SetGraphic

	; Change the file name
	mov [SelectedScreen], 0
	call SwitchScreen

	; Load the image
	call UpdateBackgourndImage

	; Reset cruser
	xor ax, ax 
    int 33h 

	; Show cruser
	mov ax, 01h
    int 33h

	; Change the cursor
	push 0
	push 0
	push offset DefaultCursor
	call ChangeCursor

	ret
endp InitGraphics


;================================================
; Description - A procedure that changes the current screen to the selected screen
; INPUT: SelectedScreen
; OUTPUT: Memory: CurrentScreen, FileName
;================================================
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

;================================================
; Description - A procedure that updates the background image
; INPUT: FileName
; OUTPUT: Background image on screen
;================================================
proc UpdateBackgourndImage
	push ax
	push dx

	; Hide cruser
	mov ax, 02h
	int 33h

	; Close the last background file
	call CloseBmpFile

	; Open and show the new background
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	call OpenShowBmp
	cmp [ErrorFile], 0
	je @@NoError
	jmp exitError

	@@NoError:
		; Show cruser
		mov ax, 01h
		int 33h
		
		; Update the floor color
		push 65
		push 190
		call GetPixelColor
		mov [FloorColor], al

		pop dx
		pop ax
		ret
endp UpdateBackgourndImage

;================================================
; Description - This procedure is converting a position in a matrix to a position in the screen. 
;				It takes the x and y parameters and multiplies the y parameter 
;				by 320 (the width of the screen) to get the correct position in the screen. 
; INPUT: Stack: xParam, yParam
; OUTPUT: di: the matrix position
;================================================
xParam equ [bp + 6]
yParam equ [bp + 4]
proc ConvertMatrixPos
	push bp
	mov bp, sp
	push ax
	push cx

	mov ax, xParam
	mov cx, yParam
	cmp cx, 0
	je @@Quit
	@@MulBy320:
		add ax, 320
	loop @@MulBy320

	mov di, ax

	@@Quit:
		pop cx
		pop ax
		pop bp
		ret 4
endp ConvertMatrixPos

;================================================
; Description - Reads the color of a pixel
; INPUT: Stack: xPixel, yPixel
; OUTPUT: al: the color
;================================================
xPixel equ [bp + 6]
yPixel equ [bp + 4]
proc GetPixelColor
	push bp
	mov bp, sp
	push bx
	push cx
	push dx

	mov ah, 0dh
	mov bx, 0
	mov cx, xPixel
	mov dx, yPixel
	int 10H ; AL = COLOR

	xor ah, ah

	pop dx
	pop cx
	pop bx
	pop bp
    ret 4
endp GetPixelColor


proc OpenShowBmp

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
proc OpenBmpFile						 
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
 

proc CloseBmpFile
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile


; Read 54 bytes the Header
proc ReadBmpHeader					
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


proc ReadBmpPalette ; Read BMP file color palette, 256 colors * 4 bytes (400h)
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
proc CopyBmpPalette					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
	@@CopyNextColor:
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
								
	loop @@CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


proc DrawHorizontalLine
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


proc DrawVerticalLine
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

 
proc SetGraphic
	mov ax, 13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp SetGraphic

 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
proc ShowBMP 
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


; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)
proc putMatrixInScreen
	push es
	push ax
	push si
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	push dx
	mov ax,cx
	mul dx
	mov bp,ax
	pop dx
	
	
	mov si,[matrix]
	
NextRow:	
	push cx
	
	mov cx, dx
	rep movsb ; Copy line to the screen
	sub di,dx
	add di, 320
	
	
	pop cx
	loop NextRow
	
	
endProc:	
	
	pop si
	pop ax
	pop es
    ret
endp putMatrixInScreen