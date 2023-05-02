IDEAL

MODEL small
STACK 90


DATASEG

	; 1 -> Standing Right
	; 2 -> Standing Left
	; 3 -> Walking Right
	; 4 -> Walking Left
	; 5 -> Jumping Rihgt
	; 6 -> Jumping Left
	; 7 -> Climbing Right
	; 8 -> Climbing Left
	DkFileName db "dk1.bmp", 0

	LastDkPos 		db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)

	DkMatrix 		db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
					db 40 dup (0)
 
	DkFileHandle	dw ?
	DkHeader db 120 dup(0)

	; Dk image data
	CurrentDkImage dw "1"
	LastDkImage dw "1"
	DkWidth db 40
	DkHeight db 32
	DkArea dw 1280

	; IsWalking db 1

CODESEG

Image equ [bp + 4]
proc ChangeDkImage
	push bp
	mov bp, sp
	push ax
	push dx
	
	mov ax, Image
	mov [DkFileName + 2], al

	mov dx, offset DkFileName
	mov ax, [DkTopPointX]
	mov [BmpLeft], ax
	mov ax, [DkTopPointY]
	mov [BmpTop], ax
	xor ax, ax
	mov al, [DkWidth]
	mov [BmpColSize], ax
	mov al, [DkHeight]
	mov [BmpRowSize], ax
	call OpenShowDkBmp

	call RemoveDkBackground

	pop dx
	pop ax
	pop bp
	ret 2
endp ChangeDkImage

Image equ [bp + 4]
proc ChangeDkData
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

	; cmp ax, "2"
	; je @@Standing

	; cmp ax, "3"
	; je @@Walking

	; cmp ax, "4"
	; je @@Walking
	
	; cmp ax, "5"
	; je @@Jumping
	
	; cmp ax, "6"
	; je @@Jumping
	
	; cmp ax, "7"
	; je @@Climbing
	
	; cmp ax, "8"
	; je @@Climbing

	jmp @@Quit

	@@Standing:
		mov [DkWidth], 40
		mov	[DkHeight], 32
		mov	[DkArea], 1280

		jmp @@Quit

	@@Walking:
		mov [DkWidth], 15
		mov	[DkHeight], 16
		mov	[DkArea], 240

		jmp @@Quit
	
	@@Jumping:
		mov [DkWidth], 16
		mov	[DkHeight], 16
		mov	[DkArea], 256

		jmp @@Quit
	
	@@Climbing:
		mov [DkWidth], 13
		mov	[DkHeight], 16
		mov	[DkArea], 208

		jmp @@Quit


	@@Quit:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp ChangeDkData


