IDEAL

MODEL small
STACK 256


DATASEG

	DefaultCursor  	dw 0000111111111111b
					dw 0000011111111111b
					dw 0000011111111111b
					dw 1000001111111111b
					dw 1000000000000111b
					dw 1000000000000011b
					dw 1100000000000001b
					dw 1100000000000001b
					dw 1100000000000001b
					dw 1000000000000001b
					dw 0000000000000001b
					dw 0000000000000001b
					dw 0000000000000001b
					dw 1000000000000001b
					dw 1110000000000011b
					dw 1111110000000111b

					dw 0000000000000000b
					dw 0111000000000000b
					dw 0111000000000000b
					dw 0011100000000000b
					dw 0011110000000000b
					dw 0011111011111000b
					dw 0001111111111100b
					dw 0001111111111100b
					dw 0001111111111100b
					dw 0001111111111100b
					dw 0110111111111100b
					dw 0111111111111100b
					dw 0011111111111100b
					dw 0001111111111100b
					dw 0000001111111000b
					dw 0000000000000000b


	ClickCursor  	dw 1110011111111111b
					dw 1100001111111111b
					dw 1100001111111111b
					dw 1100001111111111b
					dw 1100001111111111b
					dw 1100000001111111b
					dw 1000000000111111b
					dw 0000000000111111b
					dw 0000000000011111b
					dw 1000000000011111b
					dw 1000000000011111b
					dw 1100000000011111b
					dw 1100000000011111b
					dw 1110000000111111b
					dw 1110000001111111b
					dw 1111000011111111b

					dw 0000000000000000b
					dw 0001100000000000b
					dw 0001100000000000b
					dw 0001100000000000b
					dw 0001100000000000b
					dw 0001110000000000b
					dw 0001111110000000b
					dw 0101111110000000b
					dw 0110111111000000b
					dw 0011111111000000b
					dw 0011111111000000b
					dw 0001111111000000b
					dw 0001111111000000b
					dw 0000111110000000b
					dw 0000111100000000b
					dw 0000000000000000b

	EmptyCursor dw 16 dup (1), 16 dup (0)


	MousePosX dw ?
	MousePosY dw ?
	IsLeftButtonPressed db 0
	IsRightButtonPressed db 0

CODESEG

HotSpotX equ [word ptr bp + 8]
HotSpotY equ [word ptr bp + 6]
CursorOffset equ [word ptr bp + 4]
proc ChangeCursor
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es


	mov ax, 9
	push ds
	pop es
	mov bx, HotSpotX
	mov cx, HotSpotY
	mov dx, CursorOffset
	int 33h


	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	
endp ChangeCursor


proc UpdateMouse
	push ax
	push bx
	push cx
	push dx

	xor bx, bx

	mov ax, 3
	int 33h
	shr cx, 1
	mov [MousePosX], cx
	mov [MousePosY], dx

	mov ax, bx

	shl bx, 7
	shr bx, 7
	mov [IsLeftButtonPressed], bl

	shr ax, 1
	shl ax, 7
	shr ax, 7
	mov [IsRightButtonPressed], al

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp UpdateMouse


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
