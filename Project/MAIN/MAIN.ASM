IDEAL
MODEL small
 
 

STACK 90
 
BMP_WIDTH = 320
BMP_HEIGHT = 200


include "graphics.asm"
include "mouse.asm"
include "buttons.asm"
include "mario.asm"
include "dk.asm"
include "barrels.asm"
include "keyboard.asm"
include "timer.asm"
; include "sound.asm"

DATASEG

CODESEG
 

start:
	mov ax, @data
	mov ds, ax
	
	call InitGraphics
	call InitButtons
	; call InitSound

	push 2
	call StartTimer
	push 3
	call StartTimer
	push 3
	call StopTimer

	MainLoop:
		; call PlayMusic
		call UpdateTime
		call UpdateMouse
		call CheckClickOnButton
		call DetectKey
		call UpdateMario
		call UpdateDk

		push 3
		call GetTime
		cmp al, 0F0h
		jne @@NotB
		call CreateBarrel

		push 3
		call StopTimer
		push 3
		call ResetTimer

		@@NotB:

		cmp [IsRightButtonPressed], 1
		je exit

		jmp MainLoop
	
exitError:
	; Print Error Message
    mov dx, offset BmpFileErrorMsg
	mov ah, 9
	int 21h
			
exit:
	; call StopMusic

	; Text Mode
	mov ax,2
	int 10h

	; Exit
	mov ax, 4c00h
	int 21h

END start