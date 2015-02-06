#define ROM4K
#define SEGDELAY 359

* = $E000

DDR = $00
PORT = $01

CIA = $D000
PRA = CIA + $0
PRB = CIA + $1
DDRA = CIA + $2
DDRB = CIA + $3
TAL = CIA + $4
TAH = CIA + $5
TBL = CIA + $6
TBH = CIA + $7
SDR = CIA + $C
ICR = CIA + $D
CRA = CIA + $E
CRB = CIA + $F

ACIA		= $D800
ACIA_CTRL	= ACIA+0
ACIA_SR		= ACIA+0
ACIA_DAT	= ACIA+1

; Zeropage
MSGL		=	$28
MSGH		= 	$29
MSGN		=	$2A

INTL		=	$30
INTH		=	$31
INTERRUPT	=	INTL
DIGN		=	$32
DIG0		=	$33
DIG1		=	$34
DIG2		=	$35
DIG3		=	$36
DIG4		=	$37
DIG5		=	$38
DIGA		=	$39


start:
RESET		cld						; Clear decimal arithmetic mode.
			sei						; Disable interrupts
			ldx #$FF
			txa
			lda #3					; Reset ACIA
			sta ACIA_CTRL
			lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA_CTRL			; * Serial clock/16
									; * 8b 2s no parity
			lda #"4"					; Load some test values
			sta DIG0
			lda #"5"
			sta DIG1
			lda #"6"
			sta DIG2
			lda #"7"
			sta DIG3
			lda #"8"
			sta DIG4
			lda #"9"
			sta DIG5

			lda #04					; Status LED pin is output
			sta DDR

			lda #<SEVSEG			; Load interrupt vector
			sta INTL
			lda #>SEVSEG
			sta INTH
			jsr ENSEG				; Enable seven segment display
			cli
ATTRACT		lda #(MSGEND-MSGSTART)/6		; 4 messages total
			sta MSGN
			lda #<MSG1
			sta MSGL
			lda #>MSG1
			sta MSGH
NEXTMSG		jsr SHOWMSG				; Show message
			clc						; Go to next message
			lda #6
			adc MSGL
			sta MSGL
			lda #0
			adc MSGH
			sta MSGH
			jsr DELAY
			dec MSGN
			bne NEXTMSG				; When all messages are shown
			lda #9
			jsr PRBCD
			jsr DELAY
			lda #8
			jsr PRBCD
			jsr DELAY
			lda #7
			jsr PRBCD
			jsr DELAY
			lda #6
			jsr PRBCD
			jsr DELAY
			lda #5
			jsr PRBCD
			jsr DELAY
			lda #4
			jsr PRBCD
			jsr DELAY
			lda #3
			jsr PRBCD
			jsr DELAY
			lda #2
			jsr PRBCD
			jsr DELAY
			lda #1
			jsr PRBCD
			jsr DELAY
			lda #0
			jsr PRBCD
			jsr DELAY
			jsr DELAY
			jsr DELAY
			jmp ATTRACT				; Go back to the first one

PRBCD		ldy #0					; Repeat for all 6 digits
			clc
			adc #$30
			sta DIGA
PUTBCD		lda DIG1,Y				; Move all digits one to the left
			sta DIG0,Y
			iny
			cpy #6
			bne PUTBCD
			rts

SHOWMSG		ldy #6					; Repeat for all 6 digits
PUTDIS		dey
			lda (MSGL),Y			; Copy string
			sta DIG0,Y				; to display
			cpy #0
			bne PUTDIS
			rts


ENSEG		lda #0					; Go to first digit
			sta DIGN
			lda #$07				; Set PA0..PA2 to output 
			ora DDRA
			sta DDRA
			lda #$FF				; Set PB0..PB7 to output
			sta DDRB
			lda #<SEGDELAY			; Set timer B delay
			sta TBL
			lda #>SEGDELAY
			sta TBH
			lda #%00010001			; Start timer in continuous mode
			sta CRB
			lda #%10000010			; Enable timer B underflow interrupts
			sta ICR
			rts

ISR			jmp (INTERRUPT)

SEVSEG		pha
			txa
			pha
			tya
			pha
			lda ICR					; Acknowledge interrupt
			ldy DIGN
			lda DIG0,Y				; Get character
			sec
			sbc #$20				; Convert from ascii
			tax
			lda SEGS,X				; Lookup shape
			sta PRB					; Drive LED segments
			lda DIGN
			sta PRA
			lda #06
			cmp DIGN				; * At last digit?				
			bne NEXTSEG				; * Yes, return to first one.
			lda #0
			sta DIGN
			beq ENDSEG
NEXTSEG		inc DIGN				; Go to the next digit
ENDSEG		pla
			tay
			pla
			tax
			pla
			rti						; Return from interrupt

DELAY		ldx #$00				; Initialize delay counter
OUTER		ldy #$00				; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
INNER		dey
			bne INNER
			dex
			bne OUTER
			rts						; Return from subroutine

STATLED		lda #4					; Toggle status LED
			eor $01
			sta $01
			rts

MSGSTART
MSG1		.asc	"RAAD  "
MSG2		.asc	"HET   "
MSG3		.asc	"GETAL "
MSG4		.asc	"      "
MSGEND

SEGS		.byte $00, $82, $21, $00, $00, $00, $00, $02, $39, $0F	; Symbols
			.byte $00, $00, $00, $40, $80, $52
			.byte $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F	; Numbers

			.byte $00, $00, $00, $48, $00, $53, $00					; Symbols

			.byte $77, $7C, $39, $5E, $79, $71, $6F, $76, $06, $1E	; Letters
			.byte $76, $38, $55, $54, $3F, $73, $67, $50, $6D, $78
			.byte $3E, $FE, $1C, $76, $6E, $5B
end:

#ifdef ROM8K
		.dsb ($2000-(end-start)-6),$FF
		.word RESET
		.word RESET
		.word ISR
#endif
#ifdef ROM4K
		.dsb ($1000-(end-start)-6),$FF
		.word RESET
		.word RESET
		.word ISR
#endif