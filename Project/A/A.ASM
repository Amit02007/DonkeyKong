IDEAL
MODEL small
 
p186


 
MACRO PUT_CHAR   MY_CHAR
	mov dl,MY_CHAR
	mov ah,2
	int 21h
ENDM 


STACK 100h


DATASEG

	FileName1 	db 'mario1.bmp' ,0
	FileName2 	db 'mario3.bmp' ,0

    BMP_WIDTH = 320
    BMP_HEIGHT = 200

    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer 
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)

	OrigPalette db 300h dup (0)

	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?


    ; print Pallete colors
    NUM_OF_COLORS = 256
    SCR_WIDTH = 320
    SCR_HEIGHT = 200
    MAX_BOX_IN_COL = 16
    MAX_BOX_IN_ROW = 16


    BOX_HIGHT dw 0
    BOX_WIDTH dw 0
    curr_row  dw 0
    curr_col  dw 0


	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0

CODESEG
 
start:
	mov ax, @data
	mov ds, ax

	call SetGraphic

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Save the original pallete
    push ds
    push offset OrigPalette
    call SavePalette

    ; ;Change palette for bitmap

    push ds
    push WORD OrigPalette
    call RestorePalette


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; show the original pallete
    ;
    call PrintPallete 
    mov ah,1 ;silent input
	int 21h
	
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	mov dx, offset FileName1
	call OpenShowBmp
	cmp [ErrorFile],1
	jne cont 
	jmp exitError
cont:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; show the pallete after loading a BMP file
    ;
    call PrintPallete 
    mov ah,1 ;silent input
	int 21h
    jmp @@10

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Restore the original pallete
    push ds
    push offset OrigPalette
    call RestorePalette
    call PrintPallete 
    mov ah,1 ;silent input
	int 21h

    ;jmp exit

@@10:
	
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200	
	mov dx,offset FileName2
	call OpenShowBmp 
	cmp [ErrorFile],1
	jne cont1
	jmp exitError
cont1:	
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; show the pallete after another a BMP file was loaded
    ;
    call PrintPallete 
    mov ah,1 ;silent input
	int 21h





    jmp exit
exitError:
	mov ax,2
	int 10h
	
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
exit:

	mov ax,2
	int 10h
	
	mov ax, 4c00h
	int 21h
	

	
;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================
proc PrintPallete
    mov dx,0
    mov ax, SCR_WIDTH
    mov bx, MAX_BOX_IN_COL
    div bx
    mov [BOX_WIDTH], ax
   
    mov dx,0
    mov ax, SCR_HEIGHT
    mov bx, MAX_BOX_IN_ROW
    div bx
    mov [BOX_HIGHT], ax

    mov cx, NUM_OF_COLORS
    mov bx, 0
PrintNextBox:
    push cx

    push ax
    push bx
    mov ax,bx
    mov bx,MAX_BOX_IN_COL
    div bl
    
    mov [curr_row], 0
    mov [curr_col], 0
    mov [byte curr_row], al
    mov [byte curr_col], ah

    mov ax, [BOX_HIGHT]
    mul [curr_row]
    mov [curr_row], ax

    mov ax, [BOX_WIDTH]
    mul [curr_col]
    mov [curr_col], ax

    ; cx = col dx= row al = color si = height di = width 
    mov ax,cx
    mov ax, [BOX_WIDTH]
    mul [curr_row]
    mov cx,ax
    pop bx
    pop ax

    mov ax, bx
	mov cx,[curr_col]
	mov dx,[curr_row]
	mov si,[BOX_HIGHT]
	mov di,[BOX_WIDTH]
	call Rect
    inc bx
    pop cx
    
    loop PrintNextBox
    
    ret
endp PrintPallete



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


proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	call ReadBmpPalette
	call CopyBmpPalette
	call  ShowBmp
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



;WORD Buffer Segment
;WORD Buffer Offset
;DF = Direction of saving
proc SavePalette
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push dx
    push cx

    mov es, [WORD bp+06h]
    mov di, [WORD bp+04h]

    xor al, al
    mov dx, 3c7h
    out dx, al      ;Read from index 0

    inc dx
    inc dx
    mov cx, 300h        ;3x256 reads
    rep insb

    pop cx
    pop dx
    pop ax
    pop di
    pop es

    pop bp
    ret 04h
endp SavePalette

;WORD Buffer Segment
;WORD Buffer Offset
;DF = Direction of loading
proc RestorePalette
    push bp
    mov bp, sp

    push ds
    push si
    push ax
    push dx
    push cx

    mov ds, [WORD bp+06h]
    mov si, [WORD bp+04h]

    xor al, al
    mov dx, 3c8h
    out dx, al      ;Write from index 0

    inc dx
    mov cx, 300h        ;3x256 writes
    rep outsb

    pop cx
    pop dx
    pop ax
    pop si
    pop ds

    pop bp
    ret 04h
endp RestorePalette






proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic
 

proc ShowAxDecimal
	   push ax
       push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal

proc ShowAxHex
	
	mov bx,ax
	mov cx,4
@@Next:
	
	mov dx,0f000h
	and dx,bx
	rol dx, 4          
	cmp dl, 9
	ja @@n1
	add dl, '0'
	jmp @@n2

@@n1:	 
	add dl, ('A' - 10)

@@n2:
	mov ah, 2
	int 21h
	shl bx,4
	loop @@Next
	
	ret
endp ShowAxHex

 
END start

