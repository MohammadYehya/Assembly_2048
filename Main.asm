INCLUDE IRVINE32.inc
.data
Title_2048 BYTE "2048",0
WonText BYTE "You Have Won!",0
LostText BYTE "You Have Lost!",0
MaxHorizontalLength WORD ?
MaxVerticalLength WORD ?
Grid DWORD 4 DUP(4 DUP(0))
colorArr BYTE 0FFh, 0FFh, 0E0h, 060h, 0C0h, 040h, 0D0h, 050h, 09Fh, 01Fh, 0AFh, 02Fh, 034h
CreditStrings	BYTE "Mohammad Yehya K213309",0,"Muhammad Sufyan K213206",0,"Press any key to Continue..."
Instructions1 BYTE "The aim of the game is simple. You have to get the number form the number 2048.",0
Instructions2 BYTE "You can only add same numbers, for example 2 can only add with 2 and 4 can only add with 4.",0
Instructions3 BYTE "If there are no more numbers that can be added on the board then it is Game over!",0
MenuStrings BYTE "Play",0
			BYTE "Instructions",0
			BYTE "Exit",0
MenuArr DWORD 0,5,13
row DWORD 4
added DWORD 4 DUP(4 DUP(0))
_Space BYTE " ",0
DivChecker DWORD 10
NumberOfSpace BYTE 3
a DWORD ?
i DWORD ?
j DWORD ?
count DWORD 0

.code
MAIN PROC
call Asm2048
exit
MAIN ENDP
;------------------------------------------------------
;A function that combines all the functions
Asm2048  PROC
;------------------------------------------------------
call Randomize
	call PrintTitle
	call Credits
	call CLRSCR
MenuCall:
	call PrintTitle
	call Menu
	call CLRSCR
	cmp eax, 0
	je PlayGame
	cmp eax, 1
	je Instructions
	cmp eax, 2
	je leaveApp
Instructions:
	call WriteInstructions
	call CLRSCR
	jmp MenuCall
PlayGame:
	cmp eax, 0
	je DontUpdate
	call UpdateGrid
DontUpdate:call PrintTitle
	call PrintGrid
	call GameWon
	cmp eax, 1
	je Won
	call GameLost
	cmp eax, 1
	je Lost
	call KeyStroke
	jmp PlayGame
Won:mov edx, OFFSET WonText
	jmp Print
Lost:mov edx, OFFSET LostText
Print: call WriteString
	call readchar
	call ResetGrid
	call CLRSCR
	jmp MenuCall
leaveApp:
ret
Asm2048 ENDP
;------------------------------------------------------
;Simple Function to write instructions on the screen
WriteInstructions PROC USES eax
;------------------------------------------------------
call PrintTitle
	mov ah, BYTE PTR MaxHorizontalLength
	mov al, BYTE PTR MaxVerticalLength
	shr ah, 4
	mov edx, eax
	call GotoXY
	inc ah
	mov edx, OFFSET Instructions1
	call WriteString
	call CRLF
	mov edx, eax
	call GotoXY
	inc ah
	mov edx, OFFSET Instructions2
	call WriteString
	call CRLF
	mov edx, eax
	call GotoXY
	inc ah
	mov edx, OFFSET Instructions3
	call WriteString
	call CRLF
	call readchar
ret
WriteInstructions ENDP
;------------------------------------------------------
;A function used to set all elements in the grid to zero
ResetGrid PROC
;------------------------------------------------------
	mov esi, OFFSET Grid
	mov eax, 0
	mov ebx, 0
	ResetLoop:
	cmp ebx , 16
	jge ResetDone
	mov [esi + ebx*TYPE Grid], eax
	inc ebx
	jmp ResetLoop
	ResetDone:ret
