IDEAL
MODEL small
 
 

STACK 150h
 
BMP_WIDTH = 320
BMP_HEIGHT = 200


include "src/graphics/graphics.asm"
include "src/input/mouse.asm"
include "src/input/buttons.asm"
include "src/game/mario.asm"
include "src/game/dk.asm"
include "src/game/peach.asm"
include "src/game/barrels.asm"
include "src/input/keyboard.asm"
include "src/other/timer.asm"
include "src/game/gHelp.asm"
include "src/other/random.asm"
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