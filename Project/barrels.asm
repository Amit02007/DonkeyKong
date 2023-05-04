IDEAL

MODEL small
STACK 256

MAX_BARRELS_ON_SCREEN = 4
MAX_BARRELS_WIDTH = 16
MAX_BARRELS_HEIGHT = 10


DATASEG

    ; x, y, image, width, height, area
    Barrels dw MAX_BARRELS_ON_SCREEN dup (0, 0, 0, 0, 0, 0)
    BarrelsLenght dw $ - Barrels

    BarrelFileName db "Barrel1.bmp", 0
    
	
	; LastBarrelPos db MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0))
	; LastBarrelPos2 db MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0))

    ; BarrelMatrix db  MAX_BARRELS_ON_SCREEN dup (MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0)))
	
	LastBarrelPos db MAX_BARRELS_ON_SCREEN dup (MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0)))

    BarrelMatrix db  MAX_BARRELS_ON_SCREEN dup (MAX_BARRELS_HEIGHT dup (MAX_BARRELS_WIDTH dup (0)))

    BarrelFileHandle dw ?
    BarrelHeader db 54 dup(0)

    CurrentBarrelImage dw "1"
	LastBarrelImage dw "1"
	; BarrelWidth db 12
	; BarrelHeight db 16
	; BarrelArea dw 192

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

        add bx, 12
        cmp bx, [BarrelsLenght]
        jle @@FindEmptyBarrel

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
				call GetLastBarrelPosOffser
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

	; call RemoveBarrelBackground

	pop dx
	pop bx
	pop ax
	pop bp
	ret 4
endp ChangeBarrelImage

; Image equ [bp + 4]
; proc ChangeBarrelData
; 	push bp
; 	mov bp, sp
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push si

; 	mov ax, Image

; 	cmp ax, "1"
; 	je @@Standing

; 	cmp ax, "2"
; 	je @@Standing

; 	cmp ax, "3"
; 	je @@Walking

; 	cmp ax, "4"
; 	je @@Walking
	
; 	cmp ax, "5"
; 	je @@Jumping
	
; 	cmp ax, "6"
; 	je @@Jumping
	
; 	cmp ax, "7"
; 	je @@Climbing
	
; 	cmp ax, "8"
; 	je @@Climbing

; 	jmp @@Quit

; 	@@Standing:
; 		mov [BarrelWidth], 12
; 		mov	[BarrelHeight], 16
; 		mov	[BarrelArea], 192

; 		jmp @@Quit

; 	@@Walking:
; 		mov [BarrelWidth], 15
; 		mov	[BarrelHeight], 16
; 		mov	[BarrelArea], 240

; 		jmp @@Quit
	
; 	@@Jumping:
; 		mov [BarrelWidth], 16
; 		mov	[BarrelHeight], 16
; 		mov	[BarrelArea], 256

; 		jmp @@Quit
	
; 	@@Climbing:
; 		mov [BarrelWidth], 13
; 		mov	[BarrelHeight], 16
; 		mov	[BarrelArea], 208

; 		jmp @@Quit


; 	@@Quit:
; 		pop si
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		pop bp
; 		ret 2
; endp ChangeBarrelData


proc UpdateBarrelImage
	push ax
	push bx
	push cx
	push dx

	mov ax, [CurrentBarrelImage]
	mov [LastBarrelImage], ax

    push 2
    Call GetTime

    cmp al, 7
    jl @@Quit

    push 2
    call StopTimer
    push 2
    call ResetTimer
    push 2
    call StartTimer

    push 0
    call MoveBarrelPixelRight

	cmp [word ptr Barrels + 12], 0
	je @@Quit
    push 12
    call MoveBarrelPixelRight



	@@Quit:
		mov ax, [LastBarrelImage]
		cmp [CurrentBarrelImage], ax
		je @@Resume

		; call RefreshBarrel

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


; proc RefreshBarrel
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push si

; 	call CloseBarrelBmpFile

; 	push [BarrelTopPointX]
; 	push [BarrelTopPointY]
; 	call ConvertMatrixPos
; 	lea cx, [LastBarrelPos] 
; 	mov [Matrix], cx ; put the bytes offset in Matrix
; 	xor dx, dx
; 	mov dl, [BarrelWidth]   ; number of cols 
; 	xor cx, cx 
; 	mov cl, [BarrelHeight]  ;number of rows
; 	call putMatrixInScreen

; 	push [CurrentBarrelImage]
; 	call ChangeBarrelData

; 	xor cx, cx
; 	mov cl, [BarrelWidth]

; 	xor si, si
; 	@@Column:
; 		xor bx, bx
; 			@@Row:
; 				mov ax, [BarrelTopPointX]
; 				add ax, bx
; 				push ax
; 				mov ax, [BarrelTopPointY]
; 				add ax, si
; 				push ax
; 				call GetPixelColor

