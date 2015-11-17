// Filename: seven_seg.asm
// 

ss_putd:
	lda !segdigits+,x	// Lookup digit
	sta $F000			// Put on segment display
	rts
ss_clear:
	lda %11111111		// Every light off
	sta $F000			// Put on segment display
	rts


!segdigits:
.byte
	%10000010,		// 0
	%10011111,		// 1
	%11000001,		// 2
	%10000101,		// 3
	%10011100,		// 4
	%10100100,		// 5
	%10100000,		// 6
	%10001111,		// 7
	%10000000,		// 8
	%10000100,		// 9
	%10001000,		// A
	%10110000,		// B
	%11100010,		// C
	%10010001,		// D
	%11100000,		// E
	%11101000		// F