IDEAL
MODEL small
 
 

STACK 150h
 
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
include "gHelp.asm"
include "random.asm"
; include "sound.asm"

DATASEG

CODESEG
 

start:
	mov ax, @data
	mov ds, ax
	
	call InitGraphics
	call InitButtons


	MainLoop:
		; call PlayMusic
		call UpdateTime
		call UpdateMouse
		call CheckClickOnButton
		call DetectKey
		call UpdateGame

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