#include "../cbs.inc"

#define cbaud 1;				; Maximum serial transmission rate

sstr = $02						; String pointer

* = $0200						; Program loads at $0200
;=====================================================================
; M A I N   P R O G R A M
;=====================================================================
init:	lda #(DISROM | STATLED)	; Disable the ROM & turn on status LED
		sta $00
		ora $01
		sta $01
		jsr initSerial			; Initialize the serial port
		lda #<bootMsg			; Print a string over serial
		sta sstr
		lda #>bootMsg
		sta sstr + 1
		jsr puts
loop:	jmp loop				; Loop forever

initSerial:
		lda #<cbaud				; Set baudrate
		sta TAL
		lda #>cbaud
		sta TAH
		lda #%01010001			; Start timer in continuous mode
		sta CRA					; Serial port = output
		rts
;=====================================================================
; S U B R O U T I N E S
;=====================================================================
; Send zero terminated string over serial
puts:	tya
		pha
puts_nextch:
		ldy #0
		lda (sstrPtr),y			; Load character from ram
		cmp #0
		beq puts_strterm
		jsr putc
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

putc:	ldy ICR
		sta SDR					; Send character over serial
		pha
putc_wait:
		lda ICR					; Check if character has been sent yet
		and #((1<<7)|(1<<3))
		cmp #((1<<7)|(1<<3))
		bne putc_wait
		rts
	
blinkLed:
		lda #STATLED
		eor $01
		sta $01
		rts
;=====================================================================
; D A T A
;=====================================================================
bootMsg:
.asc " *** 6510 Microcomputer System *** ", $0D, $0A ,$00