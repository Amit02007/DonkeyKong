IDEAL

MODEL small
STACK 150h


MAX_BUTTON_NUMBER = 20


DATASEG
	; Button Params: Screen, Start x, Start y, End x, End y, On Click
	Buttons dw MAX_BUTTON_NUMBER dup (6 dup (?))

	CurrentButtonPlace dw 0

CODESEG


; ---------- On click ----------

SwitchToGameScreen:

	push 0
	push 0
	push Offset EmptyCursor
	call ChangeCursor

	CHANGE_BACKGROUND 1

    call ResetLives
	call InitGame
	
jmp ButtonOnClickReturn


BackFromPause:
	push ax
	push bx
	push dx
	push di

	CHANGE_BACKGROUND 1

	call ShowAllBarrels

	push [CurrentMarioImage]
	call ChangeMarioImage
		
	push [CurrentDkImage]
	call ChangeDkImage

	push [CurrentPeachImage]
	call ChangePeachImage

	call ShowLives

	; Show Score
	mov ah, 2
	mov bh, 0
	push 3
	push 1
	call ConvertMatrixPos
	mov dx, di
	int 10h

	mov ah, 9
	lea dx, [Score]
	int 21h

	; Hide cruser
	mov ax, 02h
	int 33h
	
	pop di
	pop dx
	pop bx
	pop ax
jmp ButtonOnClickReturn


SwitchToHelpScreen:

	CHANGE_BACKGROUND 2
	
jmp ButtonOnClickReturn


SwitchToMenuScreen:

	CHANGE_BACKGROUND 0
	
jmp ButtonOnClickReturn


ChangeSkin:

	CHANGE_BACKGROUND 6

	cmp [MarioFileName], "1"
	je ChangToMarioSkin

	cmp [MarioFileName], "2"
	je ChangToLuigiSkin

	cmp [MarioFileName], "3"
	je ChangToWarioSkin

jmp ButtonOnClickReturn


ChangToMarioSkin:

	CHANGE_BACKGROUND 6

	mov [color], 0fh
	mov [SquareSize], 65
	mov [Xp], 41
	mov [Yp], 57
	call DrawSquare

	mov [MarioFileName], "1"
	mov [LivesFileName], "1"

jmp ButtonOnClickReturn


ChangToLuigiSkin:

	CHANGE_BACKGROUND 6

	mov [color], 0fh
	mov [SquareSize], 65
	mov [Xp], 212
	mov [Yp], 57
	call DrawSquare

	mov [MarioFileName], "2"
	mov [LivesFileName], "2"

jmp ButtonOnClickReturn


ChangToWarioSkin:

	CHANGE_BACKGROUND 6

	mov [color], 0fh
	mov [SquareSize], 65
	mov [Xp], 127
	mov [Yp], 57
	call DrawSquare

	mov [MarioFileName], "3"
	mov [LivesFileName], "3"

jmp ButtonOnClickReturn




; ---------- Functions ----------

;================================================
; Description - Initialize the buttons
; INPUT: None
; OUTPUT: None
;================================================
proc InitButtons

	; ------- Menu -------
	; Play Button
	push 0
	push 113
	push 128
	push 202
	push 146
	push offset SwitchToGameScreen
	call CreateButton

	; Help Button
	push 0
	push 113
	push 153
	push 202
	push 170
	push offset SwitchToHelpScreen
	call CreateButton

	; Exit Button
	push 0
	push 113
	push 177
	push 202
	push 194
	push offset Exit
	call CreateButton

	; Change Skin
	push 0
	push 74
	push 79
	push 88
	push 85
	push offset ChangeSkin
	call CreateButton


	; ------- Help -------
	; Back Button
	push 2
	push 221
	push 171
	push 310
	push 189
	push offset SwitchToMenuScreen
	call CreateButton


	; ------- Pause -------
	; Continue
	push 3
	push 116
	push 23
	push 205
	push 41
	push offset BackFromPause
	call CreateButton

	; Quit Button
	push 3
	push 116
	push 54
	push 205
	push 72
	push offset SwitchToMenuScreen
	call CreateButton



	; ------- Game Over -------
	; Quit Button
	push 4
	push 17
	push 149
	push 106
	push 167
	push offset Exit
	call CreateButton

	; Retry Button
	push 4
	push 116
	push 149
	push 205
	push 167
	push offset SwitchToGameScreen
	call CreateButton

	; Back To Menu Button
	push 4
	push 215
	push 149
	push 304
	push 167
	push offset SwitchToMenuScreen
	call CreateButton
	
	
	
	; ------- You Won -------
	; Quit Button
	push 5
	push 17
	push 149
	push 106
	push 167
	push offset Exit
	call CreateButton

	; Retry Button
	push 5
	push 116
	push 149
	push 205
	push 167
	push offset SwitchToGameScreen
	call CreateButton

	; Back To Menu Button
	push 5
	push 215
	push 149
	push 304
	push 167
	push offset SwitchToMenuScreen
	call CreateButton



	; ------- Change Skin -------
	; Back Button
	push 6
	push 115
	push 173
	push 204
	push 191
	push offset SwitchToMenuScreen
	call CreateButton

	; Select Mario
	push 6
	push 51
	push 58
	push 98
	push 121
	push offset ChangToMarioSkin
	call CreateButton

	; Select Luigi
	push 6
	push 224
	push 58
	push 271
	push 121
	push offset ChangToLuigiSkin
	call CreateButton

	; Select Wario
	push 6
	push 137
	push 58
	push 181
	push 121
	push offset ChangToWarioSkin
	call CreateButton



	ret
