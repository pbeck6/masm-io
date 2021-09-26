;----------------------------------------------------------------------------------------------
; DESIGNING LOW-LEVEL I/O PROCEDURES     (low-level-i-o.asm)
;
; Author: Philip Beck
; Last Modified: 12/19/2020
; Email address: stoneroll6@gmail.com
; Description: This program showcases low-level procedures using
;			   macros (mGetString and mDisplayString) 
;              and string primitives (ReadVal and WriteVal),
;			   receiving 10 input signed integers and
;			   displaying their sum and average.
;
;----------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc


;MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MACROS-MAC

; ---------------------------------------------------------------------------------
; Name: mGetString
; Description: Macro prompts user to enter string, then saves str to mem
; Preconditions: some_prompt, some_memory, str_length is OFFSET mem
; Postconditions: EAX, ECX, EDX, EDI restored
; Receives: EDX = buffer offset, ECX = buffer size
; Returns: some_memory = str offset, str_length = length of array

mGetString MACRO some_prompt, some_memory, max_length, str_length

	pushad

	mov		EDX, some_prompt
	call	WriteString
	
	mov		EDX, some_memory							; will store in OFFSET
	mov		ECX, max_length								; will set max chars
	call	ReadString									; number of chars in EAX
	mov		EDI, str_length								; load OFFSET
	mov		[EDI], EAX									; change value at OFFSET

	popad

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
; Description: Macro displays string parameter str_offset
; Preconditions: str_offset is OFFSET (a memory address)
; Postconditions: EDX restored
; Receives: str_offset
; Returns: none

mDisplayString MACRO str_offset

	push	EDX

	mov		EDX, str_offset
	call	WriteString

	pop		EDX

ENDM

;----------------------------------------------------------------------------------------------


;CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONSTANTS-CONS

ARRAYSIZE   = 10
MAXSIZE		= 26										; max size of byte array for input


;DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA-DATA
.data

intro1		BYTE	"Designing Low-Level I/O Procedures by Philip Beck",13,10,13,10,0
intro2		BYTE	"Please provide 10 signed decimal integers.",13,10
			BYTE	"Each number must be small enough to fit inside a 32 bit register.",13,10
			BYTE	"The program will then display the input integers, their sum, ",13,10
			BYTE	"and their average value.",13,10,13,10,0
prompt		BYTE	"Please enter a signed number: ",0
reprompt	BYTE	"ERROR: Not a signed number or too large a number.",13,10
			BYTE	"Please try again: ",0
showAll		BYTE	"You entered the following numbers:",13,10,0
showSum		BYTE	"The sum of these numbers is: ",0
showAvg		BYTE	"The floor-rounded average is: ",0
lastMsg		BYTE	"Thanks and goodbye.",13,10,0
spacing		BYTE	", ",0

numString	BYTE	MAXSIZE+1 DUP(?)					; +1 makes room for null char ReadString
revString	BYTE	MAXSIZE+1 DUP(?)
stringLen	DWORD	?
numArray	SDWORD	ARRAYSIZE DUP(?)
number		SDWORD	?
sum			SDWORD	?
average		SDWORD	?


;CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE-CODE
.code
main PROC

	;--------------------
	; Introduce the program
	mDisplayString OFFSET intro1
	mDisplayString OFFSET intro2

	;--------------------
	; Prompt user to enter numbers
	push	OFFSET average
	push	OFFSET sum
	push	ARRAYSIZE
	push	OFFSET stringLen
	push	MAXSIZE
	push	OFFSET prompt								
	push	OFFSET reprompt								
	push	OFFSET numString							
	push	OFFSET numArray								
	push	OFFSET number								
	call	ReadVal

	;--------------------
	; Write the array as string
	call	CrLf
	mDisplayString OFFSET showAll
	mov		ECX, ARRAYSIZE
	mov		ESI, OFFSET numArray
_showElement:
	mov		EAX, [ESI]										; value in numArray[n]
	mov		number, EAX
	push	OFFSET revString
	push	OFFSET numString
	push	OFFSET number
	call	WriteVal
	add		ESI, TYPE SDWORD
	cmp		ECX, 1
	je		_writeSum
	mDisplayString OFFSET spacing
	loop	_showElement

	;--------------------
	; Write the sum as string
_writeSum:
	call	CrLf
	mDisplayString OFFSET showSum
	push	OFFSET revString
	push	OFFSET numString
	push	OFFSET sum
	call	WriteVal

	;--------------------
	; Write the average as string
	call	CrLf
	mDisplayString OFFSET showAvg
	push	OFFSET revString
	push	OFFSET numString
	push	OFFSET average
	call	WriteVal

	;--------------------
	; Say goodbye
	call	CrLf
	mDisplayString OFFSET lastMsg
	invoke	ExitProcess,0								; exit to operating system

