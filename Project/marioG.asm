IDEAL

MODEL small
STACK 256


DATASEG

	; 1 -> Standing Right
	; 2 -> Standing Left
	; 3 -> Walking Right
	; 4 -> Walking Left
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

	LastAnimation dw ?

	; Mario image data
	CurrentImage dw "1"
	LastImage dw "1"
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

	mov dx, offset MarioFileName
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
	je @@One

	cmp ax, "2"
	je @@Two

	cmp ax, "3"
	je @@Three

	cmp ax, "4"
	je @@Four
	
	cmp ax, "5"
	je @@Five
	
	cmp ax, "6"
	je @@Six

	jmp @@Quit

	@@One:
		mov [MarioWidth], 12
		mov	[MarioHeight], 16
		mov	[MarioArea], 192

		jmp @@Quit
	
	@@Two:
		mov [MarioWidth], 12
		mov	[MarioHeight], 16
		mov	[MarioArea], 192

		jmp @@Quit

	@@Three:
		mov [MarioWidth], 15
		mov	[MarioHeight], 16
		mov	[MarioArea], 240

		jmp @@Quit

	@@Four:
		mov [MarioWidth], 15
		mov	[MarioHeight], 16
		mov	[MarioArea], 240

		jmp @@Quit
	
	@@Five:
		mov [MarioWidth], 16
		mov	[MarioHeight], 16
		mov	[MarioArea], 256

		jmp @@Quit
	
	@@Six:
		mov [MarioWidth], 16
		mov	[MarioHeight], 16
		mov	[MarioArea], 256

		jmp @@Quit


	@@Quit:
		pop dx
		pop si
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
	push es

	mov ax, [CurrentImage]
	mov [lastImage], ax
	mov ax, [CurrentImage]

	
	cmp [IsJumping], 1
	je @@Jumping

	cmp [ButtonPressed], "L"
	je @@Walking
	
	cmp [ButtonPressed], "R"
	je @@Walking
	
	cmp [ButtonPressed], 0
	je @@Standing


	@@Standing:
		cmp [LastButtonPressed], "L"
		je @@StandingLeft
		
		cmp [LastButtonPressed], "R"
		je @@StandingRight

		@@ReturnFromJump:
			cmp [CurrentImage], "6"
			je @@StandingLeft
			
			cmp [CurrentImage], "5"
			je @@StandingRight

			jmp @@Quit

		@@StandingLeft:
			mov [CurrentImage], "2"
			jmp @@Quit

		@@StandingRight:
			mov [CurrentImage], "1"
			jmp @@Quit


	@@Jumping:
		mov ax, [CurrentImage]

		cmp ax, "2"
		je @@JumpingLeft
		
		cmp ax, "1"
		je @@JumpingRight
		
		cmp ax, "6"
		je @@JumpingLeft
		
		cmp ax, "5"
		je @@JumpingRight

		@@JumpingLeft:
			mov [CurrentImage], "6"
			jmp @@Quit

		@@JumpingRight:
			mov [CurrentImage], "5"
			jmp @@Quit


	@@Walking:
		mov al, [LastButtonPressed]
		cmp [ButtonPressed], al
		je @@WalkingAnimation

		cmp [ButtonPressed], "L"
		je @@StandingLeft
		
		cmp [ButtonPressed], "R"
		je @@StandingRight


		@@WalkingAnimation:
			mov ax, 40h
			mov es, ax

			mov ax, [Clock]

			cmp ax, [LastAnimation]
			je @@Quit
			mov [LastAnimation], ax
	
			cmp [ButtonPressed], "L"
			je @@WalkingAnimationLeft
			
			cmp [ButtonPressed], "R"
			je @@WalkingAnimationRight

			@@WalkingAnimationLeft:

				cmp [CurrentImage], "2"
				je @@SwitchLeft

				mov [CurrentImage], "2"
				jmp @@Quit

				@@SwitchLeft:
					mov [CurrentImage], "2" ; 4
					jmp @@Quit


			@@WalkingAnimationRight:
				cmp [CurrentImage], "1"
				je @@SwitchRight

				mov [CurrentImage], "1"
				jmp @@Quit

				@@SwitchRight:
					mov [CurrentImage], "1" ; 3
					jmp @@Quit


	@@Quit:
		mov ax, [LastImage]
		cmp [CurrentImage], ax
		je @@Resume

		call RefreshMario

		cmp [LastImage], "5"
		je @@ShowMario

		cmp [LastImage], "6"
		je @@ShowMario
		
		jmp @@Resume

		@@ShowMario:
			push [CurrentImage]
			call ChangeMarioImage

		@@Resume:
			pop es
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

	push [CurrentImage]
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

	call CheckJump

	; push [CurrentImage]
	; call ChangeMarioImage

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
	push es
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
	pop es
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
	push es
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
	push [CurrentImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop es
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
	push es
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
	push [CurrentImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop es
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
	push es
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
			jl @@MovMatrixUp1D
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
	push [CurrentImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop es
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
	push es
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
	; mov cx, [MarioTopPointY]
	; dec cx
	; xor si, si
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
	
	; mov dx, offset MarioFileName
	; mov ax, [MarioTopPointX]
	; mov [BmpLeft], ax
	; mov ax, [MarioTopPointY]
	; dec ax
	; mov [BmpTop], ax
	; mov [BmpColSize], 12
	; mov [BmpRowSize], 16
	; call OpenShowMarioBmp

	dec [MarioTopPointY]
	push [CurrentImage]
	call ChangeMarioImage

	@@Quit:
		pop di
		pop es
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