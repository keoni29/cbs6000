; Assemble using xa feed.asm
#include "../cbs.inc"

ECHO		= $E182
*		=($800-4)
	.word	START		; Loader parameters
	.word	END

START		lda #$8C	; Set strobe high
		sta PRB
		lda #$FF	; Set data pins to all outputs
		sta DDRB
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		lda #$0C	; Set strobe low
		sta PRB		; Data is latched now
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		lda #$8C	; Set strobe high
		sta PRB		; Put data on I/O port
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		jmp START
END		.byte 0