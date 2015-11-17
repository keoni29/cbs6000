// Rotary dial input for 6510 microprocessor
// Author: Koen van Vliet
// Date: 28 sep 2014
// Error: -
// Status: Tested. Works great!
// Version: 0.1

// Summary:
// Part 0:
// 	Initialize cpu and seven segment display.
// Part 1:
//	Wait until the dial moves.
// Part 2:
//	Count pulses.
// Part 3:
// 	Process counter value and put value on display.

// C O N S T A N T S
.const pin_led	= %00000001		// LED hooked up to built in GPIO port pin 0
.const pin_pulse= %00000010		// Pulse wire hooked up to pin 1
.const pin_rest	= %00000100		// Rest wire hooked up to pin 2
.const GPIO	= $01
.const DDR	= $00

.pc = $F000
// P A R T [0]
	ldx #$FF		// Initialize stack pointer
	txs
	lda #pin_led
	sta DDR			// Set LED pin to output
	sei 			// Disable interrupts
	jsr ss_clear	// Clear display

// P A R T [1]
next:
	lda #pin_led
	sta GPIO		// Turn LED on
idle:
	lda #pin_rest	// \ Wait until pin_rest is pulled low 
	and GPIO		// ]
	bne	idle		// /
	ldx #0			// Reset counter
	jsr wait40ms	// Wait until signals have settled
	lda #0		
	sta GPIO		// Turn LED off
	clc				// Pulse is inactive (using carry bit for this)
// P A R T [2]
countloop:
	lda #pin_rest	// \ Repeat while pin_rest is low
	and GPIO		// ]
	bne digit		// ]
	lda #pin_pulse	// ]
	and GPIO		// ]
	bcs	pulseactive	// ] If pulse is not active
	beq countloop	// ^ and pin_pulse is high
	sec				// ] Pulse is active
	lda #pin_led	// ]
	sta GPIO		// ]
	bne countloop	// ^
pulseactive:		// ] If pulse is active
	bne countloop	// ^ and pin_pulse is low
	inx				// ] Increment counter
	jsr wait40ms	// ] Wait until signals have settled
	jsr wait40ms	// ]
	clc				// ] Pulse is inactive
	lda #0			// ]
	sta GPIO		// ]
	jsr ss_putd		// ]
	jmp countloop	// /

// P A R T [3]
digit:
	cpx #0			// Verify dial
	bne not0
invalid:
	jsr ss_clear	// Invalid dial
	jmp next
not0:
	cpx #11			// If 10 pulses have been counted...
	bcs	invalid		// More than 10 means something went wrong
	cpx #10
	bne lessthan10
equalto10:
	ldx #0			// This means digit 0 was received from the dial
lessthan10:
	jsr ss_putd		// Put received digit on 7segment display
	jsr bp_beep		// Make a sound
	jmp next

// S U B R O U T I N E S
wait40ms:
	txa				// Push counter value on stack
	pha
	ldx #31			// Initialize delay counter
delay:	
	ldy #0			//   \ Calculate delay:31*(7 + 256*(2+3)) ~= 40000 cycles
inner:				// \ ]
	dey				// ] ]
	bne inner		// / ]
	dex				//   ]
	bne delay		//   /
	pla				// Pop counter value from stack
	tax
	rts

// Include sevem segment driver code
.import source "seven_seg.asm"
// Include sound driver code
.import source "beep.asm"