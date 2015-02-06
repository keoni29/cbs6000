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
			lda #<MSG4				; Clear display
			sta MSGL
			lda #>MSG4
			sta MSGH
			jsr SHOWMSG
			lda #04					; Status LED pin is output
			sta DDR
			jsr ENDIAL				; Enable rotary dial input
			jsr ENSEG				; Enable seven segment display output
			cli
ATTRACT		jmp ATTRACT


			lda #(MSGEND-MSGSTART)/6		; 4 messages total
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
			bne NEXTMSG				; Repeat for all messages
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

ENDIAL		lda #$FF				; Start counter A on $FFFF
			sta TAL
			sta TAH
			lda #%00110001			; Count positive CNT transistions
			sta CRA
			lda #%10010000			; Enable /FLAG interrupts
			sta ICR
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

ISR			pha
			txa
			pha
			ldx ICR					; Acknowledge interrupt
			txa
			and #2					; Check timer B overflow
			bne SEVSEG				; Yes, refresh display
			txa
			and #16					; Check FLAG set
			bne DIAL				; Process counted pulses
			pla
			tax
			pla
			rti

DIAL		tya
			pha
			lda #$FD
			sec
			sbc TAL
			BMI INVALID
			jsr PRBYTE				; Show number on display
INVALID		jsr ENDIAL				; Reset dial
			pla
			tay
			pla
			tax
			pla
			rti

SEVSEG		tya
			pha
			ldy DIGN
			lda DIG0,Y				; Get character
			sec
			sbc #$20				; Convert from ascii
			tax
			lda SEGS,X				; Lookup shape
			sta PRB					; Drive LED segments
			lda DIGN
			sta PRA
			lda #05
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

PRBYTE		PHA				 ;Save A for LSD.
				LSR
				LSR
				LSR				 ;MSD to LSD position.
				LSR
				JSR PRHEX		 ;Output hex digit.
				PLA				 ;Restore A.
PRHEX		 AND #$0F		  ;Mask LSD for hex print.
				ORA #$B0		  ;Add "0".
				CMP #$BA		  ;Digit?
				BCC ECHO		  ;Yes, output it.
				ADC #$06		  ;Add offset for letter.
ECHO		  PHA				 ;*Save A
				AND #$7F		  ;*Change to "standard ASCII"
				STA ACIA_DAT	 ;*Send it.
WAIT		 LDA ACIA_SR	  ;*Load status register for ACIA
				AND #$02		  ;*Mask bit 2.
				BEQ	 WAIT	 ;*ACIA not done yet, wait.
				PLA				 ;*Restore A
				RTS				 ;*Done, over and out...

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