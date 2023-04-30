IDEAL
MODEL small
STACK 100h

DATASEG
	Clock equ es:6Ch
	StartMessage db 'Counting 10 seconds. Start...',13,10,'$'
	EndMessage db '...Stop.',13,10,'$'

CODESEG

	start :
		mov ax, @data
		mov ds, ax
		; wait for first change in timer
		mov ax, 40h
		mov es, ax
		mov ax, [Clock]
	FirstTick :
		cmp ax, [Clock]
		je FirstTick
		; print start message
		mov dx, offset StartMessage
		mov ah, 9h
		int 21h
		; count 10 sec
		mov cx, 18 ; 182x0.055sec = ~10sec
	DelayLoop:
		mov ax, [Clock]
		Tick :
			cmp ax, [Clock]
			je Tick
	loop DelayLoop
	; print end message
		mov dx, offset EndMessage
		mov ah, 9h
		int 21h
	quit :
		mov ax, 4c00h
		int 21h
END start