main ENDP
;**********************************************************************************************

;----------------------------------------------------------------------------------------------
; Name: ReadVal
; Description: Reads string-input value of signed integer, converts to SDWORD
; Preconditions: 
; Postconditions: EAX, EBX, ECX, EDX restored
; Receives: [EBP+8] = OFFSET number, [EBP+12] = OFFSET numArray, [EBP+16] = OFFSET numString,
;			[EBP+20] = OFFSET reprompt, [EBP+24] = OFFSET prompt, [EBP+28] = MAXSIZE
;			[EBP+32] = OFFSET stringLen, [EBP+36] = ARRAYSIZE, [EBP+40] = OFFSET sum
;			[EBP+44] = OFFSET average
; Returns: numArray with ARRAYSIZE signed integers, sum SDWORD, average SDWORD

ReadVal PROC

	; Set base, preserve registers
	push	EBP
	mov		EBP, ESP
	pushad
	
	; Get string value
	mov		ECX, [EBP+36]								; ARRAYSIZE = loop counter
	mov		EDI, [EBP+12]								; OFFSET numArray
_getNumber:
	mGetString [EBP+24], [EBP+16], [EBP+28], [EBP+32]	

	; Convert str and validate, reprompt if needed
	push	[EBP+32]									; OFFSET stringLen
	push	[EBP+8]										; OFFSET number
	push	[EBP+20]									; OFFSET reprompt
	push	[EBP+16]									; OFFSET numString
	push	[EBP+28]									; MAXSIZE
	call	Validate

	; Add SDWORD to array
	mov		ESI, [EBP+8]								; OFFSET number (validated)
	mov		EAX, [ESI]									; move number value to EAX
	mov		[EDI], EAX									; replace blank array value
	add		EDI, TYPE SDWORD							; move to next blank array index

	; Add to sum
	mov		ESI, [EBP+40]								; OFFSET sum
	add		[ESI], EAX									; add number to sum

	; Loop ARRAYSIZE times
	loop	_getNumber

	; Calculate average
	push	[EBP+40]									; OFFSET sum
	push	[EBP+36]									; ARRAYSIZE
	push	[EBP+44]									; OFFSET average
	call	CalcAverage

	; Restore registers and return
	popad
	pop		EBP
	ret		40											; de-ref 8*OFFSET+2*constant = 10*DWORD = 40

ReadVal ENDP
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; Name: Validate
; Description: Validates that string-input signed integer can fit in 32-bit register
; Preconditions: numString and reprompt is str array, stringlen is int
; Postconditions: EAX, EBX, ECX, EDX, ESI, EDI restored
; Receives: [EBP+8] = MAXSIZE, [EBP+12] = OFFSET numString, [EBP+16] = OFFSET reprompt,
;			[EBP+20] = OFFSET number, [EBP+24] = OFFSET stringLen
; Returns: OFFSET number contains SDWORD int of input value

Validate PROC

	; Set base, preserve registers
	local tempNum:SDWORD, tempSign:BYTE
	pushad

	; Set local variables
	mov		tempNum, 0									; starting value (additive)
	mov		tempSign, 0									; 1 = negative
	
	; Start validation
_checkValid:
	mov		ESI, [EBP+12]								; first char of numString
	mov		EBX, [EBP+24]								; load OFFSET of str len
	mov		ECX, [EBX]									; load value of str len into counter

	; Check if first char = negative sign
	mov		EAX, 0										; clear entire register for AL
	mov		AL, 45										; ASCII 45d = negative sign
	cmp		AL, [ESI]
	je		_setNegative								; jump if negative int

	; Check if first char = positive sign
	mov		AL, 43										; ASCII 43d = positive sign
	cmp		AL, [ESI]
	jne		_continueValid								; jump if not positive sign
	inc		ESI
	cmp		ECX, 1
	je		_invalidStr									; can't input just a plus sign
	dec		ECX

_continueValid:
	mov		AL, 57										; ASCII 57d = 9
	cmp		AL, [ESI]	
	jl		_invalidStr									; jump if char > 9

	mov		AL, 48										; ASCII 48d = 0
	cmp		AL, [ESI]
	jg		_invalidStr									; jump if char < 0

	; Convert ASCII to int digit
	cld
	lodsb
	sub		EAX, 48										; single digit converted
	
	; Calculate to correct tenths place
	push	ECX											; preserve ECX for loop
	dec		ECX											; tenths place = [ECX] - 1
	cmp		ECX, 0
	jle		_collectDigits

_exponentTen:
	mov		EBX, 10
	mul		EBX
	loop	_exponentTen

_collectDigits:
	pop		ECX
	add		tempNum, EAX
	jo		_invalidStr
	mov		EAX, 0
	loop	_continueValid
	jmp		_checkSign
	
