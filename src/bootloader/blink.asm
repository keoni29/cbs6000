#define ledpin 4
#define ROM4K

*= $e000
init:	sei						; Disable interrupts
		ldx #$FF				; Initialize stack
		txs
		cld						; Clear decimal mode

		lda #(ledpin)			; Turn on status LED
		sta $00
		ora $01
		sta $01
		
		lda #$00
loop:	eor #ledpin 
		sta $01
		ldx #$80		; Initialize delay counter
delay:	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner:	dey
		bne inner
		dex
		bne delay
		beq loop		; Jump back to the start
#ifdef ROM4K
end:
		.dsb ($1000-(end-init)-4),$FF
		.byte $00, $e0
		.byte $00, $e0
#endif