endp InitButtons


;================================================
; Description - Creates a button by taking in parameters from the stack and adding them to an array called `Buttons`. 
;				The procedure uses a loop to add each parameter to the array 
;				and then updates the value of `CurrentButtonPlace` to point to the next available index in the array. 
; INPUT: Stack: Screen
;				StartX
;				StartY
;				EndX
;				EndY
;				OnClick
; OUTPUT: Memory: Buttons
;================================================
proc CreateButton
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push si

	mov cx, 6
	mov si, 14
	mov bx, [CurrentButtonPlace]
	@@AddToButtonsArray:
		mov ax, [bp + si]
		mov [word ptr Buttons + bx], ax

		sub si, 2
		add bx, 2
	loop @@AddToButtonsArray

	mov [CurrentButtonPlace], bx
	

	pop si
	pop cx
	pop bx
	pop ax
	pop bp
	ret 12
endp CreateButton


;================================================
; Description - Draw a rectangular button on the screen and add it to the `Buttons` array using the `CreateButton` procedure.
; INPUT: Stack: Screen
;				StartX
;				StartY
;				EndX
;				EndY
;				ButtonColor
;				OnClick
; OUTPUT: Memory: Buttons
;================================================
Screen equ [bp + 16]
StartX equ [bp + 14]
StartY equ [bp + 12]
EndX equ [bp + 10]
EndY equ [bp + 8]
ButtonColor equ [bp + 6]
OnClick equ [bp + 4]
proc CreateVisualButton
	push bp
	mov bp, sp
	push ax
	push cx
	push dx
	push si
	push di

	mov ax, ButtonColor
	mov cx, StartX
	mov dx, StartY
	mov si, EndX
	mov di, EndY
	call Rect

	push Screen
	push StartX
	push StartY
	push EndX
	push EndY
	push OnClick
	call CreateButton

	pop di
	pop si
	pop dx
	pop cx
	pop ax
	pop bp
	ret 14
endp CreateVisualButton


;================================================
; Description - This procedure checks if the mouse click is on any of the buttons created in the `Buttons` array.
;				It loops through the array and checks if the current screen matches the screen of the button.
;				If it does, it checks if the mouse click is within the boundaries of the button.  
;				If it is, it changes the cursor to a click cursor and waits for the left mouse button to be pressed.
;				If the left mouse button is pressed, it jumps to the `OnClick` address stored in the button's array.
;				If the mouse click is not on any button, it changes the cursor back to the default cursor.
; INPUT: None
; OUTPUT: None
;================================================
proc CheckClickOnButton
	push ax
	push bx
	push cx

	xor ax, ax
	mov al, [CurrentScreen]
	mov dx, ax
	xor bx, bx
	jmp @@FindCurrentScreen
	@@NextButton:
		mov ax, dx
		add bx, 12
		cmp bx, [CurrentButtonPlace]
		jg @@NotOnButton
	; Checks if the current screen matches the screen of the button
	@@FindCurrentScreen:
		cmp [word ptr Buttons + bx], ax
		je @@FindXY ; If it does, it checks if the mouse click is within the boundaries of the button
		add bx, 12
		cmp bx, [CurrentButtonPlace]
		jg @@NotOnButton ; If the loop pass all the buttons
		jmp @@FindCurrentScreen

	
	@@FindXY:
		; Check the boundaries of the button
		mov ax, [word ptr Buttons + bx + 2]
		cmp ax, [word ptr MousePosX]
		ja @@NextButton

		mov ax, [word ptr Buttons + bx + 4]
		cmp ax, [word ptr MousePosY] 
		ja @@NextButton

		mov ax, [word ptr Buttons + bx + 6]
		cmp ax, [word ptr MousePosX]
		jb @@NextButton

		mov ax, [word ptr Buttons + bx + 8]
		cmp ax, [word ptr MousePosY]
		jb @@NextButton
		
		; Changes the cursor to a click cursor and waits for the left mouse button to be pressed
		push 3
		push 0
		push offset ClickCursor
		call ChangeCursor

		cmp [IsLeftButtonPressed], 1
		jne @@Quit

		mov ax, [word ptr Buttons + bx + 10]
		jmp ax

	ButtonOnClickReturn: ; All the buttons click methods return to here
		push 250
		call sleep_ms

	; If the mouse is not on a button return the default cursor
	@@NotOnButton:
		push 0
		push 0
		push offset DefaultCursor
		call ChangeCursor

	@@Quit:
		pop cx
		pop bx
		pop ax
		ret
endp CheckClickOnButton



