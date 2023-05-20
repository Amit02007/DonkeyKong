IDEAL

MODEL small
STACK 90

Clock equ es:6Ch


include "dkG.asm"

DATASEG

	DkTopPointX dw ?
	DkTopPointY dw ?

	IsDroppingBarrel db 0

CODESEG


proc InitDk
	push ax
	push bx
	push dx
	push si

	mov [DkTopPointX], 83
	mov [DkTopPointY], 14

	; Get first backgound
	xor cx, cx
	mov cl, [DkWidth]

	xor si, si
	@@Column:
		xor bx, bx
		@@Row:
			mov ax, [DkTopPointX]
			add ax, bx
			push ax
			mov ax, [DkTopPointY]
			add ax, si
			push ax
			call GetPixelColor

			push si
			push ax
			mov dx, si
			mov al, [DkWidth]
			mul dl
			add ax, bx
			mov si, ax
			pop ax

			mov [LastDkPos + si], al
			pop si
			inc bx
			cmp bx, cx
			jne @@Row
	
	xor bx, bx
	mov bl, [DkHeight]
	inc si
	cmp si, bx
	jne @@Column

	push "1"
	call ChangeDkImage

	push 5
	call StartTimer

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp InitDk


proc UpdateDk
	
    call DkDropBarrel

	@@Quit:
		ret
endp UpdateDk


proc DkDropBarrel
	push ax

	cmp [IsDroppingBarrel], 0
	jne @@CheckTime
	jmp @@Quit


	@@CheckTime:
		push 5
		Call GetTime

		cmp [IsReadyToClimb], 1
		je @@Slower

		cmp [MarioClimbState], 1
		jne @@NotJumping

		@@Climb:
			cmp al, 20
			jnb @@Resume
			jmp @@Quit


		@@Slower:
			cmp al, 14
			jnb @@Resume
			jmp @@Quit

		@@NotJumping:
			cmp al, 8
			jnb @@Resume
			jmp @@Quit

		@@Resume:
			push 5
			call StopTimer
			push 5
			call ResetTimer
			push 5
			call StartTimer


	cmp [CurrentDkImage], "4"
	jne @@IncImage

	mov [CurrentDkImage], "1"
	call RefreshDk
	push [CurrentDkImage]
	call ChangeDkImage
	mov [IsDroppingBarrel], 0
    call CreateBarrel
	jmp @@Quit


	@@IncImage:
		inc [CurrentDkImage]
		call RefreshDk
		push [CurrentDkImage]
		call ChangeDkImage


	@@Quit:
		pop ax
		ret
endp DkDropBarrel


