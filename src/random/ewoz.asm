; EWOZ Extended Woz Monitor.
; Just a few mods to the original monitor.
; Modified for the CBS6000 by Koen van Vliet <8by8mail@gmail.com>

#define ROM4K
#define SEGDELAY (360*8)-1

* = $E000

ACIA		  = $D800
ACIA_CTRL	= ACIA+0
ACIA_SR	  = ACIA+0
ACIA_DAT	 = ACIA+1

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

IN			 = $0200			 ;*Input buffer
XAML		  = $24				;*Index pointers
XAMH		  = $25
STL			= $26
STH			= $27
L			  = $28
H			  = $29
YSAV		  = $2A
MODE		  = $2B
MSGL		= $2C
MSGH		= $2D
COUNTER		= $2E ; NOT USED
CRC			= $2F
CRCCHECK	= $30

DIGN		=	$33
DIG0		=	$34
DIG1		=	$35
DIG2		=	$36
DIG3		=	$37
DIG4		=	$38
DIG5		=	$39
DIGA		=	$3A
ISTAT		=	$3B


STATLED = $04

start:
RESET		CLD				 		; Clear decimal arithmetic mode.
			sei						; Disable interrupts
			ldx #$FF
			txa
			lda #3					; Reset ACIA
			sta ACIA_CTRL
			lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA_CTRL			; * Serial clock/16
									; * 8b 2s no parity
			jsr ENSEG				; Enable seven segment display
			lda #<MSG4
			sta MSGL
			lda #>MSG4
			sta MSGH
			jsr SSHOWMSG			; Put message on 7 segment display
			cli
			LDA #$0D
			JSR ECHO				;* New line.
			LDA #$0A
			JSR ECHO				;* New line.
			LDA #<MSG1
			STA MSGL
			LDA #>MSG1
			STA MSGH
			JSR SHWMSG				;* Show Welcome.
			LDA #$0D
			JSR ECHO				;* New line.
			LDA #$0A
			JSR ECHO				;* New line.
SOFTRESET	LDA #$9B				;* Auto escape.
NOTCR		 CMP #$88		  ;"<-"? * Note this was chaged to $88 which is the back space key.
				BEQ BACKSPACE	;Yes.
				CMP #$9B		  ;ESC?
				BEQ ESCAPE		;Yes.
				INY				 ;Advance text index.
				BPL NEXTCHAR	 ;Auto ESC if >127.
ESCAPE		LDA #$DC		  ;"\"
				JSR ECHO		  ;Output it.
GETLINE	  LDA #$8D		  ;CR.
				JSR ECHO		  ;Output it.
				LDA #$8A
				JSR ECHO
				LDY #$01		  ;Initiallize text index.
BACKSPACE	DEY				 ;Backup text index.
				BMI GETLINE	  ;Beyond start of line, reinitialize.
			LDA #$A0		;*Space, overwrite the backspaced char.
			JSR ECHO
			LDA #$88		;*Backspace again to get to correct pos.
			JSR ECHO
NEXTCHAR	LDA ACIA_SR	  ;*See if we got an incoming char
				AND #$01		  ;*Test bit 1
				BEQ NEXTCHAR	 ;*Wait for character
				LDA ACIA_DAT	 ;*Load char
			CMP #$60		;*Is it Lower case
			BMI	CONVERT		;*Nope, just convert it
			AND #$5F		;*If lower case, convert to Upper case
CONVERT	 	ORA #$80		  ;*Convert it to "ASCII Keyboard" Input
				STA IN,Y		  ;Add to text buffer.
				JSR ECHO		  ;Display character.
				CMP #$8D		  ;CR?
				BNE NOTCR		 ;No.
				LDY #$FF		  ;Reset text index.
				LDA #$00		  ;For XAM mode.
				TAX				 ;0->X.
SETSTOR	  ASL				 ;Leaves $7B if setting STOR mode.
SETMODE	  STA MODE		  ;$00 = XAM, $7B = STOR, $AE = BLOK XAM.
BLSKIP		INY				 ;Advance text index.
NEXTITEM	 LDA IN,Y		  ;Get character.
				CMP #$8D		  ;CR?
				BEQ GETLINE	  ;Yes, done this line.
				CMP #$AE		  ;"."?
				BCC BLSKIP		;Skip delimiter.
				BEQ SETMODE	  ;Set BLOCK XAM mode.
				CMP #$BA		  ;":"?
				BEQ SETSTOR	  ;Yes, set STOR mode.
			CMP #$D2		  ;"R"?
				BEQ RUN			;Yes, run user program.
				;CMP #$CC		  ;* "L"?
				;BEQ LOADINT	  ;* Yes, Load Intel Code.
				CMP #$43		  ;* "C"?
				BEQ CLEARSEVSEG		; Yes, Clear seven segment displays
				STX L			  ;$00->L.
				STX H			  ; and H.
				STY YSAV		  ;Save Y for comparison.
NEXTHEX	  LDA IN,Y		  ;Get character for hex test.
				EOR #$B0		  ;Map digits to $0-9.
				CMP #$0A		  ;Digit?
				BCC DIG			;Yes.
				ADC #$88		  ;Map letter "A"-"F" to $FA-FF.
				CMP #$FA		  ;Hex letter?
				BCC NOTHEX		;No, character not hex.
DIG			ASL
				ASL				 ;Hex digit to MSD of A.
				ASL
				ASL
				LDX #$04		  ;Shift count.
