	.data

newline:			.string 0xA, 0xD
score_prompt:		.string "Score: ", 0
board: 				.string " -------------------- ", 0xA, 0xD
					.string "|  4                  |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
					.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|          *          |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string "|                     |", 0xA, 0xD
	   				.string " -------------------- ", 0x0



	.text

	.global lab6
	.global uart_init
	.global uart_interrupt_init
	.global	gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler

	.global output_string


ptr_to_newline:			.word newline
ptr_to_score_prompt:	.word score_prompt
ptr_to_board:			.word board


lab6:
	PUSH {r4-r12, lr}

	BL uart_init
	BL uart_interrupt_init
	BL gpio_interrupt_init

	LDR r0, ptr_to_score_prompt
	BL output_string

	LDR r0, ptr_to_newline
	BL output_string

	LDR r0, ptr_to_board
	BL output_string


	POP {r4-r12, lr}
	MOV pc, lr


UART0_Handler:
	PUSH {r4-r12, lr}




	POP {r4-r12, lr}
	BX lr

Switch_Handler:
	PUSH {r4-r12, lr}




	POP {r4-r12, lr}
	BX lr


Timer_Handler:
	PUSH {r4-r12, lr}




	POP {r4-r12, lr}
	BX lr


	.end

