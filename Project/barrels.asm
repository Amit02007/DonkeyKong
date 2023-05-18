IDEAL

MODEL small
STACK 150h

MAX_BARRELS_ON_SCREEN = 4
MAX_BARRELS_WIDTH = 16
MAX_BARRELS_HEIGHT = 10

NEXT_BARREL = 14


DATASEG

    ; x, y, image, width, height, area, falling counter / is falling
    Barrels dw MAX_BARRELS_ON_SCREEN dup (0, 0, 0, 0, 0, 0, 0)
    BarrelsLenght dw $ - Barrels

    BarrelFileName db "Barrel1.bmp", 0
	
	LastBarrelPos db MAX_BARRELS_ON_SCREEN dup (MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0)))

    BarrelMatrix db  MAX_BARRELS_ON_SCREEN dup (MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0)))

    BarrelFileHandle dw ?
    BarrelHeader db 54 dup(0)

    CurrentBarrelImage dw "1"
	LastBarrelImage dw "1"
	; BarrelWidth db 12
	; BarrelHeight db 10
	; BarrelArea dw 120

	IsBarrelInit db 0


CODESEG

proc CreateBarrel
	push ax
	push bx
	push cx
	push dx
	push si

    xor bx, bx
    @@FindEmptyBarrel:
        cmp [word ptr Barrels + bx], 0
        je @@Found

        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jb @@FindEmptyBarrel

    jmp @@Quit

    @@Found:
        mov [Barrels + bx], 124             ; X point
        mov [Barrels + bx + 2], 36          ; Y point
        mov [Barrels + bx + 4], "1"         ; Image
        mov [Barrels + bx + 6], 12          ; Width
        mov [Barrels + bx + 8], 10          ; Height
        mov [Barrels + bx + 10], 120        ; Area

		mov cx, bx

		; Get first backgound

		xor si, si
		@@Column:
			xor bx, bx
			@@Row:
				mov ax, 124
				add ax, bx
				push ax
				mov ax, 36
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

				push bx
				push cx
				call GetLastBarrelPosOffset
				mov [LastBarrelPos + si + bx], al
				pop bx
				pop si
				inc bx
				cmp bx, 12
				jne @@Row

			mov bx, 10
			inc si
			cmp si, bx
			jne @@Column
        
		push cx
		mov bx, cx
		push [Barrels + bx + 4]
		call ChangeBarrelImage

    @@Quit:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
        ret
endp CreateBarrel


BarrelStartPosition equ [bp + 4]
proc RemoveBarrel
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	push di


	mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + 2 + bx]
	call ConvertMatrixPos

	lea cx, [LastBarrelPos] 
    mov bx, BarrelStartPosition
    push bx
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen

	mov [Barrels + bx], 0

	pop di
	pop dx
	pop cx
	pop bx
	pop bp
	ret 2
endp RemoveBarrel


proc InitBarrel
	push ax
	push bx
	push dx
	push si

	push 2
	call StartTimer
	push 3
	call StartTimer
	push 4
	call StartTimer

	pop si
	pop dx
	pop bx
	pop ax
	ret
endp InitBarrel


proc UpdateBarrels

	cmp [CurrentScreen], 1
	je @@NotRemoveBarrel

	; TODO: Change the location of DetectDirection
	cmp [CurrentScreen], 3
	je @@Pause
	jmp @@RemoveBarrel

	@@Pause:
		cmp [IsBarrelInit], 2
		jne @@Remove
		jmp @@Quit

		@@Remove:
			call CloseBarrelBmpFile
			mov [IsBarrelInit], 2
			jmp @@Quit

	@@NotRemoveBarrel:

	cmp [IsBarrelInit], 1
	je @@Init
	call InitBarrel
	mov [IsBarrelInit], 1

	@@Init:
		call UpdateBarrelImage
		
		call MoveBarrels


	jmp @@Quit

	@@RemoveBarrel:
		mov [IsBarrelInit], 0
		call CloseBarrelBmpFile

	@@Quit:
		ret
