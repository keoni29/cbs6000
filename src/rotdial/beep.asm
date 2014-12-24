// Filename: beep.asm
// Author: Koen van Vliet
// Date: 28 sep 2014
// Version: 0.1
// Status: Tested. Works.
.const pin_beeper = %00001000


bp_beep:
	lda #pin_beeper	// Set beeper pin to output
	ora DDR
	sta DDR
	txa
	pha
	clc
	lda !c_tone+,x	// Look up tone constant
	sta $02
	lda !c_repeat+,x// Lookup repeat constant
	rol A
!repeat:			//     \
	ldx $02			//     |
!outer:				//     |
	ldy #2			//   \ | used to be #8
!inner:				// \ ] |
	dey				// ] ] |
	bne !inner-		// / ] |
	dex				//   ] |
	bne !outer-		//   / |
	tay				//     |
	lda #pin_beeper //     |
	eor GPIO		//     | Toggle voltage on beeper pin, thus creating a square waveform.
	sta GPIO		//     |
	dey				//     |
	tya 			//     |
	cmp	#0			//     |
	bne !repeat-	//     /
	pla				// Pop counter value from stack
	tax
	rts
//      C   D   E   F   G   A   B   C   D   E   F
!c_tone:
.byte 163,145,129,122,109, 97, 86, 81, 73, 65, 61
!c_repeat:
.byte  26, 29, 33, 35, 39, 44, 49, 53, 58, 65, 70
