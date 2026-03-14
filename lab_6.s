
UARTICR:	.equ 0x044 		; UART Interrupt Clear Register
RXIC:		.equ 0x010 		; UART Clear Bit Mask (Bit 4)
GPIOICR: 	.equ 0x41C		; GPIO Interrupt Clear Register
SW1:		.equ 0x010		; Switch 1 Mask - Port F, Pin 4 (Bit 4)
GPTMICR:	.equ 0x024 		; GPTM Interrupt Register Clear
TATOIM:		.equ 0x001		; Timer A Time Out Interrupt Mask (bit 0) (Disable 0 / Enable 1)

GPTMCTL:	.equ 0x00C		; Enable Timer (Disable 0 / Enable 1)


	.data

clear_screen:		.byte 0xC, 0
space:				.byte 0x20
asterisk:			.byte 0x2A
start_coord:		.half 0xFA
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
	   				.string "|                     |", 0xA, 0xD
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
player_lost:		.string "You're ass kid", 0


timer:				.byte 0x14	; game timer set to 20 seconds
score:				.byte 0		; user score
paused:				.byte 0		; stores pause state
									; 0 - not paused
									; 1 - paused
position:			.byte 0 	; stores next input position
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
	.global timer_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler

	.global simple_read_character
	.global output_string


ptr_to_clear_screen:	.word clear_screen
ptr_to_newline:			.word newline
ptr_to_score_prompt:	.word score_prompt
ptr_to_board:			.word board
ptr_to_coord:			.word start_coord
ptr_to_space:			.word space
ptr_to_asterisk:		.word asterisk

ptr_to_timer:			.word timer
ptr_to_score:			.word score
ptr_to_paused:			.word paused
ptr_to_position:		.word position
ptr_to_player_lost:		.word player_lost




lab6:
	PUSH {r4-r12, lr}

	BL uart_init
	BL uart_interrupt_init
	BL gpio_interrupt_init
	BL timer_interrupt_init

	; used to reset score and paused variables
	MOV r4, #0

	LDR r0, ptr_to_paused
	STRB r4, [r0]

	LDR r0, ptr_to_score
	STRB r4, [r0]

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

	; Set user next position
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
	BEQ uart_done

	; if any other input, use current position
	LDRB r5, [r4]

uart_done:
	; set next position to temp position
	STRB r5, [r4]

	POP {r4-r12, lr}
	BX lr