HEXSHIFT	 ASL				 ;Hex digit left MSB to carry.
				ROL L			  ;Rotate into LSD.
				ROL H			  ;Rotate into MSD's.
				DEX				 ;Done 4 shifts?
				BNE HEXSHIFT	 ;No, loop.
				INY				 ;Advance text index.
				BNE NEXTHEX	  ;Always taken. Check next character for hex.
NOTHEX		CPY YSAV		  ;Check if L, H empty (no hex digits).
			BNE NOESCAPE	;* Branch out of range, had to improvise...
				JMP ESCAPE		;Yes, generate ESC sequence.

RUN			JSR ACTRUN		;* JSR to the Address we want to run.
			JMP	SOFTRESET	;* When returned for the program, reset EWOZ.
ACTRUN		JMP (XAML)		;Run at current XAM index.

;LOADINT		JSR BINLOAD		;* Load the Intel code.
;			JMP	SOFTRESET	;* When returned from the program, reset EWOZ.
CLEARSEVSEG		JSR SCLEAR
			JMP SOFTRESET

NOESCAPE	 BIT MODE		  ;Test MODE byte.
				BVC NOTSTOR	  ;B6=0 for STOR, 1 for XAM and BLOCK XAM
				LDA L			  ;LSD's of hex data.
				STA (STL, X)	 ;Store at current "store index".
				INC STL			;Increment store index.
				BNE NEXTITEM	 ;Get next item. (no carry).
				INC STH			;Add carry to 'store index' high order.
TONEXTITEM  JMP NEXTITEM	 ;Get next command item.
NOTSTOR	  BMI XAMNEXT	  ;B7=0 for XAM, 1 for BLOCK XAM.
				LDX #$02		  ;Byte count.
SETADR		LDA L-1,X		 ;Copy hex data to
				STA STL-1,X	  ;"store index".
				STA XAML-1,X	 ;And to "XAM index'.
				DEX				 ;Next of 2 bytes.
				BNE SETADR		;Loop unless X = 0.
NXTPRNT	  BNE PRDATA		;NE means no address to print.
				LDA #$8D		  ;CR.
				JSR ECHO		  ;Output it.
				LDA #$8A		  ;NL.
				JSR ECHO		  ;Output it.
				LDA XAMH		  ;'Examine index' high-order byte.
				JSR PRBYTE		;Output it in hex format.
				LDA XAML		  ;Low-order "examine index" byte.
				JSR PRBYTE		;Output it in hex format.
				LDA #$BA		  ;":".
				JSR ECHO		  ;Output it.
PRDATA		LDA #$A0		  ;Blank.
				JSR ECHO		  ;Output it.
				LDA (XAML,X)	 ;Get data byte at 'examine index".
				JSR PRBYTE		;Output it in hex format.
XAMNEXT	  STX MODE		  ;0-> MODE (XAM mode).
				LDA XAML
				CMP L			  ;Compare 'examine index" to hex data.
				LDA XAMH
				SBC H
				BCS TONEXTITEM  ;Not less, so no more data to output.
				INC XAML
				BNE MOD8CHK	  ;Increment 'examine index".
				INC XAMH
MOD8CHK	  LDA XAML		  ;Check low-order 'exainine index' byte
				AND #$0F		  ;For MOD 8=0 ** changed to $0F to get 16 values per row **
				BPL NXTPRNT	  ;Always taken.
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
ECHO		PHA				 ;*Save A
				AND #$7F		  ;*Change to "standard ASCII"
				STA ACIA_DAT	 ;*Send it.
WAIT		 LDA ACIA_SR	  ;*Load status register for ACIA
				AND #$02		  ;*Mask bit 2.
				BEQ	 WAIT	 ;*ACIA not done yet, wait.
				PLA				 ;*Restore A
				RTS				 ;*Done, over and out...

SHWMSG		LDY #$0
PRINT		LDA (MSGL),Y
			BEQ DONE
			JSR ECHO
			INY 
			BNE PRINT
DONE		RTS 


GETCHAR		LDA ACIA_SR		;See if we got an incoming char
			AND #$01		;Test bit 1 (rx register full)
			BEQ GETCHAR	  	;Wait for character
			LDA ACIA_DAT	;Load char
			RTS

SCLEAR		lda #<CLR				; Clear display
			sta MSGL
			lda #>CLR
			sta MSGH
			jsr SSHOWMSG
			rts

SSHOWMSG	ldy #6					; Repeat for all 6 digits
SPUTDIS		dey
			lda (MSGL),Y			; Copy string
			sta DIG0,Y				; to display
			cpy #0
			bne SPUTDIS
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
SEVSEGRET	pla
			tax
			pla
			rti

SEVSEG		tya
			pha
			lda DIGN
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




MSG1		.asc "Welcome to EWOZ 1.0.",0
MSG2		.asc "Start binary transfer...",0
MSG3		.asc "Binary transfer complete!",0
SEGS		.byte $00, $82, $21, $00, $00, $00, $00, $02, $39, $0F	; Symbols
			.byte $00, $00, $00, $40, $80, $52
			.byte $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F	; Numbers

			.byte $00, $00, $00, $48, $00, $53, $00					; Symbols

			.byte $77, $7C, $39, $5E, $79, $71, $6F, $76, $06, $1E	; Letters
			.byte $76, $38, $55, $54, $3F, $73, $67, $50, $6D, $78
			.byte $3E, $FE, $1C, $76, $6E, $5B
MSG4		.asc "CBS128"
CLR			.asc	0,0,0,0,0,0
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