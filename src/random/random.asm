#define ROM4K
#define SEGDELAY (360*8)-1

* = $E000

DDR = $00
PORT = $01

RX_BUFF = $0200

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

MODE		=	$2B

RXP			=	$2C
RXCNT		=	$2D

DIGN		=	$32
DIG0		=	$33
DIG1		=	$34
DIG2		=	$35
DIG3		=	$36
DIG4		=	$37
DIG5		=	$38
DIGA		=	$39

BELL		=	$3A

ISTAT		=	$3B

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
			jsr CLEAR				; Clear display
			lda #04					; Status LED pin is output
			sta DDR
			jsr ENDIAL				; Enable rotary dial input
			jsr ENSEG				; Enable seven segment display output
			lda #1<<3
			ora PRA					; A bell is driven by PA3
			sta PRA					; Set high to disable the bell
			lda #1<<3				; Set PA3 to output
			ora DDRA
			sta DDRA
			lda #1<<3				; Turn off bell
			sta BELL
RESTART		lda #0
			sta MODE				; Set MODE to 0 (Attract)
			sta RXCNT
			sta RXP
			cli
ATTRACT		lda #(MSGEND-MSGSTART)/6
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
			lda RXCNT				; Dial activity?
			bne PLAY				; Yes, Play game!
			jsr DELAY
			lda RXCNT				; Dial activity?
			bne PLAY				; Yes, Play game!
			dec MSGN
			bne NEXTMSG				; Repeat for all messages
			jmp ATTRACT				; Go back to the first one
PLAY		jsr CLEAR				; Clear display
PLAYWAIT	lda PORT				; Test button
			and #1
			bne COMPARE
			lda RXCNT				; Wait for input
			beq PLAYWAIT
			jsr GETN
			jsr PRBCD				; Display number
			jmp PLAYWAIT
COMPARE		ldy #0
NEXTCOM		lda DIG0,Y
			jsr PRBYTE
			lda GETAL,Y
			jsr PRBYTE
			lda DIG0,Y
			cmp GETAL,Y
			beq	COMPOK
			bmi HI					; Is GETAL < DIGIT?
			bpl LO					; Is GETAL > DIGIT?
COMPOK		iny
			cpy #6
			bne NEXTCOM
WINNER		lda #$00				; Turn ON bell
			sta BELL
			lda #<GAMEWIN
			sta MSGL
			lda #>GAMEWIN
			sta MSGH
			jmp NEXTGAME			; Play again
HI			lda #<GAMEHIGH
			sta MSGL
			lda #>GAMEHIGH
			sta MSGH
			jmp NEXTGAME
LO			lda #<GAMELOW
			sta MSGL
			lda #>GAMELOW
			sta MSGH
			jmp NEXTGAME
EQUAL		lda #<GAMELOW
			sta MSGL
			lda #>GAMELOW
			sta MSGH
NEXTGAME	jsr SHOWMSG				; Show instructions
			jsr DELAY
			jsr DELAY
			lda #1<<3				; Turn off bell
			sta BELL
			jsr CLEAR
			jsr DELAY
			jmp RESTART

; Get character from rx buffer.
; Affected	 A, X
GETN		lda RXCNT				; Check if buffer is empty
			beq GETNN
			lda RXP					; offset = rxp - rxcnt
			sec
			sbc RXCNT
			and #63
			dec RXCNT				; Go to next byte in buffer
			tax
			lda RX_BUFF,x			; Load byte from buffer
GETNN		rts

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

CLEAR		lda #<CLR				; Clear display
			sta MSGL
			lda #>CLR
			sta MSGH
			jsr SHOWMSG
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
			lda ICR					; Acknowledge interrupt
			sta ISTAT				; Store interrupt flags for later use
			and #2					; Check timer B overflow
			bne SEVSEG				; Yes, refresh display
SEVSEGRET	lda ISTAT
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
			bmi INVALID
			clc
			adc #1
			cmp #10					; Check if 10 pulses
			beq DIALZERO			; Yes, a 0 was dialed
			bpl INVALID				; Otherwise discard number
			jmp VALID
DIALZERO	lda #0
VALID		tax
			lda #64
			and RXCNT				; Check if buffer is full
			bne INVALID
			lda #63
			and RXP	            	; Limit buffer size to 64 bytes
			tay
			txa
			sta RX_BUFF,y	      	; Store character in buffer
			inc RXP              	; Advance buffer pointer
			inc RXCNT              	; Increase read offset
INVALID		jsr ENDIAL				; Reset dial
			pla
			tay
			pla
			tax
			pla
			rti

SEVSEG		tya
			pha
			lda BELL
			ora DIGN
			sta PRA					; Select digit
			ldy DIGN
			lda DIG0,Y				; Get character
			beq SEVSEGNUL
			sec
			sbc #$20				; Convert from ascii
SEVSEGNUL	tax
			lda SEGS,X				; Lookup shape
			sta PRB					; Drive LED segments
			lda #05
			cmp DIGN				; * At last digit?				
			bne NEXTSEG				; * Yes, return to first one.
			lda #0
			sta DIGN
			beq ENDSEG
NEXTSEG		inc DIGN				; Go to the next digit
ENDSEG		pla
			tay
			jmp SEVSEGRET			; Return to main ISR


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

CLR			.asc	0,0,0,0,0,0
MSGSTART
MSG1		.asc	"RAAD  "
MSG2		.asc	"HET   "
MSG3		.asc	"GETAL "
OPEN1		.asc	" OPEN "
OPEN2		.asc	" DAG  "
OPEN3		.asc	" HHS  "
OPEN4		.asc	" 2015 "
GAME1		.asc	"DRAAI "
GAME2		.asc	"AAN DE"
GAME3		.asc	"SCHIJF"
MSGEND

GAMEWIN		.asc	"GOED!!"
GAMELOSE	.asc	"FOUT  "
GAMEHIGH	.asc	"HOGER "
GAMELOW		.asc	"LAGER "
GAMEBEST	.asc	"BESTE "
GAMESCORE	.asc	"SCORE "

GETAL		.asc	0,0,"6691"


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