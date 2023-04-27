IDEAL

MODEL small
STACK 256

Clock equ es:6Ch

DATASEG

	MarioFileName db "mario1.bmp", 0

	LastMarioPos 	db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)

	MarioMatrix 	db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)
					db 12 dup (0)

	MarioTopPointX dw ?
	MarioTopPointY dw ?

	LastFall dw 0
 
	MarioFileHandle	dw ?
	MarioHeader db 54 dup(0)

	IsInit db 0

	CurrentDirection db 0

	key  db 48h,50h,4dh,4bh
    arrow db "UDRL"

	MarioJumpState db 0
	MarioJumpCounter db 0

CODESEG


proc InitMario
	push ax
	push bx
	push dx
	push si
	
	mov [MarioTopPointX], 61
	mov [MarioTopPointY], 170

	xor si, si
	xor bx, bx
	@@Column:
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
		mov al, 12
		mul dl
		add ax, bx
		mov si, ax
		pop ax

		mov [LastMarioPos + si], al
		pop si
		inc bx
		cmp bx, 12
		jne @@Row
	
	xor bx, bx
	inc si
	cmp si, 16
	jne @@Column

	mov dx, offset MarioFileName
	mov [BmpLeft], 61
	mov [BmpTop], 170
	mov [BmpColSize], 12
	mov [BmpRowSize], 16

	call OpenShowMarioBmp
	call RemoveMarioBackground

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
		call DetectDirection

		cmp [MarioJumpState], 1
		je @@Jump

		call MarioFalling
		jmp @@Resume

		@@Jump:
			call MarioJump

		@@Resume:
		cmp [CurrentDirection], "L"
		je @@Left
		cmp [CurrentDirection], "R"
		je @@Right
		cmp [CurrentDirection], "U"
		je @@Up

		jmp @@Quit

		@@Left:
			cmp [MarioFileName + 5], "2"
			je @@CorrectImage1
			

			call CloseMarioBmpFile
			mov [MarioFileName + 5], "2"
			
			mov dx, offset MarioFileName
			mov ax, [MarioTopPointX]
			mov [BmpLeft], ax
			mov ax, [MarioTopPointY]
			mov [BmpTop], ax
			mov [BmpColSize], 12
			mov [BmpRowSize], 16
			call OpenShowMarioBmp


			@@CorrectImage1:
				call CheckStairs
				call MoveMarioLeft
				; call MoveMarioLeft
				jmp @@Quit

		@@Right:
			cmp [MarioFileName + 5], "1"
			je @@CorrectImage2


			call CloseMarioBmpFile
			mov [MarioFileName + 5], "1"

			mov dx, offset MarioFileName
			mov ax, [MarioTopPointX]
			mov [BmpLeft], ax
			mov ax, [MarioTopPointY]
			mov [BmpTop], ax
			mov [BmpColSize], 12
			mov [BmpRowSize], 16
			call OpenShowMarioBmp

			@@CorrectImage2:
				call CheckStairs
				call MoveMarioRight
				; call MoveMarioRight
				jmp @@Quit

		@@Up:
			push ax

			call CheckJump
			cmp ax, 1
			jne @@DontJump
				mov [MarioJumpState], 1

			@@DontJump:
				pop ax



	jmp @@Quit

	@@RemoveMario:
		mov [IsInit], 0
		call CloseMarioBmpFile

	@@Quit:
		ret
endp UpdateMario


proc DetectDirection
	push ax
	push bx
	push cx


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

	cmp ax, 11bh
	jne @@CheckArrows

	mov [SelectedScreen], 3
	call SwitchScreen
	call UpdateBackgourndImage

	jmp @@Quit


	@@CheckArrows:
		mov al, ah
		mov bx, -1
		@@FindDirection:
			cmp bx, 5
			je @@NotPressed
			inc bx 
			cmp al, [key + bx] 
			jne @@FindDirection 

		mov al, [arrow + bx]
		mov [CurrentDirection], al
		jmp @@Quit

	@@NotPressed:
		mov [CurrentDirection], 0

	@@Quit:
		pop cx
		pop bx
		pop ax
		ret
endp DetectDirection


proc RemoveMarioBackground
	push ax
	push bx
	push cx
	push dx
	push si
	push es
	push di

	xor si, si
	xor bx, bx
	@@Column:
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
		mov al, 12
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
			cmp bx, 12
			jne @@Row

	xor bx, bx
	inc si
	cmp si, 16
	jne @@Column


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [MarioMatrix] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, 12   ; number of cols  
	mov cx, 16  ;number of rows
	call putMatrixInScreen


	pop di
	pop es
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RemoveMarioBackground


proc CheckJump
	push cx

	xor ax, ax

	mov cx, [MarioTopPointY]
	add cx, 16

	push [MarioTopPointX]
	push cx
	call GetPixelColor

	cmp al, [FloorColor]
	je @@True

	; False -> Check the right corner
	mov ax, [MarioTopPointX]
	add ax, 12

	mov cx, [MarioTopPointY]
	add cx, 16

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


proc MarioJump
	push ax
	push bx
	push cx

	cmp [MarioJumpCounter], 15
	je @@StopJump

	call MoveMarioUp
	inc [MarioJumpCounter]
	jmp @@OnAir

	@@StopJump:
		mov [MarioJumpState], 0
		mov [MarioJumpCounter], 0

	@@OnAir:
		pop cx
		pop bx
		pop ax
		ret
endp MarioJump


proc MoveMarioLeft
	push ax
	push bx
	push cx
	push dx
	push si
	push es
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, 12   ; number of cols  
	mov cx, 16  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	mov cx, 16
	@@MovMatrixRight2D:
		mov dx, bx
		dec dx
		add bx, 10
		@@MovMatrixRight1D:
			mov al, [LastMarioPos + bx]
			mov [LastMarioPos + bx + 1], al
			dec bx
			cmp bx, dx
			jne @@MovMatrixRight1D
		add bx, 13
	loop @@MovMatrixRight2D

	mov cx, [MarioTopPointX]
	dec cx

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
		mov al, 12
		mul dl
		mov si, ax
		pop ax

		mov [LastMarioPos + si], al
		pop si
		inc si
		cmp si, 16
		jne @@GetLeftPixels
	
	mov dx, offset MarioFileName
	mov ax, [MarioTopPointX]
	dec ax
	mov [BmpLeft], ax
	mov ax, [MarioTopPointY]
	mov [BmpTop], ax
	mov [BmpColSize], 12
	mov [BmpRowSize], 16
	call OpenShowMarioBmp
	
	dec [MarioTopPointX]

	call RemoveMarioBackground

	@@Quit:
		pop di
		pop es
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioLeft


proc MoveMarioRight
	push ax
	push bx
	push cx
	push dx
	push si
	push es
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, 12   ; number of cols  
	mov cx, 16  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	mov dx, 11
	mov cx, 16
	@@MovMatrixLeft2D:
		@@MovMatrixLeft1D:
			mov al, [LastMarioPos + bx + 1]
			mov [LastMarioPos + bx], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixLeft1D
		add dx, 12
		add bx, 1
	loop @@MovMatrixLeft2D

	mov cx, [MarioTopPointX]
	add cx, 12
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
		mov al, 12
		mul dl
		mov si, ax
		pop ax

		mov [LastMarioPos + si + 11], al
		pop si
		inc si
		cmp si, 16
		jne @@GetRightPixels
	
	mov dx, offset MarioFileName
	mov ax, [MarioTopPointX]
	inc ax
	mov [BmpLeft], ax
	mov ax, [MarioTopPointY]
	mov [BmpTop], ax
	mov [BmpColSize], 12
	mov [BmpRowSize], 16
	call OpenShowMarioBmp

	inc [MarioTopPointX]

	call RemoveMarioBackground

	@@Quit:
		pop di
		pop es
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioRight


proc MoveMarioDown
	push ax
	push bx
	push cx
	push dx
	push si
	push es
	push di


	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, 12   ; number of cols  
	mov cx, 16  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor dx, dx
	mov cx, 12
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			mov al, [LastMarioPos + bx + 12]
			mov [LastMarioPos + bx], al
			add bx, 12
			cmp bx, 180
			jl @@MovMatrixUp1D
		inc dx
		mov bx, dx
	loop @@MovMatrixUp2D

	mov cx, [MarioTopPointY]
	add cx, 16
	xor si, si
	@@GetDownPixels:

		mov ax, [MarioTopPointX]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		push si
		add si, 180

		mov [LastMarioPos + si], al
		pop si
		inc si
		cmp si, 12
		jne @@GetDownPixels
	
	mov dx, offset MarioFileName
	mov ax, [MarioTopPointX]
	mov [BmpLeft], ax
	mov ax, [MarioTopPointY]
	inc ax
	mov [BmpTop], ax
	mov [BmpColSize], 12
	mov [BmpRowSize], 16
	call OpenShowMarioBmp

	inc [MarioTopPointY]

	call RemoveMarioBackground

	@@Quit:
		pop di
		pop es
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioDown


proc MoveMarioUp
	push ax
	push bx
	push cx
	push dx
	push si
	push es
	push di

	push [MarioTopPointX]
	push [MarioTopPointY]
	call ConvertMatrixPos
	lea cx, [LastMarioPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	mov dx, 12   ; number of cols  
	mov cx, 16  ;number of rows
	call putMatrixInScreen

	mov bx, 168
	mov dx, 180
	mov cx, 16
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			mov al, [LastMarioPos + bx]
			mov [LastMarioPos + bx + 12], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixUp1D
		mov dx, bx
		sub bx, 24
		sub dx, 12
	loop @@MovMatrixUp2D

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
		cmp si, 12
		jne @@GetUpPixels
	
	mov dx, offset MarioFileName
	mov ax, [MarioTopPointX]
	mov [BmpLeft], ax
	mov ax, [MarioTopPointY]
	dec ax
	mov [BmpTop], ax
	mov [BmpColSize], 12
	mov [BmpRowSize], 16
	call OpenShowMarioBmp

	dec [MarioTopPointY]

	call RemoveMarioBackground

	@@Quit:
		pop di
		pop es
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveMarioUp


proc MarioFalling near
	push ax
	push bx
	push cx
	push es
	
	mov ax, 40h
	mov es, ax

	mov ax, [Clock]

	cmp ax, [LastFall]
	je @@OnFloor
	mov [LastFall], ax

	mov bx, 2
	@@Fall:
		mov cx, [MarioTopPointY]
		add cx, 16

		push [MarioTopPointX]
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		mov ax, [MarioTopPointX]
		add ax, 11
		push ax
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		call MoveMarioDown

	dec bx
	cmp bx, 0
	jne @@Fall


	@@OnFloor:
		pop es
		pop cx
		pop bx
		pop ax
		ret
endp MarioFalling


proc CheckStairs near
	push ax
	push cx

	cmp [CurrentDirection], "L"
	je @@Left

	cmp [CurrentDirection], "R"
	je @@Right

	jmp @@Quit

	@@Left:
		mov cx, [MarioTopPointX]
		dec cx
		push cx
		mov ax, [MarioTopPointY]
		add ax, 15
		push ax
		call GetPixelColor
		
		cmp al, [FloorColor]
		jne @@Quit

		call MoveMarioUp
		call MoveMarioUp
		jmp @@Quit

	@@Right:
		mov cx, [MarioTopPointX]
		add cx, 12
		push cx
		mov ax, [MarioTopPointY]
		add ax, 15
		push ax
		call GetPixelColor

		cmp al, [FloorColor]
		jne @@Quit

		call MoveMarioUp
		call MoveMarioUp
		jmp @@Quit

	@@Quit:
		pop cx
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



; input dx MarioFileName to open
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