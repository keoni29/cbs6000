; Assemble using xa printtest.asm
#include "../cbs.inc"

MSGL		= $2C
MSGH		= $2D
*	=	($800-4)
	.word	START
	.word	END
START		sei		; Disable interrupts
		lda #$90	; Set strobe high
		sta PRB
		lda #$FF	; Set data pins to all outputs
		sta DDRB
		lda #<MSG
		sta MSGL
		lda #>MSG
		sta MSGH
		jsr PRINTMSG	; Print the message
		cli		; Enable interrupts
		rts		; Return to woz monitor
PRINTMSG	ldy #$00
BUSY		lda #$02
		and PRA		; Check if busy
		bne BUSY	; Yes, wait for ready
		lda (MSGL),Y	; Get character from string
		beq DONE	; 0? Yes, we're done
		ora #$80	; Set strobe high
		sta PRB		; Put data on I/O port
		nop
		nop
		nop
		and #$7F	; Set strobe low
		sta PRB		; Data is latched now
		nop
		nop
		nop
		ora #$80	; Set strobe high
		sta PRB		; Put data on I/O port
		nop
		nop
		nop
		iny		; Next character
		bne BUSY	; Y overflow? Yes, abort
DONE		rts		; Done printing characters

MSG	.asc "Hello, world!",$0C,$0A,$0
END	.byte 0