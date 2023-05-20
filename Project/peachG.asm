IDEAL

MODEL small
STACK 90


DATASEG

	PeachFileName db "peach2.bmp", 0

	LastPeachPos 	db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)

	PeachMatrix 	db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
					db 15 dup (0)
 
	PeachFileHandle	dw ?
	PeachHeader db 90 dup(0)

	; Peach image data
	CurrentPeachImage dw "1"
	LastPeachImage dw "1"
	PeachWidth db 15
	PeachHeight db 22
	PeachArea dw 330


CODESEG

Image equ [bp + 4]
proc ChangePeachImage
	push bp
	mov bp, sp
	push ax
	push dx
	
	mov ax, Image
	mov [PeachFileName + 5], al

	mov dx, offset PeachFileName
	mov ax, [PeachTopPointX]
	mov [BmpLeft], ax
	mov ax, [PeachTopPointY]
	mov [BmpTop], ax
	xor ax, ax
	mov al, [PeachWidth]
	mov [BmpColSize], ax
	mov al, [PeachHeight]
	mov [BmpRowSize], ax
	call OpenShowPeachBmp

	call RemovePeachBackground

	pop dx
	pop ax
	pop bp
	ret 2
endp ChangePeachImage


Image equ [bp + 4]
proc ChangePeachData
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

	jmp @@Quit

	@@One:
		mov [PeachWidth], 14
		mov	[PeachHeight], 22
		mov	[PeachArea], 308

		jmp @@Quit

	@@Two:
		mov [PeachWidth], 15
		mov	[PeachHeight], 22
		mov	[PeachArea], 330

		jmp @@Quit


	@@Quit:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp ChangePeachData


proc UpdatePeachImage
	push ax
	push bx
	push cx
	push dx

	mov ax, [CurrentPeachImage]
	mov [LastPeachImage], ax

	push 9
	Call GetTime

	cmp al, 10
	je @@Animation
	jmp @@Quit


	@@Animation:


	push 9
	call StopTimer
	push 9
	call ResetTimer
	push 9
	call StartTimer


	cmp [CurrentPeachImage], "1"
	je @@ChangeOther

	mov [CurrentPeachImage], "1"
	jmp @@Quit

	@@ChangeOther:
		mov [CurrentPeachImage], "2"


	@@Quit:
		mov ax, [LastPeachImage]
		cmp [CurrentPeachImage], ax
		je @@Resume

		call RefreshPeach

		@@Resume:
			pop dx
			pop cx
			pop bx
			pop ax
			ret
endp UpdatePeachImage


proc RefreshPeach
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	call ClosePeachBmpFile

	mov di, [PeachTopPointX]
	lea cx, [LastPeachPos] 
	mov [Matrix], cx ; put the bytes offset in Matrix
	xor dx, dx
	mov dl, [PeachWidth]   ; number of cols 
	xor cx, cx 
	mov cl, [PeachHeight]  ;number of rows
	call putMatrixInScreen

	push [CurrentPeachImage]
	call ChangePeachData

	xor cx, cx
	mov cl, [PeachWidth]

	xor si, si
	@@Column:
		xor bx, bx
			@@Row:
				mov ax, [PeachTopPointX]
				add ax, bx
				push ax
				mov ax, [PeachTopPointY]
				add ax, si
				push ax
				call GetPixelColor

				push si
				push ax
				mov dx, si
				mov al, [PeachWidth]
				mul dl
				add ax, bx
				mov si, ax
				pop ax

				mov [LastPeachPos + si], al
				pop si
				inc bx
				cmp bx, cx
				jne @@Row
		
		xor bx, bx
		mov bl, [PeachHeight]
		inc si
		cmp si, bx
	jne @@Column

	push [CurrentPeachImage]
	call ChangePeachImage

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RefreshPeach


proc RemovePeachBackground
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

		mov ax, [PeachTopPointX]
		add ax, bx
		push ax
		mov ax, [PeachTopPointY]
		add ax, si
		push ax
		call GetPixelColor

		push si
		push ax
		mov dx, si
		mov al, [PeachWidth]
		mul dl
		add ax, bx
		mov si, ax
		pop ax

		cmp al, 0
		jne @@NoBackGound

		mov al, [LastPeachPos + si]

		@@NoBackGound:
			mov [PeachMatrix + si], al
			pop si
			inc bx
			cmp bl, [PeachWidth]
			jne @@Row

	xor bx, bx
	mov bl, [PeachHeight]
	inc si
	cmp si, bx
	jne @@Column

	xor ax, ax
	xor bx, bx
	mov al, [PeachWidth]
	mov bl, [PeachHeight]

	mov di, [PeachTopPointX]
	lea cx, [PeachMatrix] 
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
endp RemovePeachBackground


proc ClosePeachBmpFile
	mov ah,3Eh
	mov bx, [PeachFileHandle]
	int 21h
	ret
endp ClosePeachBmpFile


proc OpenShowPeachBmp
	push ax
	push bx
	push cx
	push dx

	call OpenBmpPeachFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadPeachBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call ClosePeachBmpFile

	@@ExitProc:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
endp OpenShowPeachBmp


; input dx PeachFileName to open
proc OpenBmpPeachFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [PeachFileHandle], ax
	jmp @@ExitProc
	
	@@ErrorAtOpen:
		mov [ErrorFile],1
	@@ExitProc:	
		ret
endp OpenBmpPeachFile


; Read 54 bytes the Header
proc ReadPeachBmpHeader					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [PeachFileHandle]
	mov cx,54
	mov dx,offset PeachHeader
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadPeachBmpHeader