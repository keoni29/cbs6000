; Filename	serial.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>
#define SPMODE	6
#define SS	0
;=====================================================================
; S E R I A L  O U T P U T
;=====================================================================
serial_init:
		lda #<cbaud				; Set baudrate
		sta TAL
		lda #>cbaud
		sta TAH
		lda #0					; Initialize rx buffer
		sta rxcnt
		sta rxp
		lda #(1<<SS)			; Set SS pin to output
		ora DDR
		sta DDR
		jsr sdout
		rts

sdin:	pha
		lda #(1<<SS)			; Set SS
		ora PORT
		sta PORT
		lda #%00010001			; Serial port = input
		sta CRA
		lda #%10001000			; Enable serial interrupts
		sta ICR
		pla
		rts
sdout:	pha
		lda #%00001000			; Disable serial interrupts
		sta ICR
		lda #$FF^(1<<SS)		; Clear SS
		and PORT
		sta PORT
		lda #(1<<SS)
		lda #%01010001			; Serial port = output
		sta CRA
		pla
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

; ISR Receive byte from CIA serial port
isr_rx:	pha
		txa
		pha
		tya
		pha
		lda ICR
		ldx SDR					; Read character from CIA
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