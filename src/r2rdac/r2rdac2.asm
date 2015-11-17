#include "../cbs.inc"

addr = $02

ISRL		= $41			; ISR vector
ISRH		= $42

#define delay 125

		.word START
		.word END - 1
* = $1000
START		sei							; Disable interrupts
			lda #$FF					; Set port B to output for r2r dac
			sta DDRB

			lda #<ISR					; Setup player interrupt
			sta ISRL
			lda #>ISR
			sta ISRH

			lda #%00000010				; Disable timer 1B underflow interrupts
			sta ICR2

			lda #<delay					; Set timer 2B delay
			sta TBL
			lda #>delay
			sta TBH

			lda #<SOUND
			sta addr
			lda #>SOUND
			sta addr + 1

			lda #%00010001				; Start timer in continuous mode
			sta CRB
			lda #%10000010				; Enable timer B interrupts
			sta ICR
			ldx #0
			ldy #0
			cli							; Enable interrupts
			rts

ISR			tya
			pha
			ldy #0
			lda ICR						; Acknowledge interrupt
			lda (addr),y				; Load sound data from ram
			sta PRB
			sec							; Jump to next byte in ram
			tya
			adc addr
			sta addr
			tya
			adc addr + 1
			sta addr + 1
			cmp #>SOUNDEND				; Check if sample is done playing yet
			beq RES1
			pla
			tay
			pla
			tax
			pla
			rti
RES1		lda addr
			cmp #<SOUNDEND
			beq RES
			pla
			tay
			pla
			tax
			pla
			rti
RES			lda #<SOUND					; Loop sample
			sta addr
			lda #>SOUND
			sta addr + 1
			pla
			tay
			pla
			tax
			pla
			rti
SOUND
		.bin	0,0,"dj.bin"
SOUNDEND
END
