IDEAL

MODEL small
STACK 150h

Clock equ es:6Ch

include "graphics/marioG.asm"

DATASEG

	MarioTopPointX dw ?
	MarioTopPointY dw ?

	LastFall dw 0
	LastJump dw 0
	IsJumping db 0
	JumpingDirection db 0
	MarioJumpState db 0
	MarioJumpCounter db 0

	IsReadyToClimb db 0
	MarioClimbState db 0
	LastClimb dw 0

	; IsInit db 0
	IsSlower db 0


CODESEG


proc InitMario
	push ax
	push bx
	push dx
	push si
	
	mov [MarioJumpState], 0
	mov [MarioJumpCounter], 0

	mov [MarioTopPointX], 65
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

	call RefreshMario
	push "1"
	call ChangeMarioImage

	push 1
	call StartTimer

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp InitMario


proc UpdateMario
	push ax

	call UpdateMarioImage

	cmp [MarioClimbState], 1
	jne @@NotClimb

	call MarioClimb

	jmp @@Quit

	@@NotClimb:

	cmp [MarioJumpState], 1
	je @@Jump

	call CheckOnFloor
	cmp ax, 0
	je @@ResumeFalling

	; On floor
		; mov [IsJumping], 0

		; mov [JumpingDirection], 0

		; jmp @@Resume
	

	cmp [IsJumping], 1 ; Means that returned from jump to floor
	je @@ReturnFromJump

	cmp [IsJumping], 2 
	je @@AlreadyReturned

	jmp @@JumpingDirectionZero

	@@ReturnFromJump:
		mov [IsJumping], 2
		jmp @@JumpingDirectionZero

	@@AlreadyReturned:
		mov [IsJumping], 0

	@@JumpingDirectionZero:
		mov [JumpingDirection], 0
		jmp @@Resume

	@@ResumeFalling:
		mov [IsSlower], 1
		call MarioFalling
		jmp @@Quit

	@@Jump:
		mov [IsJumping], 1
		call MarioJump
		jmp @@Quit

	@@Resume:
	mov [IsSlower], 0

	call CheckIsReadyToClimb

	cmp [ButtonPressed], "L"
	je @@Left
	cmp [ButtonPressed], "R"
	je @@Right
	cmp [ButtonPressed], "S"
	je @@Up
	cmp [ButtonPressed], "U"
	je @@ClimbButton
	cmp [ButtonPressed], "D"
	je @@ClimbButton

	jmp @@Quit

	@@Left:
		call MoveMarioLeft
		jmp @@Quit

	@@Right:
		call MoveMarioRight
		jmp @@Quit

	@@Up:
		push ax

		call CheckOnFloor
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

	@@ClimbButton:
		call CheckIsReadyToClimb

		cmp [IsReadyToClimb], 0
		je @@Quit

		mov [MarioClimbState], 1

		jmp @@Quit

	@@Quit:
		pop ax
		ret
endp UpdateMario


proc MoveMarioLeft
	cmp [MarioTopPointX], 65
	je @@Quit

	call CheckStairs
	call MoveMarioPixelLeft
	call CheckStairs
	call MoveMarioPixelLeft

	@@Quit:
		ret
endp MoveMarioLeft


proc MoveMarioRight
	cmp [MarioTopPointX], 249
	jge @@Quit
	
	call CheckStairs
	call MoveMarioPixelRight
	call CheckStairs
	call MoveMarioPixelRight

	@@Quit:
		ret
endp MoveMarioRight


