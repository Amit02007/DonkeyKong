IDEAL

MODEL small
STACK 256

Clock equ es:6Ch


include "marioG.asm"

DATASEG

	MarioTopPointX dw ?
	MarioTopPointY dw ?

	LastFall dw 0
	LastJump dw 0
	IsJumping db 0
	JumpingDirection db 0

	IsInit db 0

	MarioJumpState db 0
	MarioJumpCounter db 0

CODESEG


proc InitMario
	push ax
	push bx
	push dx
	push si
	
	mov [MarioJumpState], 0
	mov [MarioJumpCounter], 0

	mov [MarioTopPointX], 61
	mov [MarioTopPointY], 170

	; Get first backgound
	xor cx, cx
	mov cl, [MarioWidth]

	xor si, si
	@@Column:
		xor bx, bx
		@@Row:
			mov ax, [MarioTopPointX]
			add ax, bx
			push ax
			mov ax, [MarioTopPointY]
			add ax, si
			push ax
			call GetPixelColor

			push si
			push ax
			mov dx, si
			mov al, [MarioWidth]
			mul dl
			add ax, bx
			mov si, ax
			pop ax

			mov [LastMarioPos + si], al
			pop si
			inc bx
			cmp bx, cx
			jne @@Row
	
	xor bx, bx
	mov bl, [MarioHeight]
	inc si
	cmp si, bx
	jne @@Column

	push "1"
	call ChangeMarioImage

	pop ax
	pop bx
	pop bx
	pop si
	ret
endp InitMario


proc UpdateMario

	cmp [CurrentScreen], 1
	je @@NotRemoveMario

	; TODO: Change the location of DetectDirection
	cmp [CurrentScreen], 3
	je @@Pause
	jmp @@RemoveMario

	@@Pause:
		cmp [IsInit], 2
		jne @@Remove
		jmp @@Quit

		@@Remove:
			call CloseMarioBmpFile
			mov [IsInit], 2
			jmp @@Quit

	@@NotRemoveMario:

	cmp [IsInit], 1
	je @@Init
	call InitMario
	mov [IsInit], 1

	@@Init:
		call UpdateMarioImage

		cmp [MarioJumpState], 1
		je @@Jump

		call CheckJump
		cmp ax, 0
		je @@ResumeFalling

		mov [IsJumping], 0
		mov [JumpingDirection], 0

		@@ResumeFalling:
			call MarioFalling
			jmp @@Resume

		@@Jump:
			mov [IsJumping], 1
			call MarioJump


		@@Resume:
		cmp [ButtonPressed], "L"
		je @@Left
		cmp [ButtonPressed], "R"
		je @@Right
		cmp [ButtonPressed], "S"
		jne @@NotJump
		jmp @@Up

		@@NotJump:
		jmp @@Quit

		@@Left:
			call MoveMarioLeft
			jmp @@Quit

		@@Right:
			call MoveMarioRight
			jmp @@Quit

		@@Up:
			push ax

			call CheckJump
			cmp ax, 1
			jne @@DontJump
			
			mov [MarioJumpState], 1

			cmp [LastButtonPressed], "L"
			je @@JumpingDirectionLeft

			cmp [LastButtonPressed], "R"
			je @@JumpingDirectionRight

			jmp @@DontJump

			@@JumpingDirectionLeft:
				mov [JumpingDirection], "L"
				jmp @@DontJump

			@@JumpingDirectionRight:
				mov [JumpingDirection], "R"

			@@DontJump:
				pop ax



	jmp @@Quit

	@@RemoveMario:
		mov [IsInit], 0
		call CloseMarioBmpFile

	@@Quit:
		ret
endp UpdateMario


proc MoveMarioLeft
	; cmp [MarioFileName + 5], "2"
	; je @@CorrectImage
			
	; push "2"
	; call ChangeMarioImage

	@@CorrectImage:
		call CheckStairs
		call MoveMarioPixelLeft

	ret
endp MoveMarioLeft