endp UpdateBarrels


BarrelStartPosition equ [bp + 6]
Image equ [bp + 4]
proc ChangeBarrelImage
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	
	mov ax, Image
	mov [BarrelFileName + 6], al

    mov bx, BarrelStartPosition

	mov dx, offset BarrelFileName
	mov ax, [Barrels + bx]
	mov [BmpLeft], ax
	mov ax, [Barrels + bx + 2]
	mov [BmpTop], ax
	mov ax, [Barrels + bx + 6]
	mov [BmpColSize], ax
	mov ax, [Barrels + bx + 8]
	mov [BmpRowSize], ax
	call OpenShowBarrelBmp

	push BarrelStartPosition
	call RemoveBarrelBackground

	pop dx
	pop bx
	pop ax
	pop bp
	ret 4
endp ChangeBarrelImage


BarrelStartPosition equ [bp + 6]
Image equ [bp + 4]
proc ChangeBarrelData
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	mov ax, Image
	mov bx, BarrelStartPosition

	cmp ax, "1"
	je @@RollingSide

	cmp ax, "2"
	je @@RollingSide

	cmp ax, "3"
	je @@RollingDown

	cmp ax, "4"
	je @@RollingDown

	jmp @@Quit

	@@RollingSide:
		mov [Barrels + bx + 6], 12
        mov [Barrels + bx + 8], 10
        mov [Barrels + bx + 10], 120

		jmp @@Quit

	@@RollingDown:
		mov [Barrels + bx + 6], 15
        mov [Barrels + bx + 8], 10
        mov [Barrels + bx + 10], 150

		jmp @@Quit


	@@Quit:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 4
endp ChangeBarrelData


proc UpdateBarrelImage
	push ax
	push bx
	push cx
	push dx

	mov ax, [CurrentBarrelImage]
	mov [LastBarrelImage], ax


	push 3
	Call GetTime

	cmp al, 18
	jge @@Animation
	jmp @@Quit


	@@Animation:

	push 3
	call StopTimer
	push 3
	call ResetTimer
	push 3
	call StartTimer

	xor bx, bx
    @@FindMovingBarrel:
        cmp [word ptr Barrels + bx], 0
        jne @@Found

        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jb @@FindMovingBarrel

    jmp @@Quit



    @@Found:
		mov ax, [Barrels + bx + 12]
		cmp ax, 0
		jne @@Falling

		cmp [Barrels + bx + 4], "1"
		jne @@Replace

		mov cx, "2"
		cmp [Barrels + bx + 4], "3"
		je @@Refresh
		cmp [Barrels + bx + 4], "4"
		je @@Refresh

		mov [Barrels + bx + 4], "2"

		add bx, NEXT_BARREL
		cmp bx, [BarrelsLenght]
		jbe @@FindMovingBarrel
		jmp @@quit

		@@Replace:
			mov cx, "1"
			cmp [Barrels + bx + 4], "3"
			je @@Refresh
			cmp [Barrels + bx + 4], "4"
			je @@Refresh

			mov [Barrels + bx + 4], "1"
			
			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jbe @@FindMovingBarrel

			jmp @@Quit


		@@Refresh:
			mov [Barrels + bx + 4], cx
			push bx
			call RefreshBarrel
			
			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jbe @@FindMovingBarrel
			jmp @@quit


		@@Falling:
			cmp [Barrels + bx + 4], "3"
			jne @@ReplaceFalling

			mov cx, "4"
			cmp [Barrels + bx + 4], "2"
			je @@Refresh
			cmp [Barrels + bx + 4], "1"
			je @@Refresh

			mov [Barrels + bx + 4], "4"

			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jnbe @@quit
			jmp @@FindMovingBarrel

			@@ReplaceFalling:
				mov cx, "3"
				cmp [Barrels + bx + 4], "2"
				je @@Refresh
				cmp [Barrels + bx + 4], "1"
				je @@Refresh
				
				mov [Barrels + bx + 4], "3"

				add bx, NEXT_BARREL
				cmp bx, [BarrelsLenght]
				jnbe @@Quit

				jmp @@FindMovingBarrel


		@@Quit:
			mov ax, [LastBarrelImage]
			cmp [CurrentBarrelImage], ax
			je @@Resume

		; cmp [LastBarrelImage], "5"
		; je @@ShowBarrel

		; cmp [LastBarrelImage], "6"
		; je @@ShowBarrel
		
		; cmp [LastBarrelImage], "7"
		; je @@ShowBarrel
		
		; cmp [LastBarrelImage], "8"
		; je @@ShowBarrel
		
		; jmp @@Resume

		; @@ShowBarrel:
		; 	push [CurrentBarrelImage]
		; 	call ChangeBarrelImage

		@@Resume:
			pop dx
			pop cx
			pop bx
			pop ax
			ret
