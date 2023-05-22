IDEAL

MODEL small
STACK 150h


DATASEG

	; 1 -> Standing Right
	; 2 -> Standing Left
	; 3 -> Walking Right
	; 4 -> Walking Left
	; 5 -> Jumping Rihgt
	; 6 -> Jumping Left
	; 7 -> Climbing Right
	; 8 -> Climbing Left
    MarioPath db "../images/mario/"
	MarioFileName db "mario1.bmp", 0

	LastMarioPos 	db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)

	MarioMatrix 	db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
					db 16 dup (0)
 
	MarioFileHandle	dw ?
	MarioHeader db 54 dup(0)

	; Mario image data
	CurrentMarioImage dw "1"
	LastMarioImage dw "1"
	MarioWidth db 12
	MarioHeight db 16
	MarioArea dw 192

CODESEG


Image equ [bp + 4]
proc ChangeMarioImage
	push bp
	mov bp, sp
	push ax
	push dx
	
	mov ax, Image
	mov [MarioFileName + 5], al

	mov dx, offset MarioPath
	mov ax, [MarioTopPointX]
	mov [BmpLeft], ax
	mov ax, [MarioTopPointY]
	mov [BmpTop], ax
	xor ax, ax
	mov al, [MarioWidth]
	mov [BmpColSize], ax
	mov al, [MarioHeight]
	mov [BmpRowSize], ax
	call OpenShowMarioBmp

	call RemoveMarioBackground

	pop dx
	pop ax
	pop bp
	ret 2
endp ChangeMarioImage


Image equ [bp + 4]
proc ChangeMarioData
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	mov ax, Image

	cmp ax, "1"
	je @@Standing

	cmp ax, "2"
	je @@Standing

	cmp ax, "3"
	je @@Walking

	cmp ax, "4"
	je @@Walking
	
	cmp ax, "5"
	je @@Jumping
	
	cmp ax, "6"
	je @@Jumping
	
	cmp ax, "7"
	je @@Climbing
	
	cmp ax, "8"
	je @@Climbing

	jmp @@Quit

	@@Standing:
		mov [MarioWidth], 12
		mov	[MarioHeight], 16
		mov	[MarioArea], 192

		jmp @@Quit

	@@Walking:
		mov [MarioWidth], 15
		mov	[MarioHeight], 16
		mov	[MarioArea], 240

		jmp @@Quit
	
	@@Jumping:
		mov [MarioWidth], 16
		mov	[MarioHeight], 16
		mov	[MarioArea], 256

		jmp @@Quit
	
	@@Climbing:
		mov [MarioWidth], 13
		mov	[MarioHeight], 16
		mov	[MarioArea], 208

		jmp @@Quit


	@@Quit:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp ChangeMarioData


