#define ledpin 4

*= $1000
init:	lda #ledpin
		sta $00
		lda #$00
loop:	eor #ledpin 
		sta $01
		ldx #$00		; Initialize delay counter
delay:	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner:	dey
		bne inner
		dex
		bne delay
		beq loop		; Jump back to the start