ResetGrid ENDP
;------------------------------------------------------
;A function to implement the functionality of a Main menu
Menu PROC USES ecx
;------------------------------------------------------
	mov ecx, 0
	EnterNotPressed:
		mov ebx, 0
		mov edx, OFFSET MenuStrings
		cmp ecx, 0
		jl MovGreater
		cmp ecx, 2
		jng PrintMenu
		mov ecx, 0
		PrintMenu:
			add edx, MenuArr[ebx * TYPE DWORD]
			push eax
			cmp ecx , ebx
			jne WritingString
			mov eax, 04h
			call SetTextColor
		WritingString: 
			push edx
			mov dh, BYTE PTR MaxHorizontalLength
			mov dl, BYTE PTR MaxVerticalLength
			shr dh, 4
			add dh, bl
			call GoToXY
			pop edx
			call WriteString
			mov eax, 0Fh
			call SetTextColor
			pop eax
			call Crlf
			cmp ebx, 2
			je MenuDone
			inc ebx
			jmp PrintMenu
		MenuDone:
			call readchar
			cmp ax, 5000h
			je increment
			cmp ax, 4800h
			je decrement
			jne checkEnter
		increment: inc ecx
			jmp EnterNotPressed
		decrement: dec ecx
			jmp EnterNotPressed
		checkEnter:
			cmp ax, 1C0Dh
			jne EnterNotPressed
			mov eax, ecx
			jmp MenuRet
		MovGreater:mov ecx, 2
			jmp PrintMenu
	MenuRet:ret
Menu ENDP
;------------------------------------------------------
;A simple function to write the credits on the screen
Credits PROC
;------------------------------------------------------
	mov dh, BYTE PTR MaxHorizontalLength
	mov dl, BYTE PTR MaxVerticalLength
	shr dh, 4
	call GoToXY
	mov ebx, OFFSET CreditStrings
	mov ecx, LENGTHOF CreditStrings
	mov esi,0
PrintCredits:
	cmp esi, ecx
	jge CreditsRet
	mov al, [ebx+esi]
	cmp al, 0
	je LineBreaker
	call WriteChar
	mov eax, 100
	call delay
	jmp IncrementCredits
LineBreaker:	inc dh
	call GoToXY
	mov eax, 2000
	call delay
IncrementCredits: inc esi
	jmp PrintCredits
CreditsRet:call readchar
ret
Credits ENDP
;------------------------------------------------------
;A simple function to print the title
PrintTitle PROC USES eax edx
;------------------------------------------------------
	call GetMaxXY
	mov MaxHorizontalLength, dx
	mov MaxVerticalLength, ax
	add al, 8
	mov dl, al
	call GoToXY
	mov edx, OFFSET Title_2048
	call writestring
	call crlf
	ret
PrintTitle ENDP
;------------------------------------------------------
;A simple function to check whether the Grid is empty of not; Value set in EAX
IsFull PROC USES ecx
;------------------------------------------------------
	mov ecx, 0
CheckingGrid:
	cmp ecx, 16
	jge CheckingGridFin
	cmp Grid[ecx * TYPE DWORD], 0
	je CheckingGridNot
	inc ecx
	jmp CheckingGrid
CheckingGridNot:
	mov eax, 0
	jmp CheckingGridRet
CheckingGridFin:
	mov eax, 1
CheckingGridRet:ret
IsFull ENDP
;------------------------------------------------------
;A function that puts a value in a random spot on the Grid; Value set in EAX
UpdateGrid PROC USES ebx
;------------------------------------------------------
	call IsFull
	cmp eax, 1
	je UpdateGridRet
FindSpot:
	mov eax, 16
	call RandomRange
	mov ebx, Grid[eax * TYPE DWORD]
	cmp ebx, 0
	je FoundSpot
	jmp FindSpot
FoundSpot:	mov Grid[eax * TYPE DWORD], 2
UpdateGridRet:ret
UpdateGrid ENDP
;------------------------------------------------------
;A simple function that checks if there is a '2048' on the grid; Value set in EAX
GameWon PROC
;------------------------------------------------------
	mov ecx, 0
GameWin:
	cmp ecx, 16
	jge GameNotWin
	cmp Grid[ecx * TYPE DWORD], 2048
	je Win
	inc ecx
	jmp GameWin
GameNotWin:
	mov eax, 0
	jmp GameWinRet
