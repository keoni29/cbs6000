;=====================================================================
; S E R I A L  O U T P U T
;=====================================================================
serial_init:
		lda #<cbaud				; Set baudrate
		sta TAL
		lda #>cbaud
		sta TAH
		lda #%01010001			; Start timer in continuous mode
		sta CRA					; Serial port = output
		rts

puts:	tya
		pha
puts_nextch:
		ldy #0
		lda (sstr),y			; Load character from ram
		cmp #0
		beq puts_strterm		; Terminate if zero
		sta SDR
		sec						; Advance to next character
		tya
		adc sstr
		sta sstr
		tya
		adc sstr + 1
		sta sstr + 1
		jmp puts_nextch
puts_strterm:
		pla
		tay
		rts