IDEAL
MODEL small
 
 

STACK 0f500h
 
BMP_WIDTH = 320
BMP_HEIGHT = 200


include "graphics.asm"
include "mouse.asm"
include "buttons.asm"
include "mario.asm"
include "keyboard.asm"
; include "sound.asm"

DATASEG

CODESEG
 

start:
	mov ax, @data
	mov ds, ax
	
	call InitGraphics
	call InitButtons
	; call InitSound



	MainLoop:
		; call PlayMusic
		call UpdateMouse
		call CheckClickOnButton
		call DetectKey
		call UpdateMario


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