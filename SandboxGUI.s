; -----------------------------------------------------------------------------
; File:            SandboxWithHeaders.s
; Author:          Juan Vargas
; Date:            October 29, 2025
; Last edit:	   Nov 20, 2025
; Source:          Adapted from - https://www.youtube.com/watch?v=YUO7gDDuZAM
;				- https://www.chibialiens.com/arm/nds.php
;
; Description:
;   Nintendo DS assembly source file.
;   Compile for the NDS only. Do not compile for DSi unless you know what
;   you are fully aware of the hardware differences and implications.
;
; License:
;   This work is under APACHE license, feel free to use it
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

	; main loop
	bl ScreenInit
	bl FillScreen
	bl NewLine

	ldr r1, Txt2ScreenAddress
	bl PrintString
	
	;bl TestReadWriteRam
	
	BL ShowUserRam
	BL NewLine
    BL NewLine
    BL MonitorR0
    BL MonitorR1
    BL NewLine
    BL MonitorR2
    BL MonitorR3
    BL NewLine
    BL MonitorR4
    BL MonitorR5
    BL NewLine
    BL NewLine
    
    
    
	BL PrintImg
	
	
		

	
	b endCode ;end code loop
	
Txt2ScreenAddress:
	.long Txt2Screen			;Pointer to string message

TxtMainMenuAdress:
	.long TxtMainMenu
	
Txt2Screen:
	.byte "COEN 311 S - (Juan)",0
	.align 4	
	
TxtMainMenu:
	.byte "Press A to start",0
	.align 4
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test code

TestReadWriteRam:	;Test Reading And Writing Ram
	STMFD sp!,{r0-r12, lr}	
	 bl ShowTestRam		;show 'TestVal' ram
	;bl NewLine
	
	;mov r0,#0xFFFF0000	;Reset R0
	;add r0,r0,#0xFFFF	;Reset R0
	
	;bl MonitorRegisters		;Show the regs
		
	ldrB r0,TestVal		;Load BYTE r0 from address TestVal
	
	add r0,r0,#0xFF		;add a value 
	strB r0,TestVal		;Store BYTE R0 into the address in R2
	bl ShowTestRam
	bl NewLine
	
	;bl MonitorRegisters
	;bl monitor
	LDMFD sp!,{r0-r12, lr}
	bx lr
	
	;mov r1,#1	;x
	;mov r2,#200	;y
	;bl GetScreenPos			;Get Screen address
	;ldr r1,SpriteHAddress	;load into memory the sprite
	;mov r6,#80				;Height of bmp
	

Sprite_NextLine:			;Vertical print
	mov r5,#144				;Width of bmp	
	STMFD sp!,{r10}
	
Sprite_NextByte:			;Horizontal print
	ldrh r0,[r1],#2			;Must write 16/32bit on GBA
	strh r0,[r10],#2
	subs r5,r5,#1
	bne Sprite_NextByte
	LDMFD sp!,{r10}
			
	;add r10,r10, #198		
	;clanker fix - 240bytes wide screen
	
	bl GetNextLine
	subs r6,r6,#1
	bne Sprite_NextLine

	
	;bl WriteLoopCounter	

	LDMFD sp!,{r0-r12, pc}
	
PrintImg:
STMFD sp!,{r10}

ldr r0, SpriteHAddress    ; address of first image
mov r1, #10              ; x
mov r2, #200             ; y on lower screen
mov r3, #144             ; width of raw
mov r4, #80              ; height of raw
bl DrawImage

ldr r0, SpriteLAddress
mov r1, #10 + 144 + 4    ; x shifted by width+padding
mov r2, #200			 ; y on lower screen
mov r3, #80           	 ; width of raw
mov r4, #80				 ; height of raw
bl DrawImage

sub r1,r1,r1			  ; r1 clean 
sub r2,r2,r2			  ; r2 clean
mov r1, #72      		  ; x
mov r2, #30			      ; y
bl SetScreenPos			  ; R1,R2 = X,Y
ldr r1, TxtMainMenuAdress
bl PrintString			    ; print that string

LDMFD sp!,{r0-r12, pc}

endCode:
	b endCode	; inf loop to end the code

.align 4				;We need to make sure we're aligned to a 32 bit boundsry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;==============================================================
; DrawImage
; r0 = pointer to RAW image (16-bit per pixel)
; r1 = x position
; r2 = y position
; r3 = width  (in pixels)
; r4 = height (in pixels)
;
; Uses: r0-r6, r10
;==============================================================

DrawImage:
    STMFD sp!, {r0-r6, lr}
    
    ; get VRAM pointer in r10
    bl GetScreenPos   ; r1=x, r2=y → r10 = VRAM pointer

    mov r6, r4        ; height counter
    mov r5, r3        ; width per row

ImageRowLoop:
    mov r5, r3        ; reset width

ImagePixelLoop:
    ldrh r12, [r0], #2    ; load pixel
    strh r12, [r10], #2   ; write pixel
    subs r5, r5, #1
    bne ImagePixelLoop

    ; next line:
    sub r10, r10, r3, lsl #1  ; rewind horizontal (width * 2)
    add r10, r10, #512        ; move down 1 scanline (256*2)

    subs r6, r6, #1
    bne ImageRowLoop

    LDMFD sp!, {r0-r6, pc}
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test code - not in use

MntRegister:
    STMFD sp!, {lr}         ; Save return address

    BL NewLine
    BL NewLine
    BL MonitorR0
    BL MonitorR1
    BL NewLine
    BL MonitorR2
    BL MonitorR3
    BL NewLine
    BL MonitorR4
    BL MonitorR5
    BL NewLine
    BL NewLine
    BL ShowUserRam

    LDMFD sp!, {pc}         ; Restore return address and return

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
		bl MemDump
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
		bl MonitorSP
		bl MonitorLR
		
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
	
MonitorSP:	;put SP into r10
	mov r10,sp
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r0,#83					;Letter S
		bl PrintChar
		mov r0,#80 					;Letter P
		bl PrintChar
		mov r0,#58 					;Ascii :
		bl PrintChar
		
		mov r0,r10
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorLR:	;put LR into r8
	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		
		mov r0,#76					;Letter L
		bl PrintChar
		mov r0,#82					;Letter R
		bl PrintChar
		mov r0,#58 					;Ascii :
		bl PrintChar
		
		mov r0,r8
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
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


SpriteHAddress:
	.long SpriteHeader
SpriteLAddress:
	.long SpriteLogo
	
BitmapFont:
	.incbin "Headers/Font96.FNT"
	
SpriteHeader:
	.incbin "Headers/headerBL.RAW" 
	
SpriteLogo:
	.incbin "Headers/logoEngQ.RAW"
	
Arm9_End: