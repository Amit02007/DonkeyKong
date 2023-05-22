IDEAL

MODEL small
STACK 90


include "graphics/peachG.asm"

DATASEG

	PeachTopPointX dw 142
	PeachTopPointY dw 0

CODESEG


proc InitPeach
	push ax
	push bx
	push dx
	push si

	mov [PeachTopPointX], 142
	mov [PeachTopPointY], 0

	; Get first backgound
	xor cx, cx
	mov cl, [PeachWidth]

	xor si, si
	@@Column:
		xor bx, bx
		@@Row:
			mov ax, [PeachTopPointX]
			add ax, bx
			push ax
			mov ax, [PeachTopPointY]
			add ax, si
			push ax
			call GetPixelColor

			push si
			push ax
			mov dx, si
			mov al, [PeachWidth]
			mul dl
			add ax, bx
			mov si, ax
			pop ax

			mov [LastPeachPos + si], al
			pop si
			inc bx
			cmp bx, cx
			jne @@Row
	
	xor bx, bx
	mov bl, [PeachHeight]
	inc si
	cmp si, bx
	jne @@Column

	push "2"
	call ChangePeachImage

	push 9
	call StartTimer

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp InitPeach


proc UpdatePeach
	
    call UpdatePeachImage

	@@Quit:
		ret
endp UpdatePeach