Win:	mov eax, 1
GameWinRet:ret
GameWon ENDP
;------------------------------------------------------
;A funuction that checks if there are no more possible combinations; Value set in EAX
GameLost PROC
;------------------------------------------------------
	call IsFull
	cmp eax, 0
	je LostRet
	mov ecx, 0
	mov ebx, 0
LostHorizontal:
	cmp ecx, 16
	jge LostHorizontalFin
	mov edx, ecx
	inc edx
	cmp ebx, 3
	je resetHorizontalEBX
	mov eax, Grid[ecx* TYPE DWORD]
	cmp eax, Grid[edx * TYPE DWORD]
	je NotLost
	inc ebx
contHorizontal: inc ecx
	jmp LostHorizontal
LostHorizontalFin:
	mov ecx, 0
	mov ebx, 0
LostVertical:
	cmp ecx, 16
	jge LostVerticalFin
	mov edx, ecx
	add edx, 4
	cmp ebx, 12
	je resetVerticalEBX
	mov eax, Grid[ecx * TYPE DWORD]
	cmp eax, Grid[edx * TYPE DWORD]
	je NotLost
	add ebx, 4
	add ecx, 4
contVertical: jmp LostVertical
LostVerticalFin:
	mov eax, 1
	jmp LostRet
NotLost:mov eax, 0
	jmp LostRet
resetHorizontalEBX: mov ebx,0
	jmp contHorizontal
resetVerticalEBX: mov ebx,0
	mov edx, 0
	mov eax, ecx
	DIV row
	mov ecx, edx
	inc ecx
	jmp contVertical
LostRet: ret
GameLost ENDP
;------------------------------------------------------
;A simple function that prints the Grid
PrintGrid PROC
;------------------------------------------------------
	PUSHAD
	call GetMaxXY
	mov MaxHorizontalLength, dx
	mov MaxVerticalLength, ax
	mov dl, al
	mov ecx, 4
	mov eax, 0
	mov ebx, 0
L1:
	PUSH ecx
	mov ecx, 4
	inc dh
	call GotoXY
	L2:
		mov eax, grid[ebx * TYPE grid]
		call CheckColor
		call GetSpacedNumber
		inc ebx
		LOOP L2
	call crlf
	POP ecx
	LOOP L1
	POPAD
	call crlf
	ret
PrintGrid ENDP
;------------------------------------------------------
;A recursive function to calculate the spaces between numbers
GetNumberSpaceOccupied PROC USES eax edx
;------------------------------------------------------
	mov edx, 0
	cmp eax, 10
	jl then
	div DivChecker
	dec NumberOfSpace
	call GetNumberSpaceOccupied
then: ret
GetNumberSpaceOccupied ENDP
;------------------------------------------------------
;A utility function for the above function
GetSpacedNumber PROC USES ecx edx
;------------------------------------------------------
	call GetNumberSpaceOccupied
	mov edx, OFFSET _Space
	movzx ecx, NumberOfSpace
	cmp ecx, 0
	jle then
L1: call WriteString
	LOOP L1
then:
	call WriteDec
	mov eax, 0Fh
	call SetTextColor
	mov NumberOfSpace, 3
ret
GetSpacedNumber ENDP
;------------------------------------------------------
;A function that sets the color in the grid according to the number
CheckColor PROC uses eax
;------------------------------------------------------
zero:
	cmp eax, 0
	je LoopFinish
	shr eax, 1
	inc count
	jmp zero
LoopFinish:
	mov eax, count
	movzx eax, ColorArr[eax]
	call SetTextColor
	mov eax, 0
	mov count, eax
ret
CheckColor ENDP
;------------------------------------------------------
;A function that checks the entered key and moves the grid in accordance; Value set in EAX
Keystroke PROC
;------------------------------------------------------
	mov esi, OFFSET grid
	mov edi, OFFSET added
	call ReadChar
	cmp eax, 4800H		;Up
	je PerformMoveUp
	cmp eax, 5000H		;Down
	je PerformMoveDown
	cmp eax, 4B00H		;Left
	je PerformMoveLeft
	cmp eax, 4D00H		;Right
	je PerformMoveRight
	push 0
	jne EndStroke
PerformMoveUp:
	push 1
	mov ecx, 0
	L1Up:
		cmp ecx, 4
		jge EndStroke
		mov i, ecx
		mov ecx, 1
		L2Up:
			cmp ecx, 4
			jge EndL2Up
			mov j, ecx
			mov a, ecx
			L3Up:
				cmp ecx, 0
				jle EndL3Up
				mov eax, ecx
				dec eax
				MUL row
				add eax , i
				shl eax, 2
				mov edx, a
				IMUL edx, row
				add edx, i
				shl edx, 2
				mov ebx, 0
				cmp [esi + eax], ebx
				jne elseifUp
				mov ebx, [esi + edx]
				mov [esi + eax], ebx
				mov ebx, 0
				mov [esi + edx], ebx
				dec a
				jmp LOOPL3Up
			elseifUp:
				PUSH eax
				PUSH edx
				mov eax, [esi + eax]
				mov edx, [esi + edx]
				cmp eax, edx
				jne POPUpBreak
				POP edx
				POP eax
				PUSH eax
				PUSH edx
				mov eax, [edi + eax]
				mov edx, [edi + edx]
				cmp eax , 0
				jne POPUp
				cmp edx, 0
				jne POPUp
				POP edx
				POP eax
				PUSH eax
				mov eax, [esi + eax]
				shl eax, 1
				mov ebx, eax
				POP eax
				mov [esi + eax], ebx
				mov ebx , 0
				mov [esi + edx], ebx
				inc ebx
				mov [edi + eax], ebx
				jmp LOOPL3Up
			POPUpbreak:
				POP edx
				POP eax
				jmp EndL3Up
			POPUp:
				POP edx
				POP eax
			LOOPL3Up:
				dec ecx
				jmp L3Up
			EndL3Up:
			mov ecx, j
			inc ecx
			jmp L2Up
		EndL2Up:
		mov ecx, i
		inc ecx
		jmp L1Up
	EndL1Up:
PerformMoveDown:
	push 1
	mov ecx, 0
	L1Down:
		cmp ecx, 4
		jge EndStroke
		mov i, ecx
		mov ecx, 2
		L2Down:
			cmp ecx, 0
			jl EndL2Down
			mov j, ecx
			mov a, ecx
			L3Down:
				cmp ecx, 3
				jge EndL3Down
				mov eax, ecx
				inc eax
				MUL row
				add eax , i
				shl eax, 2
				mov edx, a
				IMUL edx, row
				add edx, i
				shl edx, 2
				mov ebx, 0
				cmp [esi + eax], ebx
				jne elseifDown
				mov ebx, [esi + edx]
				mov [esi + eax], ebx
				mov ebx, 0
				mov [esi + edx], ebx
				inc a
				jmp LOOPDown
			elseifDown:
				PUSH eax
				PUSH edx
				mov eax, [esi + eax]
				mov edx, [esi + edx]
				cmp eax, edx
				jne POPDownbreak
				POP edx
				POP eax
				PUSH eax
				PUSH edx
				mov eax, [edi + eax]
				mov edx, [edi + edx]
				cmp eax , 0
				jne POPDown
				cmp edx, 0
				jne POPDown
				POP edx
				POP eax
				PUSH eax
				mov eax, [esi + eax]
				shl eax, 1
				mov ebx, eax
				POP eax
				mov [esi + eax], ebx
				mov ebx , 0
				mov [esi + edx], ebx
				inc ebx
				mov [edi + eax], ebx
				jmp LOOPDown
			POPDownbreak:
				POP edx
				POP eax
				jmp EndL3Down
			POPDown:
				POP edx
				POP eax
			LOOPDown:
				inc ecx
				jmp L3Down
			EndL3Down:
			mov ecx, j
			dec ecx
			jmp L2Down
		EndL2Down:
		mov ecx, i
		inc ecx
		jmp L1Down
	EndL1Down:
PerformMoveLeft:
	push 1
	mov ecx, 0
	L1Left:
		cmp ecx, 4
		jge EndStroke
		mov i, ecx
		mov ecx, 1
		L2Left:
			cmp ecx, 4
			jge EndL2Left
			mov j, ecx
			mov a, ecx
			L3Left:
				cmp ecx, 0
				jle EndL3Left
				mov eax, ecx
				dec eax
				mov ebx, i
				IMUL ebx , row
				add eax , ebx
				shl eax, 2
				mov edx, a
				add edx, ebx
				shl edx, 2
				mov ebx, 0
				cmp [esi + eax], ebx
				jne elseifLeft
				mov ebx, [esi + edx]
				mov [esi + eax], ebx
				mov ebx, 0
				mov [esi + edx], ebx
				dec a
				jmp LOOPLeft
			elseifLeft:
				PUSH eax
				PUSH edx
				mov eax, [esi + eax]
				mov edx, [esi + edx]
				cmp eax, edx
				jne POPLeftbreak
				POP edx
				POP eax
				PUSH eax
				PUSH edx
				mov eax, [edi + eax]
				mov edx, [edi + edx]
				cmp eax , 0
				jne POPLeft
				cmp edx, 0
				jne POPLeft
				POP edx
				POP eax
				PUSH eax
				mov eax, [esi + eax]
				shl eax, 1
				mov ebx, eax
				POP eax
				mov [esi + eax], ebx
				mov ebx , 0
				mov [esi + edx], ebx
				inc ebx
				mov [edi + eax], ebx
				jmp LOOPLeft
			POPLeftbreak:
				POP edx
				POP eax
				jmp EndL3Left
			POPLeft:
				POP edx
				POP eax
			LOOPLeft:
				dec ecx
				jmp L3Left
			EndL3Left:
			mov ecx, j
			inc ecx
			jmp L2Left
		EndL2Left:
		mov ecx, i
		inc ecx
		jmp L1Left
	EndL1Left:
PerformMoveRight:
	push 1
	mov ecx, 0
	L1Right:
		cmp ecx, 4
		jge EndStroke
		mov i, ecx
		mov ecx, 2
		L2Right:
			cmp ecx, 0
			jl EndL2Right
			mov j, ecx
			mov a, ecx
			L3Right:
				cmp ecx, 3
				jge EndL3Right
				mov eax, ecx
				inc eax
				mov ebx, i
				IMUL ebx , row
				add eax , ebx
				shl eax, 2
				mov edx, a
				add edx, ebx
				shl edx, 2
				mov ebx, 0
				cmp [esi + eax], ebx
				jne elseifRight
				mov ebx, [esi + edx]
				mov [esi + eax], ebx
				mov ebx, 0
				mov [esi + edx], ebx
				inc a
				jmp LOOPRight
			elseifRight:
				PUSH eax
				PUSH edx
				mov eax, [esi + eax]
				mov edx, [esi + edx]
				cmp eax, edx
				jne POPRightbreak
				POP edx
				POP eax
				PUSH eax
				PUSH edx
				mov eax, [edi + eax]
				mov edx, [edi + edx]
				cmp eax , 0
				jne POPRight
				cmp edx, 0
				jne POPRight
				POP edx
				POP eax
				PUSH eax
				mov eax, [esi + eax]
				shl eax, 1
				mov ebx, eax
				POP eax
				mov [esi + eax], ebx
				mov ebx , 0
				mov [esi + edx], ebx
				inc ebx
				mov [edi + eax], ebx
				jmp LOOPRight
			POPRightbreak:
				POP edx
				POP eax
				jmp EndL3Right
			POPRight:
				POP edx
				POP eax
			LOOPRight:
				inc ecx
				jmp L3Right
			EndL3Right:
			mov ecx, j
			dec ecx
			jmp L2Right
		EndL2Right:
		mov ecx, i
		inc ecx
		jmp L1Right
	EndL1Right:
EndStroke:
	mov ecx, 16
	mov ebx, 0
RestoreAdded:
	mov eax, ecx
	dec eax
	mov added[eax*TYPE DWORD], ebx
	LOOP RestoreAdded
	pop eax
ret
Keystroke ENDP
END MAIN
END