endp UpdateBarrelImage


proc MoveBarrels
	push ax
	push bx
	push cx


	push 2
    Call GetTime

	cmp [IsReadyToClimb], 1
	je @@Slower

	cmp [MarioClimbState], 1
	jne @@NotJumping

	@@Slower:
	cmp al, 5
	jnb @@Resume
	jmp @@Quit

	@@NotJumping:
		cmp al, 1
		jnb @@Resume
		jmp @@Quit

	@@Resume:
    	push 2
		call StopTimer
		push 2
		call ResetTimer
		push 2
		call StartTimer


	xor bx, bx
    @@FindMovingBarrel:
        cmp [word ptr Barrels + bx], 0
        jne @@Found

        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jb @@FindMovingBarrel

    jmp @@Quit


    @@Found:
		mov ax, [Barrels + bx + 12]
		cmp al, 1
		je @@AllredyFallingLadder
		
		mov ax, [Barrels + bx + 2]
		add ax, [Barrels + bx + 8]
		add ax, 8
		push [Barrels + bx]
		push ax
		call GetPixelColor
		
		cmp al, [LadderColor]
		jne @@CheckDirection


		; Random Boolean
		mov cx, bx
		mov ax, [Barrels + bx + 10]
		add al, [MarioMatrix + bx]
		sub al, [BarrelMatrix + bx + 1]
		add ax, [Barrels + bx + 2]
		xor ax, [Barrels]
		sub ax, [Barrels + 16]
		xor ax, [Barrels + 32]
		xor ah, ah
		and al, 00000001b
		cmp al, 1
		je @@CheckDirection

		; Activate Falling
		mov ax, [Barrels + bx + 12]
		mov al, 1
		mov [Barrels + bx + 12], ax

		@@AllredyFallingLadder:
			mov ax, [Barrels + bx + 12]
			cmp ah, 8
			je @@ChangeToGravity

			inc ah
			mov [Barrels + bx + 12], ax
			push bx
			call MoveBarrelPixelDown
			jmp @@NextBarrelInList

			@@ChangeToGravity:
				push bx
				call BarrelFalling

			@@NextBarrelInList:
				add bx, NEXT_BARREL
				cmp bx, [BarrelsLenght]
				jnbe @@Quit

				jmp @@FindMovingBarrel


		@@CheckDirection:
			push [Barrels + bx + 2]
			call GetRollingDownDirection
		

		cmp ax, "L"
		je @@Left

		cmp ax, "R"
		je @@Right

		jmp @@Quit

		@@Left:
			cmp [Barrels + bx + 2], 172
			jng @@NotRemoveBarrel
			cmp [Barrels + bx], 65
			jne @@NotRemoveBarrel

			push bx
			call RemoveBarrel
			jmp @@Quit

			@@NotRemoveBarrel: 
			push bx
			call MoveBarrelPixelLeft
			push bx
			call BarrelFalling
			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jnbe @@Quit

			jmp @@FindMovingBarrel

		@@Right:
			push bx
			call MoveBarrelPixelRight
			push bx
			call BarrelFalling
			add bx, NEXT_BARREL
			cmp bx, [BarrelsLenght]
			jnbe @@Quit

			jmp @@FindMovingBarrel

			

	@@Quit:
		pop cx
		pop bx
		pop ax
		ret
endp MoveBarrels


BarrelStartPosition equ [bp + 4]
proc RefreshBarrel
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	
    mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + bx + 2]
	call ConvertMatrixPos

	lea cx, [LastBarrelPos] 
    push bx
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen

	
    mov bx, BarrelStartPosition
	push bx
	push [Barrels + bx + 4]
	call ChangeBarrelData

	mov cx, BarrelStartPosition
	mov bx, BarrelStartPosition
	mov dx, [Barrels + bx + 6]

	xor si, si
	@@Column:
		xor bx, bx
		@@Row:
			push bx
			mov bx, cx
			mov ax, [Barrels + bx]
			pop bx
			add ax, bx
			push ax
			push bx
			mov bx, cx
			mov ax, [Barrels + bx + 2]
			pop bx
			add ax, si
			push ax
			call GetPixelColor
			
			push si
			push dx
			push ax
			mov dx, si
			push bx
			mov bx, cx
			mov ax, [Barrels + bx + 6]
			pop bx
			mul dl
			add ax, bx
			mov si, ax
			pop ax
			pop dx

			push bx
			push cx
			call GetLastBarrelPosOffset
			mov [LastBarrelPos + si + bx], al
			pop bx
			pop si
			inc bx
			cmp bx, dx
			jne @@Row

		push dx
		push bx
		mov bx, cx
		mov dx, [Barrels + bx + 8]
		pop bx
		mov bx, dx
		pop dx
		inc si
		cmp si, bx
		jne @@Column


	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp RefreshBarrel


BarrelStartPosition equ [bp + 4]
proc RemoveBarrelBackground
    push bp
    mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	xor si, si
	xor cx, cx
	@@Column:
		xor cx, cx
		@@Row:
		mov bx, BarrelStartPosition

		mov ax, [Barrels + bx]
		add ax, cx
		push ax
		mov ax, [Barrels + bx + 2]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov ax, [Barrels + bx + 6]
		mul dl
		add ax, cx
		mov si, ax
		pop ax


		push BarrelStartPosition
		call GetLastBarrelPosOffset

		cmp al, 0
		jne @@NoBackGound

		mov al, [LastBarrelPos + si + bx]

		@@NoBackGound:
			mov [BarrelMatrix + si + bx], al
			pop si

			mov bx, BarrelStartPosition

			inc cx
			cmp cx, [Barrels + bx + 6]
			jne @@Row

	mov cx, [Barrels + bx + 8]
	inc si
	cmp si, cx
	jne @@Column

	mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + 2 + bx]
	call ConvertMatrixPos

	lea cx, [BarrelMatrix]
	
    push BarrelStartPosition
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
    pop bp
	ret 2
endp RemoveBarrelBackground

BarrelStartPosition equ [bp + 4]
proc GetLastBarrelPosOffset
    push bp
    mov bp, sp
    push ax
    push cx
	push dx

	xor bx, bx

    ; Getting barrel number
    mov ax, BarrelStartPosition
    mov bl, NEXT_BARREL
    div bl

    mov cx, ax

    mov ax, MAX_BARRELS_WIDTH
    mov bx, MAX_BARRELS_HEIGHT
    mul bl

    mul cx

    mov bx, ax

    @@Quit:
		pop dx
        pop cx
        pop ax
        pop bp
        ret 2
endp GetLastBarrelPosOffset


BarrelStartPosition equ [bp + 4]
proc MoveBarrelPixelLeft
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di


    mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + bx + 2]
	call ConvertMatrixPos

	lea cx, [LastBarrelPos] 
    push bx
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen


	mov bx, BarrelStartPosition

	push bx
	call GetLastBarrelPosOffset
	mov di, bx

	mov bx, BarrelStartPosition
	mov ax, [Barrels + bx + 6]
	inc ax
	mov cx, [Barrels + bx + 8]
	xor si, si
	@@MovMatrixRight2D:
		mov dx, si
		dec dx
		add si, [Barrels + bx + 6]
		sub si, 2

		push bx
		mov bx, di
		@@MovMatrixRight1D:
			mov al, [LastBarrelPos + si + bx]
			mov [LastBarrelPos + si + bx + 1], al
			dec si
			cmp si, dx
			jne @@MovMatrixRight1D

		; add si, BarrelWidth + 1
		pop bx
		mov bx, BarrelStartPosition
		mov ax, [Barrels + bx + 6]
		add ax, 1
		add si, ax
	loop @@MovMatrixRight2D

	mov si, BarrelStartPosition
	mov cx, [Barrels + si]
	dec cx

	mov di, [Barrels + si + 8]
	xor si, si
	@@GetLeftPixels:

		mov bx, BarrelStartPosition

		push cx
		mov ax, [Barrels + bx + 2]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov ax, [Barrels + bx + 6]
		mul dl
		mov si, ax
		pop ax

		push BarrelStartPosition
		call GetLastBarrelPosOffset

		mov [LastBarrelPos + si + bx], al
		pop si
		inc si
		cmp si, di
		jne @@GetLeftPixels
	
	mov bx, BarrelStartPosition
	dec [Barrels + bx]
	push bx
	push [Barrels + bx + 4]
	call ChangeBarrelImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp MoveBarrelPixelLeft


BarrelStartPosition equ [bp + 4]
proc MoveBarrelPixelRight
    push bp
    mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di

    mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + 2 + bx]
	call ConvertMatrixPos

	lea cx, [LastBarrelPos] 
    mov bx, BarrelStartPosition
    push bx
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen

    push bx
    call GetLastBarrelPosOffset
    mov si, bx

	mov bx, BarrelStartPosition
	mov dx, [Barrels + bx + 6]
	dec dx
	mov cx, [Barrels + bx + 8]
	xor bx, bx
	@@MovMatrixLeft2D:
		@@MovMatrixLeft1D:
			mov al, [LastBarrelPos + bx + 1 + si]
			mov [LastBarrelPos + bx + si], al
			inc bx
			cmp bx, dx
			jne @@MovMatrixLeft1D

		; add dx, BarrelWidth
        push bx
        mov bx, BarrelStartPosition
		mov ax, [Barrels + bx + 6]
		add dx, ax
        pop bx

		add bx, 1
	loop @@MovMatrixLeft2D

    mov bx, BarrelStartPosition
	mov cx, [Barrels + bx]
	; add cx, BarrelWidth
	mov ax, [Barrels + bx + 6]
	@@AddCxBarrelWidth:
		inc cx
		dec al
		jnz @@AddCxBarrelWidth

    mov bx, BarrelStartPosition
    mov si, bx
	mov bx, [Barrels + si + 6]
	dec bx
	xor si, si
	@@GetRightPixels:

        push bx
        mov bx, BarrelStartPosition
		mov ax, [Barrels + bx + 2]
        pop bx
		add ax, si
		push cx
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
        push bx
        mov bx, BarrelStartPosition
		mov ax, [Barrels + bx + 6]
        pop bx
		mul dl
		mov si, ax
		pop ax

        push bx
		mov bx, BarrelStartPosition
        push bx
        call GetLastBarrelPosOffset
        add si, bx
        pop bx

		mov [LastBarrelPos + si + bx], al
		pop si
		inc si
        push bx
        mov bx, BarrelStartPosition
		mov dx, [Barrels + bx + 8]
        pop bx

		cmp si, dx
		jne @@GetRightPixels
	
    mov bx, BarrelStartPosition
	inc [Barrels + bx]
    push bx
	push [Barrels + bx + 4]
	call ChangeBarrelImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
        pop bp
		ret 2