_setNegative:
	mov		tempSign, 1									; use mem to hold sign
	inc		ESI
	cmp		ECX, 1
	je		_invalidStr									; can't input just a minus sign
	dec		ECX
	jmp		_continueValid

	; Get new string value
_invalidStr:
	mov		tempNum, 0
	mov		tempSign, 0
	mGetString [EBP+16], [EBP+12], [EBP+8], [EBP+24]
	jmp		_checkValid

	; Set negative sign
_checkSign:
	cmp		tempSign, 1
	je		_addSign
	jmp		_finishValid
_addSign:
	mov		EAX, tempNum
	imul	EAX, -1
	mov		tempNum, EAX

	; Move local variable to global
_finishValid:
	mov		EDI, [EBP+20]
	mov		EAX, tempNum
	mov		[EDI], EAX

	; Restore registers and return
	popad
	ret		20											; de-ref 4 OFFSET + constant = 5 * DWORD = 20

Validate ENDP
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; Name: CalcAverage
; Description: Calculates the average of integers in an array, floor rounded
; Preconditions: sum is initialized signed int, average is offset, arraysize is int
; Postconditions: EAX, EBX, EDX restored
; Receives: [EBP+8] = OFFSET average, [EBP+12] = ARRAYSIZE, [EBP+16] = OFFSET sum,
; Returns: average SDWORD contains the average

CalcAverage PROC

	; Set base, preserve registers
	push	EBP
	mov		EBP, ESP
	pushad

	; Divide sum by total elements
	mov		ESI, [EBP+16]
	mov		EBX, [EBP+12]								; EBX holds number of elements
	mov		EAX, [ESI]									; EAX holds sum
	cdq
	idiv	EBX

	; Move to average global variable
	mov		EDI, [EBP+8]
	mov		[EDI], EAX

	; Restore registers and return
	popad
	pop		EBP
	ret		12											; de-ref 2 OFFSET + constant = 3 * DWORD = 12

CalcAverage ENDP
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
; Name: WriteVal
; Description: Displays signed int as string using WriteString
; Preconditions: some_value is OFFSET of signed int, output_string is OFFSET of string array
; Postconditions: 
; Receives: [EBP+8] = OFFSET some_number, [EBP+12] = OFFSET output_string, [EBP+16] = OFFSET revString
; Returns: none

WriteVal PROC

	; Set base, preserve registers
	local tempNum:SDWORD, singleDigit:SDWORD, negativeSign:BYTE
	pushad

	; Load number and string
	mov		ESI, [EBP+8]								; OFFSET of some_number
	mov		EAX, [ESI]									
	mov		tempNum, EAX
	mov		EDI, [EBP+16]								; OFFSET of revString
	mov		negativeSign, 0
	mov		ECX, 0										; counter for reverse loop
	
	; Strip negative sign, if any
	cmp		tempNum, 0
	jns		_convertDigits								; skip to digit conversion if positive
	mov		EAX, tempNum
	mov		EBX, -1
	imul	EBX
	mov		tempNum, EAX
	mov		negativeSign, 1								; set = negative sign

	; Divide by 10, add remainder to string
_convertDigits:
	mov		EBX, 10
	mov		EAX, tempNum
	cdq
	idiv	EBX											
	mov		tempNum, EAX								; quotient strips last place digit
	mov		singleDigit, EDX							; remainder holds last place digit

_addToString:
	mov		EAX, 0										; clear EAX for AL operations
	mov		AL, BYTE PTR singleDigit					; add last place digit to string
	add		AL, 48										; ASCII 48d = '0'
	cld
	stosb
	inc		ECX
	cmp		tempNum, 0									; last digit will leave quotient as 0
	jne		_convertDigits

	; Add negative sign to string
	cmp		negativeSign, 0
	je		_reverseTheStr
	mov		EAX, 0										; clear EAX for AL operations
	mov		AL, 45										; ASCII 45d = negative sign
	inc		ECX
	cld
	stosb

	; Reverse string (from StringManipulator.asm by Prof. Redfield @ Oregon State)
_reverseTheStr:
	mov    ESI, [EBP+16]								; OFFSET of revString
	add    ESI, ECX										; ECX = string length
	dec    ESI
	mov    EDI, [EBP+12]								; OFFSET of output_string
_revLoop:
    std
    lodsb
    cld
    stosb
    loop   _revLoop
	;-------------------------------------------------------------------------------

	; Terminate the string
	mov		AL, 0
	stosb

	; Display the string
	mDisplayString [EBP+12]

	; Restore registers and return
	popad
	ret		12											; de-ref OFFSET = 3 * DWORD = 12

WriteVal ENDP
;----------------------------------------------------------------------------------------------

;**********************************************************************************************
END main
;**********************************************************************************************