proc MarioClimb
	push ax

	cmp [LastButtonPressed], "U"
	je @@Up
	cmp [LastButtonPressed], "D"
	je @@Down

	jmp @@OnLadder

	@@Up:
		call IsBrokenLadder
		cmp al, 1
		je @@Quit
		call MoveMarioPixelUp
		call IsReachTopLadder
		cmp al, 1
		jne @@Quit

		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		call MoveMarioPixelUp
		mov [MarioClimbState], 0
		
		cmp [MarioTopPointY], 21
		ja @@Quit

		; Show cruser
		mov ax, 01h
		int 33h

		CHANGE_BACKGROUND 5
		
		jmp @@Quit

	@@Down:
		call CheckOnFloor
		cmp al, 1
		jne @MoveDown

		mov [MarioClimbState], 0
		jmp @@Quit

		@MoveDown:
			call MoveMarioPixelDown
			jmp @@Quit

	@@Quit:
		call CheckEndClimb

		@@OnLadder:
		pop ax
		ret
endp MarioClimb


proc IsBrokenLadder
	push bx
	push cx

	xor ax, ax
	
	xor cx, cx
	mov cl, [MarioWidth]

	xor bx, [MarioArea]
	sub bx, cx
	sub bx, cx
	@@CheckForLadder:
		xor al, al
		cmp al, [LastMarioPos + bx]
		jne @@LadderFound

		inc bx
	loop @@CheckForLadder
	
	mov ax, 1
	jmp @@Quit

	@@LadderFound:
		xor ax, ax
	@@Quit:
		pop cx
		pop bx
		ret
endp IsBrokenLadder


proc CheckEndClimb
	push ax
	push bx
	push cx
	push si


	; mov bx, [MarioTopPointX]

	xor ax, ax
	mov al, [LadderColor]

	
	xor cx, cx
	mov cl, [MarioWidth]

	xor bx, [MarioArea]
	sub bx, cx
	@@CheckForLadder:
		cmp al, [LastMarioPos + bx]
		je @@LadderFound

		inc bx
	loop @@CheckForLadder


	; call CheckOnFloor
	; cmp al, 1
	; jne @@CheckAbove
	
	mov [MarioClimbState], 0
	jmp @@Quit

	; @@CheckAbove:
	@@LadderFound:
	@@Quit:
		pop si
		pop cx
		pop bx
		pop ax
		ret
endp CheckEndClimb


proc CenterMarioOnLadder
	push ax

	call GetAmountOfLadderColor
	mov dx, cx
	call MoveMarioPixelRight
	call GetAmountOfLadderColor
	cmp cx, dx
	jg @@MoveRight
	jmp @@MoveLeft

	@@MoveRight:
		cmp cx, 60
		jg @@Quit

		call MoveMarioPixelRight
		call GetAmountOfLadderColor
		jmp @@MoveRight


	@@MoveLeft:
		cmp cx, 60
		jg @@Quit

		call MoveMarioPixelLeft
		call GetAmountOfLadderColor
		jmp @@MoveLeft



	@@Quit:
		pop ax
		ret
endp CenterMarioOnLadder


proc GetAmountOfLadderColor
	push ax
	push bx
	push dx
	push si

	xor cx, cx
	xor si, si
	xor bx, bx
	@@Column:
		xor bx, bx
		@@Row:

		push bx
		push si

		mov dx, si
		xor ax, ax
		mov al, [MarioWidth]
		mul dl
		add ax, bx
		mov si, ax

		mov al, [LastMarioPos + si]

		pop si
		pop bx

		cmp al, 0
		je @@NotFoundLadder

		inc cx

		@@NotFoundLadder:
			inc bx
			cmp bl, [MarioWidth]
			jne @@Row

	xor bx, bx
	mov bl, [MarioHeight]
	inc si
	cmp si, bx
	jne @@Column

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp GetAmountOfLadderColor


proc CheckIsReadyToClimb
	push ax
	push bx
	push dx
	push si
	
	xor si, si
	xor bx, bx
	@@Column:
		xor bx, bx
		@@Row:

		mov al, [LastMarioPos + bx + si]

		cmp al, [LadderColor]
		jne @@NoBackGound
		jmp @@FoundColor

		@@NoBackGound:
			inc bx
			cmp bl, [MarioWidth]
			jne @@Row

	xor bx, bx
	mov bl, [MarioWidth]
	add si, bx
	mov bx, [MarioArea]
	cmp si, bx
	jne @@Column

	mov [IsReadyToClimb], 0
	jmp @@Quit


	@@FoundColor:
		call CheckOnFloor
		cmp al, 1
		jne @@Quit
		mov [IsReadyToClimb], 1
	

	@@Quit:
		pop si
		pop dx
		pop bx
		pop ax
		ret
endp CheckIsReadyToClimb


proc IsStandingOnLadder
	push bx
	push cx
	push dx

	xor cx, cx
	mov cl, [MarioHeight]
	mov bx, [MarioTopPointY]
	add bx, cx
	
	mov dx, [MarioTopPointX]
	mov cl, [MarioWidth]
	@@FindLadder:
		push dx
		push bx
		call GetPixelColor

		cmp al, [LadderColor]
		je @@FoundLadder

		inc dx
	loop @@FindLadder


	mov ax, 0
	jmp @@Quit

	@@FoundLadder:
		mov ax, 1

	@@Quit:
		pop dx
		pop cx
		pop bx
		ret
endp IsStandingOnLadder


proc IsReachTopLadder
	push bx
	push cx
	push si
	
	xor cx, cx
	mov cl, [MarioWidth]
	mov bx, [MarioArea]
	sub bx, cx
	sub bx, cx
	
	mov si, [MarioArea]
	sub si, cx

	@@FindFloor:
		mov al, [LastMarioPos + bx]

		cmp al, [FloorColor]
		je @@FoundFloor

		inc bx
		cmp bx, si
		jne @@FindFloor

	xor ax, ax
	jmp @@Quit


	@@FoundFloor:
		mov ax, 1
		jmp @@Quit
	

	@@Quit:
		pop si
		pop cx
		pop bx
		ret
endp IsReachTopLadder


proc CheckOnFloor
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
endp CheckOnFloor


proc MarioJump near
	push ax
	push bx
	push cx
	push es

	mov ax, 40h
	mov es, ax

	mov ax, [Clock]

	cmp ax, [LastJump]
	jne @@Resume
	jmp @@OnAir
	@@Resume:
	mov [LastJump], ax

	cmp [MarioJumpCounter], 11
	je @@StopJump

	call MoveMarioPixelUp
	call MoveMarioPixelUp
	inc [MarioJumpCounter]
	cmp [IsAddedScore], 1
	jne @@NotAddedScore
	jmp @@OnAir

	@@StopJump:
		mov [IsAddedScore], 0
		mov [MarioJumpState], 0
		mov [MarioJumpCounter], 0
		jmp @@OnAir


	@@NotAddedScore:

	xor bx, bx
    @@FindMovingBarrel:
        cmp [word ptr Barrels + bx], 0
        jne @@Found

        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jb @@FindMovingBarrel

    jmp @@OnAir
	
    @@Found:
        xor cx, cx

        mov ax, [Barrels + bx]
        cmp ax, [MarioTopPointX]
        jnae @@NextBarrelInList

        mov ax, [Barrels + bx]
        mov cx, [MarioTopPointX]
        add cl, [MarioWidth]
        dec cx
        cmp ax, cx
        ja @@NextBarrelInList

        mov ax, [Barrels + bx + 2]
		sub ax, 15
        cmp ax, [MarioTopPointY]
        jb @@NextBarrelInList

        mov ax, [Barrels + bx + 2]
		sub ax, 15
        mov cx, [MarioTopPointY]
        add cl, [MarioHeight]
        dec cx
        cmp ax, cx
        jnbe @@NextBarrelInList

		call AddScore
		mov [IsAddedScore], 1
		
		jmp @@OnAir

		@@NextBarrelInList:
			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jnbe @@OnAir

			jmp @@FindMovingBarrel


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

		; call IsStandingOnLadder
		; cmp al, 1
		; je @@OnFloor

		
		; cmp al, [LadderColor]
		; je @@OnFloor

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