; 				push si
; 				push ax
; 				mov dx, si
; 				mov al, [BarrelWidth]
; 				mul dl
; 				add ax, bx
; 				mov si, ax
; 				pop ax

; 				mov [LastBarrelPos + si], al
; 				pop si
; 				inc bx
; 				cmp bx, cx
; 				jne @@Row
		
; 		xor bx, bx
; 		mov bl, [BarrelHeight]
; 		inc si
; 		cmp si, bx
; 	jne @@Column

; 	call CheckOnFloor

; 	; push [CurrentBarrelImage]
; 	; call ChangeBarrelImage

; 	pop si
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	ret
; endp RefreshBarrel


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
	xor bx, bx
	@@Column:
		xor bx, bx
		@@Row:

		push bx
		mov bx, BarrelStartPosition
		mov ax, [Barrels + bx]
		pop bx
		add ax, bx
		push ax
		push bx
		mov bx, BarrelStartPosition
		mov ax, [Barrels + bx + 2]
		pop bx
		add ax, si
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
		add ax, bx
		mov si, ax
		pop ax

		cmp al, 0
		jne @@NoBackGound

		push bx
		mov bx, BarrelStartPosition
		push bx
		call GetLastBarrelPosOffser
		mov al, [LastBarrelPos + si + bx]
		pop bx

		@@NoBackGound:
			push bx
			mov bx, BarrelStartPosition
			push bx
			call GetLastBarrelPosOffser
			mov [MarioMatrix + si + bx], al
			pop bx
			pop si

			mov ax, bx
			call showaxdecimal
			inc bx
			cmp bx, [Barrels + 6]
			jne @@Row

	mov bx, BarrelStartPosition
	mov bx, [Barrels + bx + 8]
	inc si
	cmp si, bx
	jne @@Column

	mov bx, BarrelStartPosition

	push [Barrels + bx]
	push [Barrels + 2 + bx]
	call ConvertMatrixPos

	lea cx, [BarrelMatrix] 
    mov bx, BarrelStartPosition
    push bx
    call GetLastBarrelPosOffser
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
proc GetLastBarrelPosOffser
    push bp
    mov bp, sp
    push ax
    push cx

    ; Getting barrel number
    mov ax, BarrelStartPosition
    mov bl, 12
    div bl

    mov cx, ax

    mov ax, MAX_BARRELS_WIDTH
    mov bx, MAX_BARRELS_HEIGHT
    mul bl

    mul cx

    mov bx, ax

    @@Quit:
        pop cx
        pop ax
        pop bp
        ret 2
endp GetLastBarrelPosOffser


; proc MoveBarrelPixelLeft
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push si
; 	push di


; 	push [BarrelTopPointX]
; 	push [BarrelTopPointY]
; 	call ConvertMatrixPos
; 	lea cx, [LastBarrelPos] 
; 	mov [Matrix], cx ; put the bytes offset in Matrix
; 	xor dx, dx
; 	mov dl, [BarrelWidth]   ; number of cols 
; 	xor cx, cx 
; 	mov cl, [BarrelHeight]  ;number of rows
; 	call putMatrixInScreen

; 	xor bx, bx
; 	xor cx, cx
; 	xor ax, ax
; 	mov al, [BarrelWidth]
; 	inc ax
; 	mov cl, [BarrelHeight]
; 	@@MovMatrixRight2D:
; 		mov dx, bx
; 		dec dx
; 		add bl, [BarrelWidth]
; 		sub bx, 2
; 		@@MovMatrixRight1D:
; 			mov al, [LastBarrelPos + bx]
; 			mov [LastBarrelPos + bx + 1], al
; 			dec bx
; 			cmp bx, dx
; 			jne @@MovMatrixRight1D

; 		; add bx, BarrelWidth + 1
; 		xor ax, ax
; 		mov al, [BarrelWidth]
; 		add ax, 1
; 		add bx, ax
; 	loop @@MovMatrixRight2D

; 	mov cx, [BarrelTopPointX]
; 	dec cx

; 	xor bx, bx
; 	mov bl, [BarrelHeight]
; 	xor si, si
; 	@@GetLeftPixels:

; 		push cx
; 		mov ax, [BarrelTopPointY]
; 		add ax, si
; 		push ax
; 		call GetPixelColor

; 		push si
; 		push ax
; 		mov dx, si
; 		mov al, [BarrelWidth]
; 		mul dl
; 		mov si, ax
; 		pop ax

; 		mov [LastBarrelPos + si], al
; 		pop si
; 		inc si
; 		cmp si, bx
; 		jne @@GetLeftPixels
	
; 	dec [BarrelTopPointX]
; 	push [CurrentBarrelImage]
; 	call ChangeBarrelImage