proc UpdateDkImage
	push ax
	push bx
	push cx
	push dx

	mov ax, [CurrentDkImage]
	mov [LastDkImage], ax

	


	; cmp [IsJumping], 1
	; je @@Jumping
	
	; cmp [IsJumping], 2
	; je @@ReturnFromJump
	
	; cmp [DkClimbState], 1
	; jne @@NotUp
	; jmp @@Climbing

	; @@NotUp:

	; cmp [ButtonPressed], "L"
	; je @@Walking
	
	; cmp [ButtonPressed], "R"
	; je @@Walking
	
	; ; cmp [ButtonPressed], 0
	; ; je @@Standing


	; jmp @@Quit

	; @@Standing:
	; 	cmp [LastButtonPressed], "L"
	; 	je @@StandingLeft
		
	; 	cmp [LastButtonPressed], "R"
	; 	je @@StandingRight
		
	; 	jmp @@Quit

	; 	@@ReturnFromJump:
	; 		cmp [CurrentDkImage], "6"
	; 		je @@StandingLeft
			
	; 		cmp [CurrentDkImage], "5"
	; 		je @@StandingRight

	; 		jmp @@Quit

	; 	@@StandingLeft:
	; 		mov [CurrentDkImage], "2"
	; 		jmp @@Quit

		@@StandingRight:
			mov [CurrentDkImage], "1"
			jmp @@Quit


	; @@Jumping:
	; 	mov ax, [CurrentDkImage]

	; 	cmp ax, "2"
	; 	je @@JumpingLeft
		
	; 	cmp ax, "1"
	; 	je @@JumpingRight
		
	; 	cmp ax, "6"
	; 	je @@JumpingLeft
		
	; 	cmp ax, "5"
	; 	je @@JumpingRight

	; 	@@JumpingLeft:
	; 		mov [CurrentDkImage], "6"
	; 		jmp @@Quit

	; 	@@JumpingRight:
	; 		mov [CurrentDkImage], "5"
	; 		jmp @@Quit


	; @@Walking:
	; 	mov ax, [CurrentDkImage]
	; 	cmp [LastDkImage], ax
	; 	je @@WalkingAnimation

	; 	cmp [ButtonPressed], "L"
	; 	je @@StandingLeft
		
	; 	cmp [ButtonPressed], "R"
	; 	je @@StandingRight


	; 	@@WalkingAnimation:

	; 		push 1
	; 		Call GetTime

	; 		cmp al, 1
	; 		jge @@Animation
	; 		jmp @@Quit


	; 		@@Animation:

	; 		push 1
	; 		call StopTimer
	; 		push 1
	; 		call ResetTimer
	; 		push 1
	; 		call StartTimer

	; 		cmp [ButtonPressed], "L"
	; 		je @@WalkingAnimationLeft
			
	; 		cmp [ButtonPressed], "R"
	; 		je @@WalkingAnimationRight

	; 		@@WalkingAnimationLeft:
	; 			cmp [CurrentDkImage], "2"
	; 			je @@SwitchLeft

	; 			mov [CurrentDkImage], "2"
	; 			jmp @@Quit

	; 			@@SwitchLeft:
	; 				mov [CurrentDkImage], "4" ; 4
	; 				jmp @@Quit


	; 		@@WalkingAnimationRight:
	; 			cmp [CurrentDkImage], "1"
	; 			je @@SwitchRight

	; 			mov [CurrentDkImage], "1"
	; 			jmp @@Quit

	; 			@@SwitchRight:
	; 				mov [CurrentDkImage], "3" ; 3
	; 				jmp @@Quit

	; @@Climbing:
	; 	cmp [ButtonPressed], "U"
	; 	je @@ClimbingAnimation
	; 	cmp [ButtonPressed], "D"
	; 	je @@ClimbingAnimation

	; 	jmp @@Quit

	; 	@@ClimbingAnimation:
	; 	push 1
	; 	Call GetTime

	; 	cmp al, 1
	; 	jl @@Quit

	; 	push 1
	; 	call StopTimer
	; 	push 1
	; 	call ResetTimer
	; 	push 1
	; 	call StartTimer

	; 	cmp [CurrentDkImage], "7"
	; 	je @@SwitchClimb

	; 	mov [CurrentDkImage], "7"
	; 	jmp @@Quit

	; 	@@SwitchClimb:
	; 		mov [CurrentDkImage], "8"
	; 		jmp @@Quit



	@@Quit:
		mov ax, [LastDkImage]
		cmp [CurrentDkImage], ax
		je @@Resume

		call RefreshDk

		; cmp [LastDkImage], "5"
		; je @@ShowDk

		; cmp [LastDkImage], "6"
		; je @@ShowDk
		
		; cmp [LastDkImage], "7"
		; je @@ShowDk
		
		; cmp [LastDkImage], "8"
		; je @@ShowDk
		
		jmp @@Resume

		@@ShowDk:
			push [CurrentDkImage]
			call ChangeDkImage

		@@Resume:
			pop dx
			pop cx
			pop bx
			pop ax
			ret
endp UpdateDkImage


