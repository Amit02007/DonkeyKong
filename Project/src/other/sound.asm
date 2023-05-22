IDEAL

MODEL small
STACK 150h

Clock equ es:6Ch

; ----------------- Notes -----------------
N_C1          =         9121
N_CSharp1     =         8609 
N_D1          =         8126
N_DSharp1     =         7670 
N_E1          =         7239
N_F1          =         6833
N_FSharp1     =         6449 
N_G1          =         6087
N_GSharp1     =         5746 
N_A1          =         5423
N_ASharp1     =         5119 
N_B1          =         4831
N_MiddleC     =         4560
N_CSharp2     =         4304
N_D2          =         4063
N_DSharp2     =         3834 
N_E2          =         3619
N_F2          =         3416
N_FSharp2     =         3224 
N_G2          =         3043
N_GSharp2     =         2873 
N_A2          =         2711
N_ASharp2     =         2559 
N_B2          =         2415
N_C3          =         2280
N_CSharp3     =         2152
N_D3          =         2031



DATASEG

    ; Note dw 2712
    Note dw N_C1, 1, N_C1, 0, N_A1, 0, N_F2, 0, N_A2, 0, N_F2, 0, N_A2, 0, N_F1, 0, N_G1, 0, N_F1, 0, N_D2, 0, N_ASharp2, 0, N_D2
    ; Note dw 9121, 8609, 8126, 7670, 7239, 6833, 6449, 6087, 5746, 5423, 5119, 4560, 4304, 4063, 3834, 3619, 3416, 3224, 3043, 2873, 2711, 2559, 2415, 2280
    LastNote dw $ - Note

    CurrentSoundPos dw 0
    LastTimeSinceBeep dw 0
    SleepTime dw 0

CODESEG


proc InitSound
    push ax
    push es

    mov ax, 40h
    mov es, ax

    mov ax, [Clock]
    mov [LastTimeSinceBeep], ax

    ; open speaker
    in al, 61h
    or al, 00000011b
    out 61h, al
    ; send control word to change frequency
    mov al, 0B6h
    out 43h, al

    pop es
    pop ax
    ret
endp InitSound


proc PlayMusic
    push ax
    push bx
    push es
    
    mov bx, [CurrentSoundPos]
    cmp bx, [LastNote]
    jg @@Reset
    jmp @@NoReset

    @@Reset:
        mov [CurrentSoundPos], 0
        xor bx, bx

    @@NoReset:
        mov ax, 40h
        mov es, ax

        mov ax, [Clock]

        cmp ax, [LastTimeSinceBeep]
        je @@Quit
        mov [LastTimeSinceBeep], ax


        mov ax, [word ptr Note + bx]
        out 42h, al ; Sending lower byte
        mov al, ah
        out 42h, al ; Sending upper byte

        add [CurrentSoundPos], 2


    @@Quit:
        pop es
        pop bx
        pop ax
        ret
endp PlayMusic


proc StopMusic
    push ax

    ; close the speaker
    in al, 61h
    and al, 11111100b
    out 61h, al

    pop ax
    ret
endp StopMusic