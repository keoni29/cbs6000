#define ledpin 4

;*= $e000
*=$0200
init:	lda #ledpin
		sta $00
		lda #$00
loop:	eor #ledpin 
		sta $01
		ldx #$10		; Initialize delay counter
delay:	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner:	dey
		bne inner
		dex
		bne delay
		beq loop		; Jump back to the start
;end:
;		.dsb ($2000-(end-init)-4),$FF
;		.byte $00, $e0
;		.byte $00, $e0