; disables the Timer (pauses the game)
pause_timer:
	PUSH {r4-r12, lr}

	MOV r4, #0x0000
	MOVT r4, #0x4003
	LDR r5, [r4, #GPTMCTL]
	BIC r5, r5, #TATOIM
	STR r5, [r4, #GPTMCTL]

	POP {r4-r12, lr}
	MOV pc, lr




; enables the Timer (resumes the game)
enable_timer:
	PUSH {r4-r12, lr}

	MOV r4, #0x0000
	MOVT r4, #0x4003
	LDR r5, [r4, #GPTMCTL]
	ORR r5, r5, #TATOIM
	STR r5, [r4, #GPTMCTL]

	POP {r4-r12, lr}
	MOV pc, lr




; Handles pause/unpause game when SW1 is clicked
Switch_Handler:
	PUSH {r4-r12, lr}

	; Clear Interrupt
	MOV r4, #0x5000
	MOVT r4, #0x4002
	LDR r5, [r4, #GPIOICR]
	ORR r5, r5, #SW1
	STR r5, [r4, #GPIOICR]

	; inverts the paused state (pause -> resume ; resume -> pause)
	LDR r4, ptr_to_paused
	LDRB r5, [r4]
	MOV r6, #1
	EOR r5, r5, r6
	STRB r5, [r4]

	CMP r5, #1
	BNE resume_game

pause_game:
	BL pause_timer
	B switch_done

resume_game:
	BL enable_timer

switch_done:
	POP {r4-r12, lr}
	BX lr




; clear board and output new game board with player new coordinates
output_board:
	PUSH {r4-r12, lr}

	LDR r0, ptr_to_clear_screen
	BL output_string

	LDR r0, ptr_to_score_prompt
	BL output_string

	LDR r0, ptr_to_score
	BL output_string

	LDR r0, ptr_to_newline
	BL output_string

	LDR r0, ptr_to_board
	BL output_string

	POP {r4-r12, lr}
	MOV pc, lr




Timer_Handler:
	PUSH {r4-r12, lr}

	LDR r12, ptr_to_coord			; r12 register will be used to track "coordinates"
	LDR r10, ptr_to_space			; r10 will be used to replace the asterisk with empty space after movement
	LDR r11, ptr_to_asterisk		; r11 will be used to replace the empty space with asterisk after movement
	LDR r9, ptr_to_board			; r9 will be pointer to mem for the board
	LDR r8, ptr_to_score			; r8 will be pointer to mem for score


	; Clear Interrupt
	MOV r4, #0x0000
	MOVT r4, #0x4003
	LDR r5, [r4, #GPTMICR]
	ORR r5, r5, #TATOIM
	STR r5, [r4, #GPTMICR]

	; decrement timer each time timer handler is called
	LDR r4, ptr_to_timer
	LDRB r5, [r4]
	SUB r5, r5, #1
	STRB r5, [r4]

	LDR r4, ptr_to_position		; Load position byte
	LDRB r5, [r4]

	CMP r5, #1					; If position is up (W)
	BEQ Move_UP

	CMP r5, #2					; If position is left (A)
	BEQ Move_LEFT

	CMP r5, #3					; If position is down (S)
	BEQ Move_DOWN

	CMP r5, #4					; If position is right (D)
	BEQ Move_RIGHT


Move_UP:

	STR r10, [r9, r12]			; Replace asterisk with empty space
	SUB r12, r12, #24			; Go up (-24 to go down a row of strings in mem to imitate up movement)
	BL CHECK_WALL
	BL CHECK_POINTS				; Check if space is a number
	STR r11, [r9, r12]			; Replace empty space with asterisk (new spot)
	B timer_done

Move_LEFT:

	STR r10, [r9, r12]			; Replace asterisk with empty space
	SUB r12, r12, #1			; Go left (-1 in mem to imitate left movement)
	BL CHECK_WALL
	BL CHECK_POINTS				; Check if space is a number
	STR r11, [r9, r12]			; Replace empty space with asterisk (new spot)
	B timer_done

Move_DOWN:

	STR r10, [r9, r12]			; Replace asterisk with empty space
	ADD r12, r12, #24			; Go down (+24 to go down a row of strings in mem to imitate down movement)
	BL CHECK_WALL
	BL CHECK_POINTS				; Check if space is a number
	STR r11, [r9, r12]			; Replace empty space with asterisk (new spot)
	B timer_done

Move_RIGHT:

	STR r10, [r9, r12]			; Replace asterisk with empty space
	ADD r12, r12, #1			; Go right (+1 in mem to imitate right movement)
	BL CHECK_WALL
	BL CHECK_POINTS				; Check if space is a number
	STR r11, [r9, r12]			; Replace empty space with asterisk (new spot)
	B timer_done

CHECK_WALL:
	LDR r5, [r9, r12]
	CMP r5, #0x2D				; If next spot is a wall
	BEQ YOU_LOSE
	CMP r5, #0x7D
	BEQ YOU_LOSE

	MOV pc, lr

YOU_LOSE:
	LDR r0, ptr_to_player_lost
	BL output_string
	; end the timer because the game is finished
	BL pause_timer

timer_done:
	BL output_board
	POP {r4-r12, lr}
	BX lr

CHECK_POINTS:
	LDR r5, [r9, r12]
	CMP r5, #0x20				; Check if this is a space
	BEQ Continue				; Is a space, so we don't add value to points
	SUB r5, r5, #0x30			; Get score value
	LDR r6, [r8]				; Get current score
	ADD r5, r5, r6				; Add current score to whatever score was just taken

Continue:
	MOV pc, lr




	.end

