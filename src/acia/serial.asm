; Filename	serial.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>
#define SPMODE	6
#define SS	0
;#define _ACIA_SETUP (1<<7) | (1<<4) | (1<<0)
#define _ACIA_SETUP (1<<4) | (1<<0)
; Notes on ACIA setup
; * Serial clock/16
; * 8b 2s no parity
; * Receive irq enabled
;=====================================================================
; S E R I A L  O U T P U T
;=====================================================================
serial_init:
		lda #3					; Reset ACIA
		sta ACIA_CR
		lda #_ACIA_SETUP		; Initialize ACIA
		sta ACIA_CR
		lda #0					; Initialize rx buffer
		sta rxcnt
		sta rxp
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

; ISR Receive byte from ACIA serial port
isr_rx:	pha
		txa
		pha
		tya
		pha
		lda ACIA_SR				; Check if a character was received
		ldx ACIA_DR				; Read character from ACIA
		lda #64
		and rxcnt				; Check if buffer is full
		bne rx_full
		lda #63
		and rxp	            	; Limit buffer size to 64 bytes
		tay
		txa
		sta RX_BUFF,y	      	; Store character in buffer
		inc rxp              	; Advance buffer pointer
		inc rxcnt              	; Increase read offset
rx_full:pla
		tay
		pla
		tax
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