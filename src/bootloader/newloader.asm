#include "../cbs.inc"
addr = $02

#define startaddr $0200				; Software will be loaded at this address

* = $E000
start:
jumptable:
t_init:	jmp init
t_isr:	jmp isr

init:	sei							; Disable interrupts
		ldx #$FF					; Initialize stack
		txs
		cld							; Clear decimal mode
		lda #( STATLED )			; Turn on the status LED
		sta $00
		ora $01
		sta $01

		lda #<startaddr
		sta addr
		lda #>startaddr
		sta addr + 1

		lda #3						; Reset ACIA
		sta ACIA_CR

		lda #%10001000				; Enable CIA sp interrupts
		sta ICR

		ldy #0
waitrun:
		lda PORT
		and #RUN					; Wait for RUN to go LOW
		bne waitrun
		cli							; Enable interrupts
loop:	lda PORT
		and #RUN					; Wait for RUN to go HIGH
		beq loop
		sei							; Disable interrupts
		lda #00
		sta DDR						; Set all pins to input
		sta PORT					; Clear port data register
		jmp startaddr				; Run program

isr:	pha
		lda #STATLED
		eor PORT
		sta PORT
		lda ICR						; Acknowledge interrupt
		lda SDR						; Get incoming byte
		ldy #0
		sta (addr),y
		sec							; Go to next memory address
		tya
		adc addr
		sta addr
		tya
		adc addr + 1
		sta addr + 1
		pla
		rti
end:
		.dsb ($1000-(end-start)-4),$FF
		.word init
		.word isr