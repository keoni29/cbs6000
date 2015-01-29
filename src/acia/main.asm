; Filename	main.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

#include "../cbs.inc"
#include "zeropage.inc"

* = $0200						; Program loads at $0200
;* = $E000

start:
;=====================================================================
; M A I N   P R O G R A M
;=====================================================================
init:		sei						; Disable interrupts
			ldx #$FF				; Initialize stack
			txs
			cld						; Clear decimal mode
			lda #(STATLED | DISROM)	; Turn on status LED and disable rom
			sta $00
			ora $01
			sta $01
			jsr delay				; Blink LED once
			jsr statled
			jsr delay
			jsr statled
			lda #(1<<3)				; Disable CIA serial port interrupts
			sta ICR
			jsr serial_init			; Initialize the serial port
			lda #<bootMsg			; Print a bootmessage over serial
			sta sstr
			lda #>bootMsg
			sta sstr + 1
			jsr puts
			cli
			jsr serial_int_en

			jsr monitor
			jmp init

; Monitor application
notcr:
monitor:	
nextchar:	jsr getc
			beq nextchar
			cmp #$60
			bmi upcase
			sec
			sbc #$20		; Convert lowercase to upper
upcase:	jsr putc			; Echo
			cmp #$0D		; CR?
			bne notcr		; No.
			lda #$0A	; <--
			jsr putc	; <--
			jmp monitor

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

		ldx ACIA_DR		; Read character from ACIA
		lda rxcnt
		and #64			; Check for buffer overflow
		bne isr_rx_full
		lda rxp
		and #63
		tay
		txa
		sta RX_BUFF,y	; Store character in buffer
		inc rxp			; Advance buffer pointer
		inc rxcnt		; Increment rx byte counter
isr_rx_full:
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
		sec
		sbc rxcnt
		and #63
		dec rxcnt				; Go to next byte in buffer
		tax
		lda RX_BUFF,x			; Load byte from buffer
getc_n:	rts

;=====================================================================
; L E D   L I G H T   C O N T R O L
;=====================================================================
statled:lda #STATLED			; Toggle status LED
		eor $01
		sta $01
		rts

delay:	ldx #$50		; Initialize delay counter
outer:	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner:	dey
		bne inner
		dex
		bne outer
		rts

;=====================================================================
; D A T A
;=====================================================================
bootMsg:
.asc "*** 6510 Micro Computer System ***", $0A, $0D
.asc "128K RAM SYSTEM  126976 BYTES FREE", $0A, $0D
.asc "READY to Rock!", $0A, $0D, $00
doneMsg:
.asc "Done executing program!", $0A, $0D, $00
rxMsg:
.asc "Got byte!", $0D, $0A, $00
;end:
;		.dsb ($1000-(end-start)-4),$FF
;		.word init
;		.word isr_rx
RX_BUFF: