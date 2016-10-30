.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start

Start:
	//setter opp interupt for knapp 0
	//EXTIPSEL
	MOV R1, 0b1111
	LSL R2, R1, #4
	MVN R3, R2
	LDR R4, = 0x40006104
	AND R5, R3, R4
	LDR R6, = PORT_B
	LSL R7, R6, #4
	ORR R8, R5, R7
	STR R8, [R4]

	//EXTIFALL
	MOV R1, #1
	LSL R1, R1, #9
	LDR R2, = 0x4000610C
	LDR R3, [R2]
	ORR R4, R1, R3
	STR R4, [R2]

	//IF
	LDR R2, = 0x4000611C
	LDR R3, [R2]
	ORR R4, R1, R3
	STR R4, [R2]

	//Enable
	LDR R2, = 0x40006110
	LDR R3, [R2]
	ORR R4, R1, R3
	STR R4, [R2]

	//setter opp SysTick interupt
	//CTRL - CONTROL AND STATUS REGISTER
	LDR R0,= SYSTICK_BASE //base adressen til systick
	MOV R1, 0b111	//Vi må sette de tre siste bittene i SYSTICK_CTRL registeret til 111
	STR R1, [R0]	//lagrer de tre siste bittene i SYSTICK_CTRL  som 111

	//LOAD - RELOAD VALUE REGISTER
	MOV R2, #SYSTICK_LOAD	//offsette til SYSTICK_LOAD = 4B
	LDR R1, = #1400000 // Klokkefrekvensen delt på 10
	STR R1, [R0,R2]	//Lagrer klokkefrekvensen delt på 10 i registeret SYSTICK_LOAD med offsett R2= 4 fra SYSTICK_BASE

	//VAL - CURRENT VALUE REGISTER
	MOV R2, #SYSTICK_VAL	//offsettet til SYSTICK_VAL = 8B
	STR R1, [R0, R2]		//Lagrer R1 i SYSTICK_VAL som gjør at den ikke vil interupte før et tidels sekund fra starten

	//Setter R10 til 1, R10 vil bli brukt som en Boolean for start/stop
	MOV R10, #1

.global GPIO_ODD_IRQHandler
.thumb_func
GPIO_ODD_IRQHandler:

	MVN R10,R10//Setter R10 til det omvendte av det den var, så om vi trykker på knappen blir den 1/0

	//clear interupt flag
	MOV R1, #1
	LSL R1, R1, #9
	LDR R2, = 0x4000611C
	LDR R3, [R2]
	ORR R4, R1, R3
	STR R4, [R2]
	BX LR

.global SysTick_Handler
.thumb_func
SysTick_Handler:
	//dette skal skje når handlern kalles
	AND R11, R10, #1
	CMP R11, #1//Om R11 er 1 vil vi telle og toggle leden
	BNE SuperFalse
		LDR R0, = tenths
		LDR R1, = seconds
		LDR R2, = minutes
		LDR R5, [R2]
		LDR R4, [R1]
		LDR R3, [R0]
		CMP R3, #10
		BNE False
			//toggle LED
			LDR R11, = 0x400060A8
			LDR R12, = 0b00000100
			STR R12, [R11]
			//
			MOV R3, #1
			ADD R4, R4, #1
			CMP R4, #60
			BNE False2
				MOV R4, #1
				ADD R5, R5, #1
				CMP R5, #60
				BNE False2
					MOV R5, #1
			False2:
				B EndIf
		False:
			ADD R3, R3, #1
		EndIf:
			STR R3,[R0]
			STR R4,[R1]
			STR R5,[R2]
			MOV R3, #0
	SuperFalse:
		BX LR
	BX LR

    // Skriv din kode her...


NOP // Behold denne pÃ¥ bunnen av fila

