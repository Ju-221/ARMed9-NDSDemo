; -----------------------------------------------------------------------------
; File:            SandboxWithHeaders.s
; Author:          Juan Vargas
; Date:            October 29, 2025
; Source:          Adapted from - https://www.youtube.com/watch?v=YUO7gDDuZAM
;
; Description:
;   Nintendo DS assembly source file.
;   Compile for the NDS only. Do not compile for DSi unless you know what
;   you are fully aware of the hardware differences and implications.
;
; License:
;   This work is licensed under the Creative Commons Attribution (CC BY) License.
;   You are free to share and adapt this material with appropriate credit.
; -----------------------------------------------------------------------------

.include "Headers\V1_Header.asm"

;=====================================
; AMR7 CPU code - usually for buttons
;=====================================
Arm7_Start:
	b Arm7_Start		;Infloop for the ARM 7 CPU
Arm7_End:


.equ userram,0x02F10000	;4byte long register
.equ RamArea,0x02F00000
.equ MonitorWidth, 8
;default console color
;  					ABBBBBGGGGGRRRRR	A=Alpha
.equ ColorScreen, 0b1000000000000000 ;default black
.equ delayCounter, 0xFFFF ; 1cc - 1/66mhz 


Arm9_Start:
	mov sp,#0x03000000 ;init Stack pointer

	bl ScreenInit
	bl FillScreen
	bl NewLine

	ldr r1, Txt2ScreenAddress
	bl PrintString
	
	b TestReadWriteRam
	
Txt2ScreenAddress:
	.long Txt2Screen			;Pointer to string message
Txt2Screen:
	.byte "COEN 311 S - (Juan)",255
	.align 4	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test code

TestReadWriteRam:	;Test Reading And Writing Ram
			
	bl ShowTestRam		;show 'TestVal' ram
	bl NewLine
	
	;mov r0,#0xFFFF0000	;Reset R0
	;add r0,r0,#0xFFFF	;Reset R0
	
	;bl MonitorRegisters		;Show the regs
		
	ldrB r0,TestVal		;Load BYTE r0 from address TestVal
	
	add r0,r0,#0xFF		;add a value 
	strB r0,TestVal		;Store BYTE R0 into the address in R2
	bl ShowTestRam
	bl NewLine
	
	bl MonitorRegisters
	;bl WriteLoopCounter	
	
	b endCode


endCode:
	b endCode	; inf loop to end the code

.align 4				;We need to make sure we're aligned to a 32 bit boundsry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteLoopCounter:
	STMFD sp!,{r0-r12, lr}	
	mov r4,#0
	ldr r5, TestVal
	
WriteLoop:
    cmp r4, #17             ; if r4 == 17 -> done
    ;beq endCode

    strb r4, [r5]           ; write byte (0–16) to TestVal
    ldrb r0, [r5]           ; read it back into r0
  	bl Delay				; artificial delay 7FFF seconds 
	
    add r4, r4, #1          ; increment counter
	b DoneWriteLoop

DoneWriteLoop:
    LDMFD sp!, {r0-r12, lr}     ; restore regs
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowTestRam:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		adr	r0,TestVal		;Address
		mov r1,#1			;Lines
		bl MemDump
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
;We can load a register from a label with LDR, and store it back with STR
TestVal: 
	.long 0xEFBE
	.align 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ShowUserRam:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov	r0,#userram
		mov r1,#1			;Lines
		;bl MemDump
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorRegisters:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorR1
		bl NewLine	
		bl MonitorR2
		bl MonitorR3
		bl NewLine	
		bl MonitorR4
		bl MonitorR5
		
		bl NewLine	
		
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	BX LR
	
MonitorR5:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r5
		mov r1,#48+5				;Number 2
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
	
MonitorR4:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r4
		mov r1,#48+4				;Number 2
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorR3:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r3
		mov r1,#48+3				;Number 2
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorR2:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r1,#48+2				;Number 2
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorR1:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r1
		mov r1,#48+1				;Number 1
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorR0:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r0
		mov r1,#48+0		
		b MonitorRn		;Number 0
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorRn:
	STMFD sp!,{r0-r12, lr}
		mov r0,#82					;Ascii 'R'
		bl PrintChar
		mov r0,r1 					;reg number
		bl PrintChar
		mov r0,#58 					;Ascii ':'
		bl PrintChar
		
		mov r0,r2
		bl ShowHex32	
		mov r0,#32 					;Ascii " "
		bl PrintChar

	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
Delay:
	STMFD sp!,{r0-r12, lr}
	mov r0, #delayCounter
    mov r7, r0          ; r0 = delay count
DelayN_Loop:
    subs r7, r7, #1
    bne DelayN_Loop  
	LDMFD sp!,{r0-r12, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
.include "Headers/V1_Monitor.asm"
.include "Headers/V1_BitmapMemory.asm"
	
	
BitmapFont:
	.incbin "Headers/Font96.FNT"
Arm9_End: