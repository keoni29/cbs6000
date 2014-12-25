#include "../cbs.inc"

#define cbaud 1;(1000000 / (baud*2))
#define delay 65535

sstr = $02
srdy = $04

* = $0200

init:	lda #(DISROM | STATLED)		; Disable the ROM
		sta $00
		ora $01
		sta $01

		jsr initSerial

		lda #<bootMsg
		sta sstr
		lda #>bootMsg
		sta sstr + 1

		cli							; Enable interrupts
loop:	jmp loop

isr:	pha
		tya
		pha
		jsr blinkLed				; Blink LED (to indicate that data is being sent)
		lda ICR						; Acknowledge interrupt
		ldy #0
		lda (sstrPtr),y
		cmp #0
		bne nextchar
		lda #1
		sta srdy
		lda #%00001000				; Disable serial port interrupts
		sta ICR
		bne endisr
nextchar:
		sta SDR						; Send character over serial

		sec							; Increment pointer to next character
		tya
		adc sstr
		sta sstr
		tya
		adc sstr + 1
		sta sstr + 1
endisr:	pla
		tay
		pla
		rti

initSerial:
		lda #1
		sta srdy
		lda #<isr					; Set interrupt vector
		sta $FFFE
		lda #>isr
		sta $FFFF

		lda #<cbaud
		sta TAL
		lda #>cbaud
		sta TAH
		lda #%01010001				; Start timer in continuous mode, Serial port = output
		sta CRA
		rts

putc:	sei
		brk
		lda #%10001000				; Enable serial port interrupts
		sta ICR
		cli
		rts
		
blinkLed:
		lda #STATLED
		eor $01
		sta $01
		rts

bootMsg:
.asc " *** 6510 Microcomputer System *** ", $0D, $0A ,$00