proc MoveMarioRight
	; cmp [MarioFileName + 5], "1"
	; je @@CorrectImage

	; push "1"
	; call ChangeMarioImage

	@@CorrectImage:
		call CheckStairs
		call MoveMarioPixelRight

	ret
endp MoveMarioRight


proc CheckJump
	push cx

	xor ax, ax
	mov al, [MarioHeight]

	mov cx, [MarioTopPointY]
	add cx, ax

	push [MarioTopPointX]
	push cx
	call GetPixelColor

	cmp al, [FloorColor]
	je @@True

	; False -> Check the right corner
	xor cx, cx
	mov cl, [MarioWidth]

	mov ax, [MarioTopPointX]
	add ax, cx

	push ax
	xor ax, ax
	mov al, [MarioHeight]

	mov cx, [MarioTopPointY]
	add cx, ax

	pop ax

	push ax
	push cx
	call GetPixelColor

	cmp al, [FloorColor]
	je @@True

	; Only if both corners are false
	mov ax, 0
	jmp @@Quit

	@@True:
		mov ax, 1

	@@Quit:
		pop cx
		ret
endp CheckJump


proc MarioJump near
	push ax
	push bx
	push cx
	push es

	mov ax, 40h
	mov es, ax

	mov ax, [Clock]

	cmp ax, [LastJump]
	je @@OnAir
	mov [LastJump], ax

	cmp [MarioJumpCounter], 7
	je @@StopJump

	call MoveMarioPixelUp
	call MoveMarioPixelUp
	inc [MarioJumpCounter]
	jmp @@OnAir

	@@StopJump:
		mov [MarioJumpState], 0
		mov [MarioJumpCounter], 0

	@@OnAir:
		pop es
		pop cx
		pop bx
		pop ax
		ret
endp MarioJump


proc MarioFalling near
	push ax
	push bx
	push cx
	push dx
	push es
	
	mov ax, 40h
	mov es, ax

	mov ax, [Clock]

	cmp ax, [LastFall]
	je @@OnFloor
	mov [LastFall], ax

	xor dx, dx
	mov dl, [MarioHeight]

	mov bx, 2
	@@Fall:
		xor dx, dx
		mov dl, [MarioHeight]

		mov cx, [MarioTopPointY]
		add cx, dx

		push [MarioTopPointX]
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		xor dx, dx
		mov dl, [MarioWidth]
		dec dx

		mov ax, [MarioTopPointX]
		add ax, dx
		push ax
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		call MoveMarioPixelDown

	dec bx
	cmp bx, 0
	jne @@Fall


	@@OnFloor:
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MarioFalling


proc CheckStairs near
	push ax
	push bx
	push cx

	cmp [ButtonPressed], "L"
	je @@Left

	cmp [ButtonPressed], "R"
	je @@Right

	jmp @@Quit

	@@Left:
		xor bx, bx
		mov bl, [MarioHeight]
		dec bx

		mov cx, [MarioTopPointX]
		dec cx
		push cx
		mov ax, [MarioTopPointY]
		add ax, bx
		push ax
		call GetPixelColor
		
		cmp al, [FloorColor]
		jne @@Quit

		call MoveMarioPixelUp
		call MoveMarioPixelUp
		jmp @@Quit

	@@Right:
		xor bx, bx
		mov bl, [MarioWidth]
		dec bx

		mov cx, [MarioTopPointX]
		add cx, bx
		push cx

		mov bl, [MarioHeight]
		dec bx

		mov ax, [MarioTopPointY]
		add ax, bx
		push ax
		call GetPixelColor

		cmp al, [FloorColor]
		jne @@Quit

		call MoveMarioPixelUp
		call MoveMarioPixelUp
		jmp @@Quit

	@@Quit:
		pop cx
		pop bx
		pop ax
		ret
endp CheckStairs


proc MarioPhysics near

	push [MarioTopPointX]
	mov ax, [MarioTopPointY]
	add ax, 17
	push ax
	call GetPixelColor
	cmp al, [FloorColor]
	je @@OnFloor



	@@OnFloor:
		ret
endp MarioPhysics