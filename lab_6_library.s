
	.text
	.global uart_init
	.global uart_interrupt_init
	.global gpio_init
	.global gpio_interrupt_init
	.global output_character
	.global read_string
	.global output_string
	.global simple_read_character


; UART0 CONSTANTS - Base Address 0x4000C000
UART: 		.equ 0x618		; Emable UART0 Clock
PRUART:		.equ 0xA18		; Ready UART0 Clock
U0DR:		.equ 0x000		; UART0 Data Register
U0FR: 		.equ 0x018		; UART0 Flag Register

; UART Interrupts - UART0 0x4000C000
RXIM:		.equ 0x010		; Receive Interrupt Mask (Bit 4)
UARTIM:		.equ 0x038		; UART Interrupt Mask Register
UARTICR:	.equ 0x044 		; UART Interrupt Clear Register
RXIC:		.equ 0x010 		; UART Clear Bit Mask (Bit 4)

; Interrupt 0-31 Set Enable Register - EN0 0xE000E000
EN0:		.equ 0x100 		; EN0 Offset
UART_EN0M:	.equ 0x020		; UART0 Interrupt Enable Mask (Bit 5)
; GPIO_EN0M .equ 			BIT 30
; T0_EN0M 	.equ 			BIT 19

; GPIO CONSTANTS - Base 0x400FE000
RCGPIO:		.equ 0x608		; Enable GPIO Clock (Disable 0 / Enable 1)
PRGPIO:		.equ 0xA08		; Check GPIO Clock Ready (Not Ready 0 / Ready 1)
PORTFM:		.equ 0x020 		; Port F Bit Mask
RCGCTIMER:	.equ 0x604		; Enable Timer Clock (Disable 0 / Enable 1)
PRTIMER:	.equ 0xA04		; Check Timer Clock Ready (Not Ready 0 / Ready 1)

; TIMER 0 (GP) - Base 0x40030000
GPTMCFG:	.equ 0x00		; Enable Timer 32-Bit Mode (use config 0)
GPTMTAMR:	.equ 0x004		; Enable Timer Periodic Mode - continuously count through range of values
GPTMTAILR:	.equ 0x028		; Set Interrupt Frequency
GPTMIMR:	.equ 0x018		; Enable Timer for Interrupts (Disable 0 / Enable 1)
TATOIM:		.equ 0x000		; Timer A Time Out Interrupt Mask
GPTMCTL:	.equ 0x00C		; Enable Timer (Disable 0 / Enable 1)
TAEN:		.equ 0x000		; Enable Timer A - bit 0 (Disable 0 / Enable 1)

; GPIO PORT F - Base 0x40025000
GPIODIR:	.equ 0x400		; Data Direction Register
GPIODEN:	.equ 0x51C		; Enable Each Pin (8 bit) Digital I/O
GPIOPUR:	.equ 0x510 		; Enable Pull-Up Resistor for GPIO Pin
GPIODATA: 	.equ 0x3FC		; Read/Write Each Pin
RED:		.equ 0x002 		; RED LED Mask - Port F, Pin 1 (Bit 1)
BLUE:		.equ 0x004		; BLUE LED Mask - Port F, Pin 2 (Bit 2)
GREEN:		.equ 0x008 		; GREEN LED Mask - Port F, Pin 3 (Bit 3)
SW1:		.equ 0x010		; Switch 1 Mask - Port F, Pin 4 (Bit 4)
; GPIO Interrupts
GPIOIS:		.equ 0x404		; GPIO Interrupt Sense Register (Edge Sens 0 / Level Sens 1)
GPIOIBE:	.equ 0x408		; GPIO Interrupt Both Edges Regiser (GPIOEV 0 / Both 1)
GPIOEV:		.equ 0x40C		; GPIO Interrupt Event Register (Falling Edge 0 / Rising Edge 1)
GPIOIM:		.equ 0x410 		; GPIO Interrupt Mask Register (Disable 0 / Enable 1)
GPIOICR: 	.equ 0x41C		; GPIO Interrupt Clear Register




uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack
	; Your code is placed here

	MOV r4, #0xE618
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4]  		; First line of serial_init

	MOV r4, #0xE608
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4] 		; Enable clock port a

	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0
	STR r5, [r4] 		; Disable UART0 control

	MOV r4, #0xC024
	MOVT r4, #0x4000
	MOV r5, #8
	STR r5, [r4] 		; Set baud

	MOV r5, #44
	STR r5, [r4, #4] 	; 0xC0244000 Offset 4 = 0x4000C028

	MOV r4, #0xCFC8
	MOVT r4, #0x4000
	MOV r5, #0
    STR r5, [r4] 		; Use sys clock

	MOV r4, #0xC02C
	MOVT r4, #0x4000
	MOV r5, #0x60
	STR r5, [r4] 		; use 8 bit length

	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0x301
	STR r5, [r4] 		; enable uart0 crt

	MOV r4, #0x451C
	MOVT r4, #0x4000
	LDR r5, [r4]
	ORR r5, r5, #0x03
	STR r5, [r4] 		;make pa0 and pa1 digital ports

	MOV r4, #0x4420
	MOVT r4, #0x4000
	LDR r5, [r4]
	ORR r5, r5, #0x03
	STR r5, [r4] 		;change pa0 pa1 to use alt func

	MOV r4, #0x452C
	MOVT r4, #0x4000
	LDR r5, [r4]
	ORR r5, r5, #0x11
	STR r5, [r4] 	;configure pa0 and pa1

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr




uart_interrupt_init:
	PUSH {r4-r12, lr}
	; Your code to initialize the UART0 interrupt goes here

	; Set RXIM bit in UARTIM
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDR r5, [r4, #UARTIM]
	ORR r5, r5, #RXIM
	STR r5, [r4, #UARTIM]

	; Set Interrupt Set Enable Register (EN0)
	MOV r4, #0xE000
	MOVT r4, #0xE000
	LDR r5, [r4, #EN0]
	ORR r5, r5, #UART_EN0M
	STR r5, [r4, #EN0]

	POP {r4-r12,lr}
	MOV pc, lr




gpio_init:
	PUSH {r4-r12, lr}

	; INITIALIZE SW1 (Port F, Pin 4) & LED OUTPUT (Port F, Pin Red 1/ Green 3)
	MOV r4, #0xE000	; GPIO Base Address
	MOVT r4, #0x400F

	; Enable GPIO Port Clock
	LDR r5, [r4, #RCGPIO]
	ORR r5, r5, #PORTFM
	STR r5, [r4, #RCGPIO]
wait_enable_gpio:
	LDR r5, [r4, #PRGPIO]
	TST r5, #PORTFM			; if bit is set (ready), z flag = 0
	BEQ wait_enable_gpio	; branch back if z flag is set

	; GPIO Port F Base Address
	MOV r4, #0x5000
	MOVT r4, #0x4002

	; Set Red/Green LED as Output | SW1 as Input
	LDR r5, [r4, #GPIODIR]
	ORR r5, r5, #RED
	ORR r5, r5, #GREEN
	BIC r5, r5, #SW1
	STR r5, [r4, #GPIODIR]

	; Emable Pull-Up Resistor for SW1
	LDR r5, [r4, #GPIOPUR]
	ORR r5, r5, #SW1
	STR r5, [r4, #GPIOPUR]

	; Enable Red/Green LED & SW1
	LDR r5, [r4, #GPIODEN]
	ORR r5, r5, #RED
	ORR r5, r5, #GREEN
	ORR r5, r5, #SW1
	STR r5, [r4, #GPIODEN]

	POP {r4-r12,lr}
	MOV pc, lr




gpio_interrupt_init:
	PUSH {r4-r12, lr}
	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	; INITIALIZE GPIO SW1 (Port F, Pin 4) & LED OUTPUTS
	BL gpio_init

	; GPIO Port F Base Address
	MOV r4, #0x5000
	MOVT r4, #0x4002


	; INTERRUPT
	; First, we configure the interrupt:
	; Set Interrupt for [Edge] Sensitivity
	LDR r5, [r4, #GPIOIS]
	BIC r5, r5, #SW1		; bit clear bit 4 for edge sensitivity (logic low 0)
	STR r5, [r4, #GPIOIS]

	; Set Interrupt for [GPIOEV Edge Control]
	LDR r5, [r4, #GPIOIBE]
	BIC r5, r5, #SW1		; bit clear bit 4 for GPIOEV control (logic low 0)
	STR r5, [r4, #GPIOIBE]

	; Set Interrupt for [Falling Edge] Triggering
	LDR r5, [r4, #GPIOEV]
	BIC r5, r5, #SW1		; bit clear bit 4 for falling edge trigger (logic low 0)
	STR r5, [r4, #GPIOEV]

	; Enable the Interrupt
	LDR r5, [r4, #GPIOIM]
	ORR r5, r5, #SW1 		; bit set bit 4 for GPIOEV control (logic high 1)
	STR r5, [r4, #GPIOIM]

	; Set Interrupt Enable Register (EN0)
	MOV r4, #0xE000
	MOVT r4, #0xE000
	LDR r5, [r4, #EN0]

	MOV r6, #0
	MOVT r6, #0x4000		; GPIO_EN0 bit mask position (bit 30)
	ORR r5, r5, r6
	STR r5, [r4, #EN0]

	POP {r4-r12,lr}
	MOV pc, lr




simple_read_character:		; Removed RxFE flag check for interrupts
	PUSH {r4-r12,lr}		; Spill registers to stack
	; Your code is placed here

	MOV	r4, #0xC000
	MOVT r4, #0x4000

    LDR r0, [r4, #U0DR]		; LOAD Byte from data register
    AND r0, r0, #0xFF		; mask here to only get the 8 bits of data we need

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr




output_character:
	PUSH {r4-r12,lr}	; Spill registers to stack
	; Your code is placed here

	MOV	r4, #0xC000
	MOVT r4, #0x4000
wait_tx_flag:
    LDR r5, [r4, #U0FR] 	; LOAD Flag from flag register
    AND r5, r5, #0x20		; mask here to get bit 5
    CMP r5, #0x20 			; Is TXFF set?
    BEQ wait_tx_flag 		; YES -> loop back and wait

    STR r0, [r4, #U0DR]		; STORE Byte in data register

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr




read_string:
	PUSH {r4-r12,lr}	; Spill registers to stack
	; Your code is placed here

	MOV r6, r0			; store base address in temp register
	MOV r4, r6
read_string_loop:
	BL simple_read_character
	CMP r0, #0x0D		; ascii carriage return
	BEQ read_string_done

	BL output_character
	STRB r0, [r4], #1	; store byte in memory then increment address
	B read_string_loop

read_string_done:
	MOV r5, #0
	STRB r5, [r4]		; null terminate string

	MOV r0, r6			; restore base address to return

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr




output_string:
	PUSH {r4-r12,lr}	; Spill registers to stack
	; Your code is placed here

	MOV r4, r0			; store base address in temp register

output_string_loop:
	LDRB r0, [r4], #1	; load byte then increment address
	CMP r0, #0
	BEQ output_string_done
	BL output_character
	B output_string_loop

output_string_done:
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr




	.end

