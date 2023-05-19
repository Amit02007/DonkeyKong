IDEAL

MODEL small
STACK 90

Clock equ es:6Ch


include "dkG.asm"

DATASEG

	DkTopPointX dw ?
	DkTopPointY dw ?

	; LastFall dw 0
	; LastJump dw 0
	; IsJumping db 0
	; JumpingDirection db 0
	; DkJumpState db 0
	; DkJumpCounter db 0

	; IsReadyToClimb db 0
	; DkClimbState db 0
	; LastClimb dw 0

	IsDkInit db 0


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

	; push 1
	; call StartTimer

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp InitDk


proc UpdateDk

	; cmp [CurrentScreen], 1
	; je @@NotRemoveDk

	; ; TODO: Change the location of DetectDirection
	; cmp [CurrentScreen], 3
	; je @@Pause
	; jmp @@RemoveDk

	; @@Pause:
	; 	cmp [IsDkInit], 2
	; 	jne @@Remove
	; 	jmp @@Quit

	; 	@@Remove:
	; 		call CloseDkBmpFile
	; 		mov [IsDkInit], 2
	; 		jmp @@Quit

	; @@NotRemoveDk:

	; cmp [IsDkInit], 1
	; je @@Init
	; call InitDk
	; mov [IsDkInit], 1

	; @@Init:
		call UpdateDkImage

		
		; cmp [DkClimbState], 1
		; jne @@NotClimb

		; call DkClimb

		; jmp @@Quit

		; @@NotClimb:

		; cmp [DkJumpState], 1
		; je @@Jump

		; call CheckOnFloor
		; cmp ax, 0
		; je @@ResumeFalling

		; ; On floor

		; cmp [IsJumping], 1 ; Means that returned from jump to floor
		; je @@ReturnFromJump

		; cmp [IsJumping], 2 
		; je @@AlreadyReturned

		; jmp @@JumpingDirectionZero

		; @@ReturnFromJump:
		; 	mov [IsJumping], 2
		; 	jmp @@JumpingDirectionZero

		; @@AlreadyReturned:
		; 	mov [IsJumping], 0

		; @@JumpingDirectionZero:
		; 	mov [JumpingDirection], 0

		; @@ResumeFalling:
		; 	call DkFalling
		; 	jmp @@Resume

		; @@Jump:
		; 	mov [IsJumping], 1
		; 	call DkJump

		; @@Resume:

		; call CheckIsReadyToClimb

		; cmp [ButtonPressed], "L"
		; je @@Left
		; cmp [ButtonPressed], "R"
		; je @@Right
		; cmp [ButtonPressed], "S"
		; je @@Up
		; cmp [ButtonPressed], "U"
		; je @@ClimbButton
		; cmp [ButtonPressed], "D"
		; je @@ClimbButton

		; jmp @@Quit

		; @@Left:
		; 	call MoveDkLeft
		; 	jmp @@Quit

		; @@Right:
		; 	call MoveDkRight
		; 	jmp @@Quit

		; @@Up:
		; 	push ax

		; 	call CheckOnFloor
		; 	cmp ax, 1
		; 	jne @@DontJump
			
		; 	mov [DkJumpState], 1

		; 	cmp [LastButtonPressed], "L"
		; 	je @@JumpingDirectionLeft

		; 	cmp [LastButtonPressed], "R"
		; 	je @@JumpingDirectionRight

		; 	jmp @@DontJump

		; 	@@JumpingDirectionLeft:
		; 		mov [JumpingDirection], "L"
		; 		jmp @@DontJump

		; 	@@JumpingDirectionRight:
		; 		mov [JumpingDirection], "R"

		; 	@@DontJump:
		; 		pop ax

		; @@ClimbButton:

		; 	call CheckIsReadyToClimb

		; 	cmp [IsReadyToClimb], 0
		; 	je @@Quit

		; 	mov [DkClimbState], 1


	jmp @@Quit

	@@RemoveDk:
		mov [IsDkInit], 0
		call CloseDkBmpFile

	@@Quit:
		ret
endp UpdateDk


; proc MoveDkLeft
; 	; cmp [DkFileName + 5], "2"
; 	; je @@CorrectImage
			
; 	; push "2"
; 	; call ChangeDkImage

; 	@@CorrectImage:
; 		call CheckStairs
; 		call MoveDkPixelLeft

; 	ret
; endp MoveDkLeft


; proc MoveDkRight
; 	; cmp [DkFileName + 5], "1"
; 	; je @@CorrectImage

; 	; push "1"
; 	; call ChangeDkImage

; 	@@CorrectImage:
; 		call CheckStairs
; 		call MoveDkPixelRight

; 	ret
; endp MoveDkRight


; proc DkClimb
; 	push ax

; 	; xor ax, ax
; 	; mov al, [ButtonPressed]
; 	; call showaxdecimal

; 	cmp [LastButtonPressed], "U"
; 	je @@Up
; 	cmp [LastButtonPressed], "D"
; 	je @@Down

; 	jmp @@OnLadder

; 	@@Up:
; 		call MoveDkPixelUp
; 		jmp @@Quit

; 	@@Down:
; 		call CheckOnFloor
; 		cmp al, 1
; 		jne @MoveDown

; 		mov [DkClimbState], 0
; 		jmp @@Quit

; 		@MoveDown:
; 			call MoveDkPixelDown
; 			jmp @@Quit

; 	@@Quit:
; 		call CheckEndClimb
; 		; call CheckOnFloor
; 		; cmp al, 1
; 		; je @@StopClimb

; 		; call CheckIsReadyToClimb
; 		; cmp [IsReadyToClimb], 0
; 		; jne @@OnLadder

; 		; @@StopClimb:
; 		; mov [DkClimbState], 0

; 		@@OnLadder:
; 		pop ax
; 		ret
; endp DkClimb


; proc CheckEndClimb
; 	push ax
; 	push bx
; 	push cx
; 	push si


; 	; mov bx, [DkTopPointX]

; 	xor ax, ax
; 	mov al, [LadderColor]

	
; 	xor cx, cx
; 	mov cl, [DkWidth]

; 	xor bx, [DkArea]
; 	sub bx, cx
; 	@@CheckForLadder:
; 		cmp al, [LastDkPos + bx]
; 		je @@LadderFound

; 		inc bx
; 	loop @@CheckForLadder


; 	; call CheckOnFloor
; 	; cmp al, 1
; 	; jne @@CheckAbove
	
; 	mov [DkClimbState], 0
; 	jmp @@Quit

; 	; @@CheckAbove:
; 	@@LadderFound:
; 	@@Quit:
; 		pop si
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp CheckEndClimb


; proc CheckIsReadyToClimb
; 	push ax
; 	push bx
; 	push dx
; 	push si
	
; 	xor si, si
; 	xor bx, bx
; 	@@Column:
; 		xor bx, bx
; 		@@Row:

; 		mov al, [LastDkPos + bx + si]

; 		cmp al, [LadderColor]
; 		jne @@NoBackGound
; 		jmp @@FoundColor

; 		@@NoBackGound:
; 			inc bx
; 			cmp bl, [DkWidth]
; 			jne @@Row

; 	xor bx, bx
; 	mov bl, [DkWidth]
; 	add si, bx
; 	mov bx, [DkArea]
; 	cmp si, bx
; 	jne @@Column

; 	mov [IsReadyToClimb], 0
; 	jmp @@Quit


; 	@@FoundColor:
; 		call CheckOnFloor
; 		cmp al, 1
; 		jne @@Quit
; 		mov [IsReadyToClimb], 1
	

; 	@@Quit:
; 		pop si
; 		pop dx
; 		pop bx
; 		pop ax
; 		ret
; endp CheckIsReadyToClimb


; proc IsStandingOnLadder
; 	push bx
; 	push cx
; 	push dx

; 	xor cx, cx
; 	mov cl, [DkHeight]
; 	mov bx, [DkTopPointY]
; 	add bx, cx
	
; 	mov dx, [DkTopPointX]
; 	mov cl, [DkWidth]
; 	@@FindLadder:
; 		push dx
; 		push bx
; 		call GetPixelColor

; 		cmp al, [LadderColor]
; 		je @@FoundLadder

; 		inc dx
; 	loop @@FindLadder


; 	mov ax, 0
; 	jmp @@Quit

; 	@@FoundLadder:
; 		mov ax, 1

; 	@@Quit:
; 		pop dx
; 		pop cx
; 		pop bx
; 		ret
; endp IsStandingOnLadder


; proc CheckOnFloor
; 	push cx

; 	xor ax, ax
; 	mov al, [DkHeight]

; 	mov cx, [DkTopPointY]
; 	add cx, ax

; 	push [DkTopPointX]
; 	push cx
; 	call GetPixelColor

; 	cmp al, [FloorColor]
; 	je @@True

; 	; False -> Check the right corner
; 	xor cx, cx
; 	mov cl, [DkWidth]

; 	mov ax, [DkTopPointX]
; 	add ax, cx

; 	push ax
; 	xor ax, ax
; 	mov al, [DkHeight]

; 	mov cx, [DkTopPointY]
; 	add cx, ax

; 	pop ax

; 	push ax
; 	push cx
; 	call GetPixelColor

; 	cmp al, [FloorColor]
; 	je @@True

; 	; Only if both corners are false
; 	mov ax, 0
; 	jmp @@Quit

; 	@@True:
; 		mov ax, 1

; 	@@Quit:
; 		pop cx
; 		ret
; endp CheckOnFloor


; proc DkJump near
; 	push ax
; 	push bx
; 	push cx
; 	push es

; 	mov ax, 40h
; 	mov es, ax

; 	mov ax, [Clock]

; 	cmp ax, [LastJump]
; 	je @@OnAir
; 	mov [LastJump], ax

; 	cmp [DkJumpCounter], 7
; 	je @@StopJump

; 	call MoveDkPixelUp
; 	call MoveDkPixelUp
; 	inc [DkJumpCounter]
; 	jmp @@OnAir

; 	@@StopJump:
; 		mov [DkJumpState], 0
; 		mov [DkJumpCounter], 0

; 	@@OnAir:
; 		pop es
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp DkJump


; proc DkFalling near
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push es
	
; 	mov ax, 40h
; 	mov es, ax

; 	mov ax, [Clock]

; 	cmp ax, [LastFall]
; 	je @@OnFloor
; 	mov [LastFall], ax

; 	xor dx, dx
; 	mov dl, [DkHeight]

; 	mov bx, 2
; 	@@Fall:
; 		xor dx, dx
; 		mov dl, [DkHeight]

; 		mov cx, [DkTopPointY]
; 		add cx, dx

; 		push [DkTopPointX]
; 		push cx
; 		call GetPixelColor

; 		cmp al, [FloorColor]
; 		je @@OnFloor

; 		xor dx, dx
; 		mov dl, [DkWidth]
; 		dec dx

; 		mov ax, [DkTopPointX]
; 		add ax, dx
; 		push ax
; 		push cx
; 		call GetPixelColor

; 		cmp al, [FloorColor]
; 		je @@OnFloor

; 		call IsStandingOnLadder
; 		cmp al, 1
; 		je @@OnFloor

		
; 		; cmp al, [LadderColor]
; 		; je @@OnFloor

; 		call MoveDkPixelDown

; 	dec bx
; 	cmp bx, 0
; 	jne @@Fall


; 	@@OnFloor:
; 		pop es
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp DkFalling


; proc CheckStairs near
; 	push ax
; 	push bx
; 	push cx

; 	cmp [ButtonPressed], "L"
; 	je @@Left

; 	cmp [ButtonPressed], "R"
; 	je @@Right

; 	jmp @@Quit

; 	@@Left:
; 		xor bx, bx
; 		mov bl, [DkHeight]
; 		dec bx

; 		mov cx, [DkTopPointX]
; 		dec cx
; 		push cx
; 		mov ax, [DkTopPointY]
; 		add ax, bx
; 		push ax
; 		call GetPixelColor
		
; 		cmp al, [FloorColor]
; 		jne @@Quit

; 		call MoveDkPixelUp
; 		call MoveDkPixelUp
; 		jmp @@Quit

; 	@@Right:
; 		xor bx, bx
; 		mov bl, [DkWidth]
; 		dec bx

; 		mov cx, [DkTopPointX]
; 		add cx, bx
; 		push cx

; 		mov bl, [DkHeight]
; 		dec bx

; 		mov ax, [DkTopPointY]
; 		add ax, bx
; 		push ax
; 		call GetPixelColor

; 		cmp al, [FloorColor]
; 		jne @@Quit

; 		call MoveDkPixelUp
; 		call MoveDkPixelUp
; 		jmp @@Quit

; 	@@Quit:
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp CheckStairs


; proc DkPhysics near

; 	push [DkTopPointX]
; 	mov ax, [DkTopPointY]
; 	add ax, 17
; 	push ax
; 	call GetPixelColor
; 	cmp al, [FloorColor]
; 	je @@OnFloor



; 	@@OnFloor:
; 		ret
; endp DkPhysics