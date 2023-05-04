IDEAL

MODEL small
STACK 256


DATASEG

CODESEG


yPoint equ [bp + 4] 
proc GetRollingDownDirection
    push bp
    mov bp, sp

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


    @Quit:
        pop bp
        ret 2
proc GetRollingDownDirection