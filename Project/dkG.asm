IDEAL

MODEL small
STACK 90


DATASEG

	; 1 -> Standing Forward
	; 2 -> Standing Left
	; 3 -> Standing Forward With Barrel
	; 4 -> Standing Right
	DkFileName db "dk1.bmp", 0

	LastDkPos 		db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)

	DkMatrix 		db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
					db 43 dup (0)
 
	DkFileHandle	dw ?
	DkHeader db 120 dup(0)

	; Dk image data
	CurrentDkImage dw "1"
	LastDkImage dw "1"
	DkWidth db 40
	DkHeight db 32
	DkArea dw 1280

	; DkWidth db 43
	; DkHeight db 32
	; DkArea dw 1376

	CurrentDkImageAnimation dw "1"

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

	cmp ax, "2"
	je @@Side

	cmp ax, "3"
	je @@Standing

	cmp ax, "4"
	je @@Side

	jmp @@Quit

	@@Standing:
		mov [DkWidth], 40
		mov	[DkHeight], 32
		mov	[DkArea], 1280

		jmp @@Quit

	@@Side:
		mov [DkWidth], 43
		mov	[DkHeight], 32
		mov	[DkArea], 1376

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




	@@Quit:
		mov ax, [LastDkImage]
		cmp [CurrentDkImage], ax
		je @@Resume

		call RefreshDk
		
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
	push di

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

	pop di
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