proc RefreshDk
	push ax
	push bx
	push cx
	push dx
	push si

	call CloseDkBmpFile

	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [LastDkPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [DkWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [DkHeight]  ;number of rows
	call putMatrixInScreen

	push [CurrentDkImage]
	call ChangeDkData

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

	call CheckOnFloor

	; push [CurrentDkImage]
	; call ChangeDkImage

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RefreshDk


proc RemoveDkBackground
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

		cmp al, 0
		jne @@NoBackGound

		mov al, [LastDkPos + si]

		@@NoBackGound:
			mov [DkMatrix + si], al
			pop si
			inc bx
			cmp bl, [DkWidth]
			jne @@Row

	xor bx, bx
	mov bl, [DkHeight]
	inc si
	cmp si, bx
	jne @@Column

	xor ax, ax
	xor bx, bx
	mov al, [DkWidth]
	mov bl, [DkHeight]

	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [DkMatrix] 
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
endp RemoveDkBackground


proc MoveDkPixelLeft
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [LastDkPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [DkWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [DkHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor cx, cx
	xor ax, ax
	mov al, [DkWidth]
	inc ax
	mov cl, [DkHeight]
	@@MovMatrixRight2D:
		mov dx, bx
		dec dx
		add bl, [DkWidth]
		sub bx, 2
		@@MovMatrixRight1D:
			mov al, [LastDkPos + bx]
			mov [LastDkPos + bx + 1], al
			dec bx
			cmp bx, dx
			jne @@MovMatrixRight1D

		; add bx, DkWidth + 1
		xor ax, ax
		mov al, [DkWidth]
		add ax, 1
		add bx, ax
	loop @@MovMatrixRight2D

	mov cx, [DkTopPointX]
	dec cx

	xor bx, bx
	mov bl, [DkHeight]
	xor si, si
	@@GetLeftPixels:

		push cx
		mov ax, [DkTopPointY]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov al, [DkWidth]
		mul dl
		mov si, ax
		pop ax

		mov [LastDkPos + si], al
		pop si
		inc si
		cmp si, bx
		jne @@GetLeftPixels
	
	dec [DkTopPointX]
	push [CurrentDkImage]
	call ChangeDkImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveDkPixelLeft


proc MoveDkPixelRight
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [LastDkPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [DkWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [DkHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor dx, dx
	xor cx, cx
	mov dl, [DkWidth]
	dec dx
	mov cl, [DkHeight]
	@@MovMatrixLeft2D:
		@@MovMatrixLeft1D:
			mov al, [LastDkPos + bx + 1]
			mov [LastDkPos + bx], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixLeft1D

		; add dx, DkWidth
		xor ax, ax
		mov al, [DkWidth]
		add dx, ax

		add bx, 1
	loop @@MovMatrixLeft2D

	mov cx, [DkTopPointX]
	; add cx, DkWidth
	mov al, [DkWidth]
	@@AddCxDkWidth:
		inc cx
		dec al
		jnz @@AddCxDkWidth


	xor bx, bx
	mov bl, [DkWidth]
	dec bx
	xor si, si
	@@GetRightPixels:

		push cx
		mov ax, [DkTopPointY]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov al, [DkWidth]
		mul dl
		mov si, ax
		pop ax

		mov [LastDkPos + si + bx], al
		pop si
		inc si
		xor dx, dx
		mov dl, [DkHeight]
		cmp si, dx
		jne @@GetRightPixels
	
	inc [DkTopPointX]
	push [CurrentDkImage]
	call ChangeDkImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveDkPixelRight


proc MoveDkPixelDown
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [LastDkPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [DkWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [DkHeight]  ;number of rows
	call putMatrixInScreen

	xor bx, bx
	xor dx, dx
	xor cx, cx
	mov cl, [DkWidth]
	mov si, cx
	mov ax, [DkArea]
	sub ax, si
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			push ax
			mov al, [LastDkPos + bx + si]
			mov [LastDkPos + bx], al
			add bx, si
			pop ax
			cmp bx, ax
			jl @@MovMatrixUp1D
		inc dx
		mov bx, dx
	loop @@MovMatrixUp2D

	xor ax, ax

	mov al, [DkHeight]
	mov cx, [DkTopPointY]
	add cx, ax

	mov dx, [DkArea]
	mov al, [DkWidth]
	sub dx, ax

	xor si, si
	@@GetDownPixels:

		mov ax, [DkTopPointX]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		push si
		add si, dx

		mov [LastDkPos + si], al
		pop si
		inc si

		xor ax, ax
		mov al, [DkWidth]

		cmp si, ax
		jne @@GetDownPixels

	inc [DkTopPointY]
	push [CurrentDkImage]
	call ChangeDkImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveDkPixelDown


proc MoveDkPixelUp
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	push [DkTopPointX]
	push [DkTopPointY]
	call ConvertMatrixPos
	lea cx, [LastDkPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [DkWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [DkHeight]  ;number of rows
	call putMatrixInScreen


	xor ax, ax
	mov al, [DkWidth]
	mov si, ax

	mov dx, [DkArea]
	sub dx, ax
	mov bx, dx
	sub bx, ax

	xor cx, cx
	mov cl, [DkHeight]
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			mov al, [LastDkPos + bx]
			mov [LastDkPos + bx + si], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixUp1D
		mov dx, bx
		sub bx, si
		sub bx, si
		sub dx, si
	loop @@MovMatrixUp2D



	xor dx, dx
	mov dl, [DkWidth]

	mov cx, [DkTopPointY]
	dec cx
	xor si, si
	@@GetUpPixels:

		mov ax, [DkTopPointX]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		mov [LastDkPos + si], al
		inc si
		cmp si, dx
		jne @@GetUpPixels

	dec [DkTopPointY]
	push [CurrentDkImage]
	call ChangeDkImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp MoveDkPixelUp


proc CloseDkBmpFile
	mov ah,3Eh
	mov bx, [DkFileHandle]
	int 21h
	ret
endp CloseDkBmpFile


proc OpenShowDkBmp

	call OpenBmpDkFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadDkBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseDkBmpFile

	@@ExitProc:
		ret
endp OpenShowDkBmp


; input dx DkFileName to open
proc OpenBmpDkFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [DkFileHandle], ax
	jmp @@ExitProc
	
	@@ErrorAtOpen:
		mov [ErrorFile],1
	@@ExitProc:	
		ret
endp OpenBmpDkFile


; Read 54 bytes the Header
proc ReadDkBmpHeader					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [DkFileHandle]
	mov cx,54
	mov dx,offset DkHeader
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadDkBmpHeader