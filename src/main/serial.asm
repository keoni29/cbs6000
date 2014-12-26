; Filename	serial.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

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
		tya						; Advance to next character
		jsr sstr_inca			
		jmp puts_nextch
puts_strterm:
		pla
		tay
		rts

putc:	sta SDR
		txa
		pha
		ldx #32
putc_wait:
		dex
		;lda ICR
		;and #(1<<3)
		;beq putc_wait
		bne putc_wait
		pla
		tax
		rts

; Print byte as hexadecimal
; input		A
puth:	sta swp_str
		tya
		pha
		lda swp_str
		ror:ror:ror:ror
		and #$0F
		tay
		lda b2hex_lut,y
		jsr putc
		lda swp_str
		and #$0F
		tay
		lda b2hex_lut,y
		jsr putc
		pla
		tay
		rts