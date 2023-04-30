IDEAL

MODEL small
STACK 256


DATASEG

	; The `Counters` array is a collection of 16-bit words, 
	; where the lower 4 bits represent the timer ID, 
	; the 5th bit represents whether the timer is active or not, 
	; and the upper 8 bits represent the time elapsed since the timer was started. 

	; Last byte = ID
	; Second byte from left = Is Active
	; Upper bytes = Time

	; 0000 0000 |  0000 0000
	; ↑↑↑↑↑↑↑↑↑ |  ↑↑↑↑  ↳↳↳↳ ID
	;   Timer   | IsAtive 
	Counters dw 7 dup (?)
	CountersLenght db $ - Counters

	CountersCounter db 0

	LastCount dw ?

	TicksCounter dw 0

CODESEG


;================================================
; Description - The procedure takes an argument `Id` from the stack 
; 				and adds a new timer to the `Counters` array if it doesn't already exist, or activates an existing timer if it does. 
; 				The procedure first checks if the `Counters` array is empty, 
; 				and if so, adds a new timer with the given `Id`. 
; 				If the array is not empty, it searches for an existing timer with the given `Id`. 
; 				If it finds one, it activates the timer by setting the 5th bit to 1. 
; 				If it doesn't find one, it adds a new timer with the given `Id`. 
; 				The procedure then increments the `CountersCounter` variable, 
; 				which keeps track of the number of timers in the `Counters` array, and returns.

; INPUT: Stack: ID
; OUTPUT: Memory: Counters, CountersCounter
;================================================
Id equ [bp + 4]
proc StartTimer
	push bp
	mov bp, sp
	push ax
	push bx
	push cx

	xor bx, bx 
	cmp [Counters], 0
	je @@NewCounter

	xor cx, cx
	mov cl, [CountersCounter]
	add cx, cx

	xor bx, bx
	@@FindTimer:
		mov ax, [Counters + bx]
		xor ah, ah
		and al, 00001111b
		
		cmp ax, Id
		je @@FoundTimer

		add bx, 2
		cmp bx, cx
		jne @@FindTimer

	@@NewCounter:
		mov ax, Id
		or ax, 0000000000010000b
		mov [Counters + bx], ax
		inc [CountersCounter]
		jmp @@Quit
	
	@@FoundTimer:
		or [Counters + bx], 0000000000010000b

	@@Quit:
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp StartTimer


;================================================
; Description - The `StopTimer` procedure takes an argument `Id` from the stack 
; 				and searches for an existing timer with the given `Id` in the `Counters` array. 
; 				If it finds one, it deactivates the timer by setting the 5th bit to 0. 
; 				If it doesn't find one, it does nothing. The procedure then returns.

; INPUT: Stack: ID
; OUTPUT: Memory: Counters, CountersCounter
;================================================
Id equ [bp + 4]
proc StopTimer
	push bp
	mov bp, sp
	push ax
	push bx
	push cx


	xor cx, cx
	mov cl, [CountersCounter]
	add cx, cx

	xor bx, bx
	@@FindTimer:
		mov ax, [Counters + bx]
		xor ah, ah
		and al, 00001111b
		
		cmp ax, Id
		je @@FoundTimer

		add bx, 2
		cmp bx, cx
		jne @@FindTimer

	jmp @@Quit

	@@FoundTimer:
		and [Counters + bx], 1111111111101111b

	@@Quit:
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp StopTimer


;================================================
; Description - The `ResetTimer` procedure takes an argument `Id` from the stack 
; 				and searches for an existing timer with the given `Id` in the `Counters` array. 
; 				If it finds one, it resets the timer by setting the upper 8 bits to 0. 
; 				If it doesn't find one, it does nothing. The procedure then returns.

; INPUT: Stack: ID
; OUTPUT: Memory: Counters, CountersCounter
;================================================
Id equ [bp + 4]
proc ResetTimer
	push bp
	mov bp, sp
	push ax
	push bx
	push cx


	xor cx, cx
	mov cl, [CountersCounter]
	add cx, cx

	xor bx, bx
	@@FindTimer:
		mov ax, [Counters + bx]
		xor ah, ah
		and al, 00001111b
		
		cmp ax, Id
		je @@FoundTimer

		add bx, 2
		cmp bx, cx
		jne @@FindTimer

	jmp @@Quit

	@@FoundTimer:
		and [Counters + bx], 0000000011101111b

	@@Quit:
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
endp ResetTimer


;================================================
; Description - The `GetTime` procedure takes an argument `Id` from the stack 
; 				and searches for an existing timer with the given `Id` in the `Counters` array. 
; 				If it finds one, it retrieves the time elapsed since the timer was started by 
; 				shifting the upper 8 bits of the timer's 16-bit word to the right. 
; 				If it doesn't find one, it returns 0. The procedure then returns the time elapsed since the timer was started.

; INPUT: Stack: ID
; OUTPUT: AX: Time elapsed since the timer was started.
;================================================
Id equ [bp + 4]
proc GetTime
	push bp
	mov bp, sp
	push bx
	push cx


	xor cx, cx
	mov cl, [CountersCounter]
	add cx, cx

	xor bx, bx
	@@FindTimer:
		mov ax, [Counters + bx]
		xor ah, ah
		and al, 00001111b
		
		cmp ax, Id
		je @@FoundTimer

		add bx, 2
		cmp bx, cx
		jne @@FindTimer

	xor ax, ax
	jmp @@Quit

	@@FoundTimer:
		mov ax, [Counters + bx]
		shr ax, 8

	@@Quit:
		pop cx
		pop bx
		pop bp
		ret 2
endp GetTime

;================================================
; Description - The `UpdateTime` procedure updates the timers in the `Counters` array 
; 				by incrementing the time elapsed for each active timer. 
; 				It also keeps track of the number of clock ticks that have occurred 
; 				since the last update using the `TicksCounter` variable. 
; 				The procedure uses the `LastCount` variable to keep track of the last clock count, 
; 				and compares it to the current `Clock` count to determine if a clock tick has occurred. 
; 				If a tick has occurred, the procedure increments the `TicksCounter` variable 
; 				and updates the timers in the `Counters` array. 

; INPUT: None
; OUTPUT: Memory: Counters, CountersCounter, LastCount, TicksCounter
;================================================
proc UpdateTime
	push ax
	push bx
	push cx
	push es

	cmp [CountersCounter], 0
	je @@Quit

	mov ax, 40h
	mov es, ax

	DelayLoop:
		mov ax, [LastCount]
		Tick :
			cmp ax, [Clock]
			je @@Quit

		inc [TicksCounter]
		cmp [TicksCounter], 0FFFh
		jne @@quit

	mov [TicksCounter], 0

	xor cx, cx
	mov cl, [CountersCounter]
	add cx, cx

	xor bx, bx
	@@FindActiveTime:
		mov ax, [Counters + bx]
		
		test ax, 0000000000010000b
		jnz @@Active
		jmp @@NextCounter

		@@Active:
			inc ah
			mov [Counters + bx], ax

		@@NextCounter:
			add bx, 2
			cmp bx, cx
			jne @@FindActiveTime

	@@Quit:
		pop es
		pop cx
		pop bx
		pop ax
		ret
endp UpdateTime