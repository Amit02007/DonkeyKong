IDEAL

MODEL small
STACK 256


DATASEG
	
	; Up Arrow -> U
	; Down Arrow -> D
	; Left Arrow -> L
	; Right Arrow -> R
	; Space -> S
	; Escape -> E
	ButtonPressed db 0
	ButtonPressed2 db 0
	LastButtonPressed db 0
	

	ButtonPressedScan dw ?

	ArrowKeyScan  db 48h,50h,4dh,4bh
    ArrowKey db "UDRL"

CODESEG

proc DetectKey
	push ax
	push bx
	push cx

	mov al, [ButtonPressed2]
	mov [LastButtonPressed], al

	; Check if a key pressed
	mov ah, 01h
	int 16h
	jz @@NotPressed


	@@CheckForKey:
		mov ah, 00h
		int 16h

		; Check if a key pressed
		push ax
		mov ah, 01h
		int 16h
		jz @@NoMoreKeys
		pop ax
		jmp @@CheckForKey

	@@NoMoreKeys:
		pop ax

	mov [ButtonPressedScan], ax
	cmp ax, 11bh
	je @@Escape

	cmp ax, 3920h
	je @@Space

	jmp @@CheckArrows

	@@Escape:
		mov [ButtonPressed], "E"
		jmp @@Quit

	@@Space:
		mov [ButtonPressed], "S"
		jmp @@Quit


	@@CheckArrows:
		mov al, ah
		mov bx, -1
		@@FindDirection:
			cmp bx, 5
			je @@NotPressed
			inc bx 
			cmp al, [ArrowKeyScan + bx] 
			jne @@FindDirection 

		mov al, [ArrowKey + bx]
		mov [ButtonPressed], al
		mov [ButtonPressed2], al

		jmp @@Quit

	@@NotPressed:
		mov [ButtonPressed], 0
		mov [ButtonPressed2], 0
		mov [ButtonPressedScan], 0

	@@Quit:
		pop cx
		pop bx
		pop ax
		ret
endp DetectKey