endp MoveBarrelPixelRight


BarrelStartPosition equ [bp + 4]
proc MoveBarrelPixelDown
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di


    mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + 2 + bx]
	call ConvertMatrixPos

	lea cx, [LastBarrelPos] 
    mov bx, BarrelStartPosition
    push bx
    call GetLastBarrelPosOffset
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen


    mov bx, BarrelStartPosition

	mov cx, [Barrels + bx + 6]
	mov si, cx
	mov ax, [Barrels + bx + 10]
	sub ax, si
	xor bx, bx
	xor dx, dx
	@@MovMatrixUp2D:
		@@MovMatrixUp1D:
			push ax

			mov ax, bx

			push bx

			mov bx, BarrelStartPosition
			push bx
			call GetLastBarrelPosOffset

			add bx, ax

			mov al, [LastBarrelPos + bx + si]
			mov [LastBarrelPos + bx], al

			pop bx

			add bx, si
			pop ax
			cmp bx, ax
			jb @@MovMatrixUp1D
		inc dx
		mov bx, dx
	loop @@MovMatrixUp2D

    mov bx, BarrelStartPosition

	mov ax, [Barrels + bx + 8]
	mov cx, [Barrels + bx + 2]
	add cx, ax

	mov dx, [Barrels + bx + 10]
	mov ax, [Barrels + bx + 6]
	sub dx, ax

	xor si, si
	@@GetDownPixels:

    	mov bx, BarrelStartPosition

		mov ax, [Barrels + bx]
		add ax, si
		push ax
		push cx
		call GetPixelColor

		push si
		add si, dx

		push bx
		call GetLastBarrelPosOffset

		mov [LastBarrelPos + si + bx], al
		pop si
		inc si

		mov bx, BarrelStartPosition

		mov ax, [Barrels + bx + 6]

		cmp si, ax
		jne @@GetDownPixels

	mov bx, BarrelStartPosition
	inc [Barrels + bx + 2]
	push bx
	push [Barrels + bx + 4]
	call ChangeBarrelImage

	@@Quit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp MoveBarrelPixelDown


BarrelStartPosition equ [bp + 4]
proc BarrelFalling
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

    mov si, BarrelStartPosition

	mov dx, [Barrels + si + 8]

	mov bx, 2
	@@Fall:		
		mov dx, [Barrels + si + 8]

		mov cx, [Barrels + si + 2]
		add cx, dx

		push [Barrels + si]
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		mov dx, [Barrels + si + 6]
		dec dx

		mov ax, [Barrels + si]
		add ax, dx
		push ax
		push cx
		call GetPixelColor

		cmp al, [FloorColor]
		je @@OnFloor

		push BarrelStartPosition
		call MoveBarrelPixelDown

	dec bx
	cmp bx, 0
	jne @@Fall


	@@OnFloor:
    	mov si, BarrelStartPosition
		mov [Barrels + si + 12], 0
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp BarrelFalling


proc CloseBarrelBmpFile
	mov ah,3Eh
	mov bx, [BarrelFileHandle]
	int 21h
	ret
endp CloseBarrelBmpFile


proc OpenShowBarrelBmp
	push bp

	call OpenBmpBarrelFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBarrelBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseBarrelBmpFile

	@@ExitProc:
		pop bp
		ret
endp OpenShowBarrelBmp


; input dx BarrelFileName to open
proc OpenBmpBarrelFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [BarrelFileHandle], ax
	jmp @@ExitProc
	
	@@ErrorAtOpen:
		mov [ErrorFile],1
	@@ExitProc:	
		ret
endp OpenBmpBarrelFile


; Read 54 bytes the Header
proc ReadBarrelBmpHeader					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [BarrelFileHandle]
	mov cx,54
	mov dx,offset BarrelHeader
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBarrelBmpHeader

