IDEAL
MODEL small
 
 

STACK 150h
 
BMP_WIDTH = 320
BMP_HEIGHT = 200


include "graphics/graphics.asm"
include "input/mouse.asm"
include "input/buttons.asm"
include "game/mario.asm"
include "game/dk.asm"
include "game/peach.asm"
include "game/barrels.asm"
include "input/keyboard.asm"
include "other/timer.asm"
include "game/gHelp.asm"
include "other/random.asm"

DATASEG

CODESEG
 

start:
	mov ax, @data
	mov ds, ax
	
	call InitGraphics
	call InitButtons


	MainLoop:
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
	; Text Mode
	mov ax,2
	int 10h

	; Exit
	mov ax, 4c00h
	int 21h

END start