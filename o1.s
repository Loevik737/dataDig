.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO

.text
	.global Start

Start:

	LDR R0, = GPIO_BASE //basen R0 = 0x40006000
	MOV R1, #LED_PORT   //R1 = 4
	MOV R2, #BUTTON_PORT//R2 = 1
	MOV R3, #PORT_SIZE	//R3 = 36(9 registere paa 4 bytes)
	MUL R1, R1, R3		//R1 = 144
	MUL R2, R2, R3		//R2 = 36

	LDR R3, = GPIO_PORT_DOUT // R3 = 12
	LDR R4, = GPIO_PORT_DIN  // R4 = 28
	ADD R1, R1, R3		 // R1 = 156
	ADD R2, R2, R4		 // R1 = 64

	MOV R3, #1				//R3 = 1(00000001)
	MOV R4, #1				//R4 = 1(00000001)
	LSL R3, R3, #LED_PIN	//R3 = 4(Fra: 00000001 til 00000100)
	LSL R4, R4, #BUTTON_PIN //R4 = 512(Fra: 00000001 til 1000000000)
	// Så langt er
	// R0 = 0x40006000
	// R1 = 156 som er offserttet til LED portens DOUT register
	// R2 = 64 som er offsettet til Button portens DIN register
	// R3 = 00000100 siden offsettet til LED pinnen til Led porten i DOUT registeret er 2, må vi sette 1 tallet 2 plasser til venste
	// R4 = 1000000000 siden offsettet er 9 for PB0

Loop:
	LDR R5, [R0,R2]	//henter verdien til registeret PORT_B => GPIO_PORT_DIN
	UDIV R5, R5, R4	//deler verdien vi fikk i R5 på R4. Det vil si enten 512/512 eller 0/512, som gir 1 eller 0
	MVN R5, R5		//Inveerterer så LED en er default av
	LSL R5, R5, #2	//Flytter verdien til R5 to plasser mot venstre så det blir enten 00000100 eller 00000000
	STR R5, [R0,R1] //Lagrer R6 i LED registeret så den enten lyser eller ikke
	BNE Loop		//Looper denne prosessen for evig


NOP

