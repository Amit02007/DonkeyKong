IDEAL

MODEL small
STACK 150h


DATASEG

    Lives db 3

    LivesFileName db "Lives.bmp", 0
 
	LivesFileHandle	dw ?
	LivesHeader db 54 dup(0)

    OffsetToReturn dw ?
    SavedAx dw ?
    SavedCx dw ?
    SavedBp dw ?

CODESEG


StackReturn equ [bp + 4] 
proc Return
    mov [SavedBp], bp
    pop bp
    mov bp, sp

    mov [SavedAx], ax
    mov [SavedCx], cx

    mov ax, [bp + 2]
    mov [OffsetToReturn], ax

    mov cx, StackReturn
    @@PopStack:
        pop ax

        sub cx, 2
        cmp cx, 1
        jb @@PopStack

    mov ax, [SavedAx]
    mov cx, [SavedCx]
    mov bp, [SavedBp]
    jmp [OffsetToReturn]

endp Return


proc ResetLives
    push dx
    
    mov [Lives], 3

    mov dx, offset LivesFileName
	mov [BmpLeft],5
	mov [BmpTop],5
	mov [BmpColSize], 40
	mov [BmpRowSize] ,13
	call OpenShowLivesBmp
	cmp [ErrorFile], 0
	je @@NoError
	jmp exitError
    
    @@NoError:
    pop dx
    ret
endp ResetLives


proc RemoveLives
    push ax
    push cx
    push dx
    push di
    push si

    mov dx, offset LivesFileName
	mov [BmpLeft],5
	mov [BmpTop],5
	mov [BmpColSize], 40
	mov [BmpRowSize] ,13
	call OpenShowLivesBmp
	cmp [ErrorFile], 0
	je @@NoError
	jmp exitError
    
    @@NoError:

    cmp [Lives], 3
    je @@Three

    cmp [Lives], 2
    je @@Two
  
    cmp [Lives], 1
    je @@One

    jmp @@Quit

    @@Three:
        dec [Lives]
        mov cx, 35
        mov dx, 5
        mov di, 10
        mov si, 13
        mov al, 0
        call Rect
        jmp @@Quit

    @@Two:
        dec [Lives]
        mov cx, 20
        mov dx, 5
        mov di, 55
        mov si, 13
        mov al, 0
        call Rect
        jmp @@Quit

    @@One:
        mov [SelectedScreen], 0
        call SwitchScreen
        call UpdateBackgourndImage
        jmp @@Quit

    @@Quit:
        pop si
        pop di
        pop dx
        pop cx
        pop ax
        ret
endp RemoveLives


proc CheckHit
    push ax
	push bx
    push cx
	push dx
	push si
	
    xor bx, bx
    @@FindMovingBarrel:
        cmp [word ptr Barrels + bx], 0
        jne @@Found

        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jb @@FindMovingBarrel

    jmp @@Quit
	
    @@Found:
        xor cx, cx

        mov ax, [Barrels + bx]
        cmp ax, [MarioTopPointX]
        jnae @@CheckLeftPoint

        mov ax, [Barrels + bx]
        mov cx, [MarioTopPointX]
        add cl, [MarioWidth]
        dec cx
        cmp ax, cx
        ja @@CheckLeftPoint

        mov ax, [Barrels + bx + 2]
        cmp ax, [MarioTopPointY]
        jb @@CheckLeftPoint

        mov ax, [Barrels + bx + 2]
        mov cx, [MarioTopPointY]
        add cl, [MarioHeight]
        dec cx
        cmp ax, cx
        jnbe @@CheckLeftPoint

        jmp @@Hit

        @@CheckLeftPoint:
            mov ax, [Barrels + bx]
            add ax, [Barrels + bx + 6]
            dec ax
            cmp ax, [MarioTopPointX]
            jnae @@NextBarrelInList

            mov ax, [Barrels + bx]
            add ax, [Barrels + bx + 6]
            dec ax
            mov cx, [MarioTopPointX]
            add cl, [MarioWidth]
            dec cx
            cmp ax, cx
            ja @@NextBarrelInList

            mov ax, [Barrels + bx + 2]
            add ax, [Barrels + bx + 8]
            dec ax
            cmp ax, [MarioTopPointY]
            jb @@NextBarrelInList

            mov ax, [Barrels + bx + 2]
            add ax, [Barrels + bx + 8]
            dec ax
            mov cx, [MarioTopPointY]
            add cl, [MarioHeight]
            dec cx
            cmp ax, cx
            jnbe @@NextBarrelInList
        
        @@Hit:
            @@RemoveMario:
                mov [IsInit], 0
                call CloseMarioBmpFile

            @@RemoveBarrel:
                mov [IsBarrelInit], 0
                call CloseBarrelBmpFile

            @@UpdateBackgound:
                mov [SelectedScreen], 1
                call SwitchScreen
                call UpdateBackgourndImage

                call RemoveLives

                jmp @@Quit


    @@NextBarrelInList:
        add bx, NEXT_BARREL
        cmp bx, [BarrelsLenght]
        jnbe @@Quit

        jmp @@FindMovingBarrel


	@@Quit:
		pop si
		pop dx
        pop cx
		pop bx
		pop ax
		ret
endp CheckHit


yPoint equ [bp + 4] 
proc GetRollingDownDirection
    push bp
    mov bp, sp

    mov ax, yPoint

    cmp ax, 56
    jl @@Right

    cmp ax, 85
    jl @@Left
    
    cmp ax, 114
    jl @@Right
    
    cmp ax, 143
    jl @@Left
    
    cmp ax, 172
    jl @@Right
    
    cmp ax, 194
    jl @@Left

    xor ax, ax
    jmp @@Quit

    @@Left:
        mov ax, "L"
        jmp @@Quit

    @@Right:
        mov ax, "R"
        jmp @@Quit


    @@Quit:
        pop bp
        ret 2
endp GetRollingDownDirection



proc CloseLivesBmpFile
	mov ah,3Eh
	mov bx, [LivesFileHandle]
	int 21h
	ret
endp CloseLivesBmpFile



proc OpenShowLivesBmp

	call OpenBmpLivesFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadLivesBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseLivesBmpFile

	@@ExitProc:
		ret
endp OpenShowLivesBmp


; input dx LivesFileName to open
proc OpenBmpLivesFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [LivesFileHandle], ax
	jmp @@ExitProc
	
	@@ErrorAtOpen:
		mov [ErrorFile],1
	@@ExitProc:	
		ret
endp OpenBmpLivesFile


; Read 54 bytes the Header
proc ReadLivesBmpHeader					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [LivesFileHandle]
	mov cx,54
	mov dx,offset LivesHeader
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadLivesBmpHeader