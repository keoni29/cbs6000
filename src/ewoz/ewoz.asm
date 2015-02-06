; EWOZ Extended Woz Monitor.
; Just a few mods to the original monitor.
; Modified for the CBS6000 by Koen van Vliet <8by8mail@gmail.com>

#define ROM4K

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

; Binary loader parameters
PADL	=	$32
PADH	=	$33
SIZEL	=	$34
SIZEH	=	$35
ADDRL	=	$36
ADDRH	=	$37



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
NEXTCHAR	 LDA ACIA_SR	  ;*See if we got an incoming char
				AND #$01		  ;*Test bit 1
				BEQ NEXTCHAR	 ;*Wait for character
				LDA ACIA_DAT	 ;*Load char
			CMP #$60		;*Is it Lower case
			BMI	CONVERT		;*Nope, just convert it
			AND #$5F		;*If lower case, convert to Upper case
CONVERT	  ORA #$80		  ;*Convert it to "ASCII Keyboard" Input
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
				CMP #$CC		  ;* "L"?
				BEQ LOADINT	  ;* Yes, Load Intel Code.
				CMP #$D3		;* "S"?
				BEQ INITFD		;* Yes, Move floppydrive head to trk00
				CMP #$D4		;* "T"?
				BEQ TESTFD		;* Yes, Move floppydrive head to trk82
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

LOADINT		JSR BINLOAD		;* Load the Intel code.
			JMP	SOFTRESET	;* When returned from the program, reset EWOZ.
INITFD		JSR TRK00		;* Align head to TRK00
			JMP SOFTRESET	;* When returned from the program, reset EWOZ.
TESTFD		JSR TRK82		;* Align head to TRK82
			JMP SOFTRESET	;*...

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
ECHO		  PHA				 ;*Save A
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

TRK82		lda #0			; Move the head to TRK82
			sta PRB			; DIR = 0
			lda #1<<7
			sta DDRB		; (Moves the head back)
			jmp TRK
TRK00		lda #1<<7		; Move the head to TRK00
			sta PRB			; DIR = 1
			sta DDRB		; (Moves the head back)
TRK			lda #$20
			sta TAH
			lda #$A4
			sta TBL
			lda #$00
			sta TAL
			sta TBH
			
			lda #%01010101	; Start counter B. Count timer A underflows.
			sta CRB			; One-shot mode.
			lda #%10010111	; Start timer A. Count phase2 clock pulses.
			sta CRA			; Toggle PB6 on underflow. Controls STEP pin.
			lda #$FF
SEEK		cmp TBL			; If counter B value has changed...
			beq SEEK
			lda TBL			; Print character
			bne SEEK
			lda #0
			sta PRB			; DIR = 0
			lda #%10010110  ; Stop timer A. Count phase2 clock pulses.
			sta CRA			; Toggle PB6 on underflow. Controls STEP pin.
			;lda #%01010111	; Start counter B. Count timer A underflows.
			;sta CRB			; Toggle PB7 on underflow. Controls DIR pin.
			rts
; Got rid of intel hex loader and replaced with binary loader
; -5 PADL	Reserved for future expansion
; -4 PADH 	Reserved for future expansion
; -3 SIZEL 	Reserved for future expansion. Must be 0
; -2 SIZEH 	Block count rather
; -1 ADDRL
; -0 ADDRH

BINLOAD		LDA #<MSG2			; Show message
			STA MSGL
			LDA #>MSG2
			STA MSGH
			JSR SHWMSG
			LDY #$6				; Load 6 parameter bytes
PARAM		JSR GETCHAR			; Get parameter
			DEY
			STA PADL,Y		; Store parameter
			BNE PARAM
			LDA SIZEH
			JSR PRBYTE
			LDA SIZEL
			JSR PRBYTE
			LDA #$3A
			JSR ECHO
			LDA ADDRH
			JSR PRBYTE
			LDA ADDRL
			JSR PRBYTE
			LDY #0
LOADDAT		JSR GETCHAR			; Load data. Get byte
			STA (ADDRL),Y		; Store byte
			INY					
			BNE LOADDAT			; Repeat Y $00 until $FF
			INC ADDRH			; Next block of 256 bytes
			DEC SIZEH			; Padding to 256 byte blocks required
			BNE LOADDAT			; Repeat until all bytes have been sent
			LDA #<MSG3			; Show message
			STA MSGL
			LDA #>MSG3
			STA MSGH
			JSR SHWMSG
			RTS


GETCHAR		LDA ACIA_SR		;See if we got an incoming char
			AND #$01		;Test bit 1 (rx register full)
			BEQ GETCHAR	  	;Wait for character
			LDA ACIA_DAT	;Load char
			RTS

MSG1		.asc "Welcome to EWOZ 1.0.",0
MSG2		.asc "Start binary transfer...",0
MSG3		.asc "Binary transfer complete!",0
end:
#ifdef ROM8K
		.dsb ($2000-(end-start)-6),$FF
		.word RESET
		.word RESET
		.word RESET
#endif
#ifdef ROM4K
		.dsb ($1000-(end-start)-6),$FF
		.word RESET
		.word RESET
		.word RESET
#endif