; 	@@Quit:
; 		pop di
; 		pop si
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp MoveBarrelPixelLeft


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
    call GetLastBarrelPosOffser
	add cx, bx

	mov [Matrix], cx ; put the bytes offset in Matrix

    mov bx, BarrelStartPosition

	mov dx, [Barrels + bx + 6]   ; number of cols 
	mov cx, [Barrels + bx + 8]  ;number of rows
	call putMatrixInScreen

    push bx
    call GetLastBarrelPosOffser
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
        call GetLastBarrelPosOffser
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


; proc MoveBarrelPixelDown
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push si
; 	push di


; 	push [BarrelTopPointX]
; 	push [BarrelTopPointY]
; 	call ConvertMatrixPos
; 	lea cx, [LastBarrelPos] 
; 	mov [Matrix], cx ; put the bytes offset in Matrix
; 	xor dx, dx
; 	mov dl, [BarrelWidth]   ; number of cols 
; 	xor cx, cx 
; 	mov cl, [BarrelHeight]  ;number of rows
; 	call putMatrixInScreen

; 	xor bx, bx
; 	xor dx, dx
; 	xor cx, cx
; 	mov cl, [BarrelWidth]
; 	mov si, cx
; 	mov ax, [BarrelArea]
; 	sub ax, si
; 	@@MovMatrixUp2D:
; 		@@MovMatrixUp1D:
; 			push ax
; 			mov al, [LastBarrelPos + bx + si]
; 			mov [LastBarrelPos + bx], al
; 			add bx, si
; 			pop ax
; 			cmp bx, ax
; 			jl @@MovMatrixUp1D
; 		inc dx
; 		mov bx, dx
; 	loop @@MovMatrixUp2D

; 	xor ax, ax

; 	mov al, [BarrelHeight]
; 	mov cx, [BarrelTopPointY]
; 	add cx, ax

; 	mov dx, [BarrelArea]
; 	mov al, [BarrelWidth]
; 	sub dx, ax

; 	xor si, si
; 	@@GetDownPixels:

; 		mov ax, [BarrelTopPointX]
; 		add ax, si
; 		push ax
; 		push cx
; 		call GetPixelColor

; 		push si
; 		add si, dx

; 		mov [LastBarrelPos + si], al
; 		pop si
; 		inc si

; 		xor ax, ax
; 		mov al, [BarrelWidth]

; 		cmp si, ax
; 		jne @@GetDownPixels

; 	inc [BarrelTopPointY]
; 	push [CurrentBarrelImage]
; 	call ChangeBarrelImage

; 	@@Quit:
; 		pop di
; 		pop si
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp MoveBarrelPixelDown


; proc MoveBarrelPixelUp
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push si
; 	push di

; 	push [BarrelTopPointX]
; 	push [BarrelTopPointY]
; 	call ConvertMatrixPos
; 	lea cx, [LastBarrelPos] 
; 	mov [Matrix], cx ; put the bytes offset in Matrix
; 	xor dx, dx
; 	mov dl, [BarrelWidth]   ; number of cols 
; 	xor cx, cx 
; 	mov cl, [BarrelHeight]  ;number of rows
; 	call putMatrixInScreen


; 	xor ax, ax
; 	mov al, [BarrelWidth]
; 	mov si, ax

; 	mov dx, [BarrelArea]
; 	sub dx, ax
; 	mov bx, dx
; 	sub bx, ax

; 	xor cx, cx
; 	mov cl, [BarrelHeight]
; 	@@MovMatrixUp2D:
; 		@@MovMatrixUp1D:
; 			mov al, [LastBarrelPos + bx]
; 			mov [LastBarrelPos + bx + si], al
; 			inc bx
; 			cmp bx, dx
; 			jne @@MovMatrixUp1D
; 		mov dx, bx
; 		sub bx, si
; 		sub bx, si
; 		sub dx, si
; 	loop @@MovMatrixUp2D



; 	xor dx, dx
; 	mov dl, [BarrelWidth]

; 	mov cx, [BarrelTopPointY]
; 	dec cx
; 	xor si, si
; 	@@GetUpPixels:

; 		mov ax, [BarrelTopPointX]
; 		add ax, si
; 		push ax
; 		push cx
; 		call GetPixelColor

; 		mov [LastBarrelPos + si], al
; 		inc si
; 		cmp si, dx
; 		jne @@GetUpPixels

; 	dec [BarrelTopPointY]
; 	push [CurrentBarrelImage]
; 	call ChangeBarrelImage

; 	@@Quit:
; 		pop di
; 		pop si
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret
; endp MoveBarrelPixelUp


proc CloseBarrelBmpFile
	mov ah,3Eh
	mov bx, [BarrelFileHandle]
	int 21h
	ret
endp CloseBarrelBmpFile


proc OpenShowBarrelBmp

	call OpenBmpBarrelFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBarrelBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseBarrelBmpFile

	@@ExitProc:
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