proc UpdateMarioImage
	push ax
	push bx
	push cx
	push dx

	mov ax, [CurrentMarioImage]
	mov [LastMarioImage], ax

	
	cmp [IsJumping], 1
	je @@Jumping
	
	cmp [IsJumping], 2
	je @@ReturnFromJump
	
	cmp [MarioClimbState], 1
	jne @@NotUp
	jmp @@Climbing

	@@NotUp:

	cmp [ButtonPressed], "L"
	je @@Walking
	
	cmp [ButtonPressed], "R"
	je @@Walking

	jmp @@Quit

	@@Standing:
		cmp [LastButtonPressed], "L"
		je @@StandingLeft
		cmp [CurrentMarioImage], "4"
		je @@StandingLeft
		
		cmp [LastButtonPressed], "R"
		je @@StandingRight
		
		jmp @@Quit

		@@ReturnFromJump:
			cmp [CurrentMarioImage], "6"
			je @@StandingLeft
			
			cmp [CurrentMarioImage], "5"
			je @@StandingRight

			jmp @@Quit

		@@StandingLeft:
			mov [CurrentMarioImage], "2"
			jmp @@Quit

		@@StandingRight:
			mov [CurrentMarioImage], "1"
			jmp @@Quit


	@@Jumping:
		mov ax, [CurrentMarioImage]

		cmp ax, "2"
		je @@JumpingLeft
		
		cmp ax, "1"
		je @@JumpingRight
		
		cmp ax, "6"
		je @@JumpingLeft
		
		cmp ax, "5"
		je @@JumpingRight

		@@JumpingLeft:
			mov [CurrentMarioImage], "6"
			jmp @@Quit

		@@JumpingRight:
			mov [CurrentMarioImage], "5"
			jmp @@Quit


	@@Walking:
		mov ax, [CurrentMarioImage]
		cmp [LastMarioImage], ax
		je @@WalkingAnimation

		cmp [ButtonPressed], "L"
		je @@StandingLeft
		
		cmp [ButtonPressed], "R"
		je @@StandingRight


		@@WalkingAnimation:
			cmp [MarioTopPointX], 65
			jne @@CheckRight

			jmp @@Quit

			@@CheckRight:
				cmp [MarioTopPointX], 249
				jnge @@CheckTimer

			jmp @@Quit

			@@CheckTimer:

			push 1
			Call GetTime

			cmp al, 5
			jge @@Animation
			jmp @@Quit


			@@Animation:

			push 1
			call StopTimer
			push 1
			call ResetTimer
			push 1
			call StartTimer

			cmp [ButtonPressed], "L"
			je @@WalkingAnimationLeft
			
			cmp [ButtonPressed], "R"
			je @@WalkingAnimationRight

			@@WalkingAnimationLeft:
				cmp [CurrentMarioImage], "2"
				je @@SwitchLeft

				mov [CurrentMarioImage], "2"
				jmp @@Quit

				@@SwitchLeft:
					mov [CurrentMarioImage], "4" ; 4
					jmp @@Quit


			@@WalkingAnimationRight:
				cmp [CurrentMarioImage], "1"
				je @@SwitchRight

				mov [CurrentMarioImage], "1"
				jmp @@Quit

				@@SwitchRight:
					mov [CurrentMarioImage], "3" ; 3
					jmp @@Quit

	@@Climbing:
		cmp [ButtonPressed], "U"
		je @@ClimbingAnimation
		cmp [ButtonPressed], "D"
		je @@ClimbingAnimation

		jmp @@Quit

		@@ClimbingAnimation:
		push 1
		Call GetTime

		cmp al, 15
		jb @@Quit

		push 1
		call StopTimer
		push 1
		call ResetTimer
		push 1
		call StartTimer

		cmp [CurrentMarioImage], "7"
		je @@SwitchClimb

		mov [CurrentMarioImage], "7"
		jmp @@Quit

		@@SwitchClimb:
			mov [CurrentMarioImage], "8"
			jmp @@Quit



	@@Quit:
		mov ax, [LastMarioImage]
		cmp [CurrentMarioImage], ax
		je @@Resume

		call RefreshMario

		cmp [LastMarioImage], "5"
		je @@ShowMario

		cmp [LastMarioImage], "6"
		je @@ShowMario
		
		cmp [LastMarioImage], "7"
		je @@ShowMario
		
		cmp [LastMarioImage], "8"
		je @@ShowMario
		
		jmp @@Resume

		@@ShowMario:
			push [CurrentMarioImage]
			call ChangeMarioImage

		@@Resume:
			pop dx
			pop cx
			pop bx
			pop ax
			ret
endp UpdateMarioImage


proc RefreshMario
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	call CloseMarioBmpFile

	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [MarioWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [MarioHeight]  ;number of rows
	call putMatrixInScreen

	push [CurrentMarioImage]
	call ChangeMarioData

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

	call CheckOnFloor

	; push [CurrentMarioImage]
	; call ChangeMarioImage

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RefreshMario


proc RemoveMarioBackground
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	xor si, si
	xor bx, bx
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

		cmp al, 0
		jne @@NoBackGound

		mov al, [LastMarioPos + si]

		@@NoBackGound:
			mov [MarioMatrix + si], al
			pop si
			inc bx
			cmp bl, [MarioWidth]
			jne @@Row

	xor bx, bx
	mov bl, [MarioHeight]
	inc si
	cmp si, bx
	jne @@Column

	xor ax, ax
	xor bx, bx
	mov al, [MarioWidth]
	mov bl, [MarioHeight]

	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [MarioMatrix] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, ax   ; number of cols  
	mov cx, bx  ;number of rows
	call putMatrixInScreen


	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RemoveMarioBackground


proc MoveMarioPixelLeft
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [MarioWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [MarioHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor cx, cx
	xor ax, ax
	mov al, [MarioWidth]
	inc ax
	mov cl, [MarioHeight]
	@@MovMatrixRight2D:
		mov dx, bx
		dec dx
		add bl, [MarioWidth]
		sub bx, 2
		@@MovMatrixRight1D:
			mov al, [LastMarioPos + bx]
			mov [LastMarioPos + bx + 1], al
			dec bx
			cmp bx, dx
			jne @@MovMatrixRight1D

		; add bx, MarioWidth + 1
		xor ax, ax
		mov al, [MarioWidth]
		add ax, 1
		add bx, ax
	loop @@MovMatrixRight2D

	mov cx, [MarioTopPointX]
	dec cx

	xor bx, bx
	mov bl, [MarioHeight]
	xor si, si
	@@GetLeftPixels:

		push cx
		mov ax, [MarioTopPointY]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov al, [MarioWidth]
		mul dl
		mov si, ax
		pop ax

		mov [LastMarioPos + si], al
		pop si
		inc si
		cmp si, bx
		jne @@GetLeftPixels
	
	dec [MarioTopPointX]
	push [CurrentMarioImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioPixelLeft


proc MoveMarioPixelRight
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [MarioWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [MarioHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor dx, dx
	xor cx, cx
	mov dl, [MarioWidth]
	dec dx
	mov cl, [MarioHeight]
	@@MovMatrixLeft2D:
		@@MovMatrixLeft1D:
			mov al, [LastMarioPos + bx + 1]
			mov [LastMarioPos + bx], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixLeft1D

		; add dx, MarioWidth
		xor ax, ax
		mov al, [MarioWidth]
		add dx, ax

		add bx, 1
	loop @@MovMatrixLeft2D

	mov cx, [MarioTopPointX]
	; add cx, MarioWidth
	mov al, [MarioWidth]
	@@AddCxMarioWidth:
		inc cx
		dec al
		jnz @@AddCxMarioWidth


	xor bx, bx
	mov bl, [MarioWidth]
	dec bx
	xor si, si
	@@GetRightPixels:

		push cx
		mov ax, [MarioTopPointY]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov al, [MarioWidth]
		mul dl
		mov si, ax
		pop ax

		mov [LastMarioPos + si + bx], al
		pop si
		inc si
		xor dx, dx
		mov dl, [MarioHeight]
		cmp si, dx
		jne @@GetRightPixels
	
	inc [MarioTopPointX]
	push [CurrentMarioImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioPixelRight


proc MoveMarioPixelDown
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [MarioWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [MarioHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor dx, dx
	xor cx, cx
	mov cl, [MarioWidth]
	mov si, cx
	mov ax, [MarioArea]
	sub ax, si
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			push ax
			mov al, [LastMarioPos + bx + si]
			mov [LastMarioPos + bx], al
			add bx, si
			pop ax
			cmp bx, ax
			jb @@MovMatrixUp1D
		inc dx
		mov bx, dx
	loop @@MovMatrixUp2D

	xor ax, ax

	mov al, [MarioHeight]
	mov cx, [MarioTopPointY]
	add cx, ax

	mov dx, [MarioArea]
	mov al, [MarioWidth]
	sub dx, ax

	xor si, si
	@@GetDownPixels:

		mov ax, [MarioTopPointX]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		push si
		add si, dx

		mov [LastMarioPos + si], al
		pop si
		inc si

		xor ax, ax
		mov al, [MarioWidth]

		cmp si, ax
		jne @@GetDownPixels

	inc [MarioTopPointY]
	push [CurrentMarioImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioPixelDown


proc MoveMarioPixelUp
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [MarioWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [MarioHeight]  ;number of rows
	call putMatrixInScreen


	xor ax, ax
	mov al, [MarioWidth]
	mov si, ax

	mov dx, [MarioArea]
	sub dx, ax
	mov bx, dx
	sub bx, ax

	xor cx, cx
	mov cl, [MarioHeight]
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			mov al, [LastMarioPos + bx]
			mov [LastMarioPos + bx + si], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixUp1D
		mov dx, bx
		sub bx, si
		sub bx, si
		sub dx, si
	loop @@MovMatrixUp2D



	xor dx, dx
	mov dl, [MarioWidth]

	mov cx, [MarioTopPointY]
	dec cx
	xor si, si
	@@GetUpPixels:

		mov ax, [MarioTopPointX]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		mov [LastMarioPos + si], al
		inc si
		cmp si, dx
		jne @@GetUpPixels

	dec [MarioTopPointY]
	push [CurrentMarioImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioPixelUp


proc CloseMarioBmpFile
	mov ah,3Eh
	mov bx, [MarioFileHandle]
	int 21h
	ret
endp CloseMarioBmpFile


proc OpenShowMarioBmp

	call OpenBmpMarioFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadMarioBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseMarioBmpFile

	@@ExitProc:
		ret
endp OpenShowMarioBmp


; input dx MarioPath to open
proc OpenBmpMarioFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [MarioFileHandle], ax
	jmp @@ExitProc
	
	@@ErrorAtOpen:
		mov [ErrorFile],1
	@@ExitProc:	
		ret
endp OpenBmpMarioFile


; Read 54 bytes the Header
proc ReadMarioBmpHeader					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [MarioFileHandle]
	mov cx,54
	mov dx,offset MarioHeader
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadMarioBmpHeader