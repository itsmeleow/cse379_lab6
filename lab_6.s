	.data

space:				.byte 0x20
newline:			.byte 0xD, 0xA, 0
score_prompt:		.string "Score: ", 0
board: 				.string " -------------------- ", 0xA, 0xD
					.string "|  4                  |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|         8           |", 0xA, 0xD
					.string "|                 2   |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|       3             |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|      7              |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|          *          |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|     5         1     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                6    |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|    9                |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string " -------------------- ", 0x0


score:				.byte 0	; user score
paused:				.byte 0	; stores pause state
								; 0 - not paused
								; 1 - paused
position:			.byte 0 ; stores next input position
								; 0 - no user input yet (auto right)
								; 1 - up (w)
								; 2 - left (a)
								; 3 - down (s)
								; 4 - right (d)


	.text

	.global lab6
	.global uart_init
	.global uart_interrupt_init
	.global	gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler

	.global output_string

	; global constants
	.global UARTICR
	.global RXIC
	.global GPIOICR
	.global SW1
	.global GPTMICR
	.global TATOIM



ptr_to_newline:			.word newline
ptr_to_score_prompt:	.word score_prompt
ptr_to_board:			.word board

ptr_to_score:			.word score
ptr_to_paused:			.word paused
ptr_to_position:		.word position




lab6:
	PUSH {r4-r12, lr}

	BL uart_init
	BL uart_interrupt_init
	BL gpio_interrupt_init

	; used to reset score and paused variables
	MOV r4, #0

	LDR r0, ptr_to_paused
	STRB r4, [r0]

	LDR r0, ptr_to_score_prompt
	BL output_string

	LDR r0, ptr_to_score
	STRB r4, [r0]
	BL output_string

	LDR r0, ptr_to_newline
	BL output_string

	LDR r0, ptr_to_board
	BL output_string
start_game:



	POP {r4-r12, lr}
	MOV pc, lr




UART0_Handler:
	PUSH {r4-r12, lr}

	; Clear Interrupt
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDR r5, [r4, #UARTICR]
	ORR r5, r5, #RXIC
	STR r5, [r4, #UARTICR]

	; read the character passed to input
	BL simple_read_character

	; get current position
	LDR r4, ptr_to_position

	MOV r5, #0				; set temp position to 0 (default)
							; we then increment each input key we check because (up-1, left-2, down-3, right-4)

	; Set user position
uart_up:
	ADD r5, r5, #1
	CMP r0, #0x77			; check for ascii [w]
	BEQ uart_done

uart_left:
	ADD r5, r5, #1
	CMP r0, #0x61			; check for ascii [a]
	BEQ uart_done

uart_down:
	ADD r5, r5, #1
	CMP r0, #0x73			; check for ascii [s]
	BEQ uart_done

uart_right:
	ADD r5, r5, #1
	CMP r0, #0x64			; check for ascii [d]

uart_done:
	; set next position to temp position
	STRB r5, [r4]

	POP {r4-r12, lr}
	BX lr



; Handles pause/unpause game when SW1 is clicked
Switch_Handler:
	PUSH {r4-r12, lr}

	; Clear Interrupt
	MOV r4, #0x5000
	MOVT r4, #0x4002
	LDR r5, [r4, #GPIOICR]
	ORR r5, r5, #SW1
	STR r5, [r4, #GPIOICR]

	; inverts the paused state
	LDR r4, ptr_to_paused
	LDRB r5, [r4]
	MOV r6, #1
	EOR r5, r5, r6
	STRB r5, [r4]

switch_done:
	POP {r4-r12, lr}
	BX lr




Timer_Handler:
	PUSH {r4-r12, lr}

	; Clear Interrupt
	MOVT r4, #0x4003
	LDR r5, [r4, #GPTMICR]
	ORR r5, r5, #TATOIM
	STR r5, [r4, #GPTMICR]


	POP {r4-r12, lr}
	BX lr




	.end

