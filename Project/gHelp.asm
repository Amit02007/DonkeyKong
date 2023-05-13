IDEAL

MODEL small
STACK 150h


DATASEG

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