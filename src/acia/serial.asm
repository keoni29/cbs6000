; Filename	serial.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>
#define SPMODE	6
#define SS	0
;=====================================================================
; S E R I A L  O U T P U T
;=====================================================================
serial_init:
		lda #3					; Reset ACIA
		sta ACIA_CR

		lda #<isr_rx			; Set interrupt vector
		sta $FFFE
		lda #>isr_rx
		sta $FFFF

		lda #(1<<4)|(1<<0)		; Initialize ACIA
		sta ACIA_CR				; * Serial clock/16
								; * 8b 2s no parity
		lda #0					; Initialize rx buffer
		sta rxcnt
		sta rxp
		rts

serial_int_en:
		lda #(1<<7)|(1<<4)|(1<<0); Enable rx interrupts
		sta ACIA_CR
		rts
serial_int_di:
		lda #(1<<7)|(1<<4)		; Disable rx interrupts
		sta ACIA_CR
		rts

putc:	sta ACIA_DR				; Send char
wputc:	lda ACIA_SR				; Wait until char can be sent
		and #2
		beq wputc
		rts

; Print string over serial
; Input 	sstr (pointer)
; Uses		Y
puts:	ldy #0
putsl:	lda (sstr),y
		beq putsr
		jsr putc
		lda #0
		jsr sstr_inca
		jmp putsl
putsr:	jsr sstr_inca
		rts

sstr_inca:						; Increment string pointer by 1 + A
		sec
		adc sstr
		sta sstr
		lda #0
		adc sstr + 1
		sta sstr + 1
		rts


; Print byte as hexadecimal
; input		A
b2hex_lut:
.asc "0123456789ABCDEF"
puth:	pha
		sta swp_str
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
		pla
		rts

; ISR Receive byte from ACIA serial port
isr_rx:	pha
		lda ACIA_SR
		and #1
		beq isr_no_char
		txa
		pha
		tya
		pha
		
		lda ACIA_DR
		jsr putc

		pla
		tay
		pla
		tax
isr_no_char:
		pla
		rti

; Get character from rx buffer.
; Affected	 A, X
getc:	lda rxcnt				; Check if buffer is empty
		beq getc_n
		lda rxp					; offset = rxp - rxcnt
		clc
		sbc rxcnt
		and #63
		dec rxcnt				; Go to next byte in buffer
		tax
		lda RX_BUFF,x			; Load byte from buffer
getc_n:	rts