; EWOZ Extended Woz Monitor.
; Just a few mods to the original monitor.
; Modified for personal use by Koen van Vliet <8by8mail@gmail.com>

#define SEGDELAY (360*8)-1
#define ROM8K

; Memory locations used by the monitor
IN			= $0200			;*Input buffer
XAML		= $24			;*Index pointers
XAMH		= $25
STL			= $26
STH			= $27
L			= $28
H			= $29
YSAV		= $2A
MODE		= $2B
MSGL		= $2C
MSGH		= $2D
COUNTER		= $2E
CRC			= $2F
CRCCHECK	= $30

; Memory locations used for the modem/casette interface
CASEN		= $31

; Memory locations used by interrupts
ISRL		= $41			; ISR vector
ISRH		= $42
DIGN		= $43			; Seven segment digits
DIG0		= $44
DIG1		= $45
DIG2		= $46
DIG3		= $47
DIG4		= $48
DIG5		= $49
DIGA		= $4A

#include "../../cbs.inc"

;=========================================================================
* = $E000
RESET		CLD				 		; Clear decimal arithmetic mode.
			sei						; Disable interrupts
			ldx #$FF
			txa						; Init stack
			lda #3
			sta ACIA_CTRL			; Reset ACIA
			sta ACIA2_CTRL			; Reset ACIA2 (modem)

			lda #<DUMMYISR			; Default user ISR
			sta ISRL
			lda #>DUMMYISR
			sta ISRH

			jsr ENSEG				; Enable seven segment display
			lda #<DMSG1
			sta MSGL
			lda #>DMSG1
			sta MSGH
			jsr SSHOWMSG			; Put message on 7 segment display digits

			lda #(1<<4)|(1<<0)		; Initialize ACIA and ACIA2(modem)
			sta ACIA_CTRL			; * Serial clock/16
			sta ACIA2_CTRL			; * 8b 2s no parity

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

			cli						; Enable interrupts
;=========================================================================
SOFTRESET	LDA #$9B				;* Auto escape.
NOTCR		CMP #$88		  ;"<-"? * Note this was changed to $88 which is the back space key.
			BEQ BACKSPACE	;Yes.
			CMP #$9B		  ;ESC?
			BEQ ESCAPE		;Yes.
			INY				 ;Advance text index.
			BPL NEXTCHAR	 ;Auto ESC if >127.
ESCAPE		LDA #$DC		  ;"\"
			JSR ECHO		  ;Output it.
GETLINE		LDA #$8D		  ;CR.
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
CONVERT		ORA #$80		  ;*Convert it to "ASCII Keyboard" Input
			STA IN,Y		  ;Add to text buffer.
			JSR ECHO		  ;Display character.
			CMP #$8D		  ;CR?
			BNE NOTCR		 ;No.
			LDY #$FF		  ;Reset text index.
			LDA #$00		  ;For XAM mode.
			sta CASEN		; Disable casette save mode
			TAX				 ;0->X.
SETSTOR		ASL				 ;Leaves $7B if setting STOR mode.
SETMODE		STA MODE		  ;$00 = XAM, $7B = STOR, $AE = BLOK XAM.
BLSKIP		INY				 ;Advance text index.
NEXTITEM	LDA IN,Y		  ;Get character.
			CMP #$8D		  ;CR?
			BEQ GETLINE	  ;Yes, done this line.
			CMP #$AE		  ;"."?
			BCC BLSKIP		;Skip delimiter.
			BEQ SETMODE	  ;Set BLOCK XAM mode.
			CMP #$BA		  ;":"?
			BEQ SETSTOR	  ;Yes, set STOR mode.
			CMP #">"+$80		;">"?
			BEQ	SETSAVE		; Yes, Save to casette
			CMP #"<"+$80		; "<"?
			BEQ	SETLOAD		; Yes, Load from casette
			CMP #$D2		  ;"R"?
			BEQ RUN			;Yes, run user program.
			CMP #$CC		  ;* "L"?
			BEQ LOADINT	  ;* Yes, Load Intel Code.
			STX L			  ;$00->L.
			STX H			  ; and H.
			STY YSAV		  ;Save Y for comparison.
NEXTHEX		LDA IN,Y		  ;Get character for hex test.
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
HEXSHIFT	ASL				 ;Hex digit left MSB to carry.
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
JNEXTITEM	JMP NEXTITEM	; Had to be a bit creative because of a branch that was out of range
LOADINT		JSR LOADINTEL	;* Load the Intel code.
			JMP	SOFTRESET	;* When returned from the program, reset EWOZ.
SETSAVE		lda #01
			sta CASEN
			jmp BLSKIP
SETLOAD		jsr LOADCAS 
			jmp SOFTRESET
NOESCAPE	lda CASEN
			beq ISXAM
			jsr SAVECAS
			jmp SOFTRESET
ISXAM		BIT MODE		  ;Test MODE byte.
			BVC NOTSTOR	  ;B6=0 for STOR, 1 for XAM and BLOCK XAM
			LDA L			  ;LSD's of hex data.
			STA (STL, X)	 ;Store at current "store index".
			INC STL			;Increment store index.
			BNE JNEXTITEM	 ;Get next item. (no carry).
			INC STH			;Add carry to 'store index' high order.
TONEXTITEM  JMP NEXTITEM	 ;Get next command item.
NOTSTOR		BMI XAMNEXT	  ;B7=0 for XAM, 1 for BLOCK XAM.
			LDX #$02		  ;Byte count.
SETADR		LDA L-1,X		 ;Copy hex data to
			STA STL-1,X	  ;"store index".
			STA XAML-1,X	 ;And to "XAM index'.
			DEX				 ;Next of 2 bytes.
			BNE SETADR		;Loop unless X = 0.
NXTPRNT		BNE PRDATA		;NE means no address to print.
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
XAMNEXT		STX MODE		  ;0-> MODE (XAM mode).
			LDA XAML
			CMP L			  ;Compare 'examine index" to hex data.
			LDA XAMH
			SBC H
			BCS TONEXTITEM  ;Not less, so no more data to output.
			INC XAML
			BNE MOD8CHK	  ;Increment 'examine index".
			INC XAMH
MOD8CHK		LDA XAML		  ;Check low-order 'exainine index' byte
			AND #$0F		  ;For MOD 8=0 ** changed to $0F to get 16 values per row **
			BPL NXTPRNT	  ;Always taken.
PRBYTE		PHA				 ;Save A for LSD.
			LSR
			LSR
			LSR				 ;MSD to LSD position.
			LSR
			JSR PRHEX		 ;Output hex digit.
			PLA				 ;Restore A.
PRHEX		AND #$0F		  ;Mask LSD for hex print.
			ORA #$B0		  ;Add "0".
			CMP #$BA		  ;Digit?
			BCC ECHO		  ;Yes, output it.
			ADC #$06		  ;Add offset for letter.
ECHO		PHA				 ;*Save A
			AND #$7F		  ;*Change to "standard ASCII"
			STA ACIA_DAT	 ;*Send it.
WAIT		LDA ACIA_SR	  ;*Load status register for ACIA
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

;=========================================================================
; Load an program in Intel Hex Format.
LOADINTEL	LDA #$0D
			JSR ECHO		;New line.
			LDA #<MSG2
			STA MSGL
			LDA #>MSG2
			STA MSGH
			JSR SHWMSG		;Show Start Transfer.
			LDA #$0D
			JSR ECHO		;New line.
			LDY #$00
			STY CRCCHECK	;If CRCCHECK=0, all is good.
INTELLINE	JSR GETCHAR		;Get char
			STA IN,Y		;Store it
			INY				;Next
			CMP	#$1B		;Escape ?
			BEQ	INTELDONE	;Yes, abort.
			CMP #$0D		;Did we find a new line ?
			BNE INTELLINE	;Nope, continue to scan line.
			LDY #$FF		;Find (:)
FINDCOL		INY
			LDA IN,Y
			CMP #$3A		; Is it Colon ?
			BNE FINDCOL		; Nope, try next.
			INY				; Skip colon
			LDX	#$00		; Zero in X
			STX	CRC			; Zero Check sum
			JSR GETHEX		; Get Number of bytes.
			STA COUNTER		; Number of bytes in Counter.
			CLC				; Clear carry
			ADC CRC			; Add CRC
			STA CRC			; Store it
			JSR GETHEX		; Get Hi byte
			STA STH			; Store it
			CLC				; Clear carry
			ADC CRC			; Add CRC
			STA CRC			; Store it
			JSR GETHEX		; Get Lo byte
			STA STL			; Store it
			CLC				; Clear carry
			ADC CRC			; Add CRC
			STA CRC			; Store it
			LDA #$2E		; Load "."
			JSR ECHO		; Print it to indicate activity.
NODOT		JSR GETHEX		; Get Control byte.
			CMP	#$01		; Is it a Termination record ?
			BEQ	INTELDONE	; Yes, we are done.
			CLC				; Clear carry
			ADC CRC			; Add CRC
			STA CRC			; Store it
INTELSTORE	JSR GETHEX		; Get Data Byte
			STA (STL,X)		; Store it
			CLC				; Clear carry
			ADC CRC			; Add CRC
			STA CRC			; Store it
			INC STL			; Next Address
			BNE TESTCOUNT	; Test to see if Hi byte needs INC
			INC STH			; If so, INC it.
TESTCOUNT	DEC	COUNTER		; Count down.
			BNE INTELSTORE	; Next byte
			JSR GETHEX		; Get Checksum
			LDY #$00		; Zero Y
			CLC				; Clear carry
			ADC CRC			; Add CRC
			BEQ INTELLINE	; Checksum OK.
			LDA #$01		; Flag CRC error.
			STA	CRCCHECK	; Store it
			JMP INTELLINE	; Process next line.

INTELDONE	LDA CRCCHECK	; Test if everything is OK.
			BEQ OKMESS		; Show OK message.
			LDA #$0D
			JSR ECHO		;New line.
			LDA #<MSG4		; Load Error Message
			STA MSGL
			LDA #>MSG4
			STA MSGH
			JSR SHWMSG		;Show Error.
			LDA #$0D
			JSR ECHO		;New line.
			RTS

OKMESS		LDA #$0D
			JSR ECHO		;New line.
			LDA #<MSG3		;Load OK Message.
			STA MSGL
			LDA #>MSG3
			STA MSGH
			JSR SHWMSG		;Show Done.
			LDA #$0D
			JSR ECHO		;New line.
			RTS

GETHEX		LDA IN,Y		;Get first char.
			EOR #$30
			CMP #$0A
			BCC DONEFIRST
			ADC #$08
DONEFIRST	ASL
			ASL
			ASL
			ASL
			STA L
			INY
			LDA IN,Y		;Get next char.
			EOR #$30
			CMP #$0A
			BCC DONESECOND
			ADC #$08
DONESECOND	AND #$0F
			ORA L
			INY
			RTS

GETCHAR		LDA ACIA_SR	  ;See if we got an incoming char
			AND #$01		  ;Test bit 1 (rx register full)
			BEQ GETCHAR	  ;Wait for character
			LDA ACIA_DAT	 ;Load char
			RTS
;=========================================================================
SCLEAR		lda #<CLR				; Clear display
			sta MSGL
			lda #>CLR
			sta MSGH
			jsr SSHOWMSG
			rts

SSHOWMSG	ldy #6					; Repeat for all 6 digits
SPUTDIS		dey
			lda (MSGL),Y			; Copy string
			sec
			sbc #$20				; Convert character
			sta DIG0,Y				; to display
			cpy #0
			bne SPUTDIS
			rts

ENSEG		lda #0					; Go to first digit
			sta DIGN
			lda #$07				; Set PA0..PA2 to output 
			ora DDRA2
			sta DDRA2
			lda #$FF				; Set PB0..PB7 to output
			sta DDRB2
			lda #<SEGDELAY			; Set timer B delay
			sta TBL2
			lda #>SEGDELAY
			sta TBH2
			lda #%00010001			; Start timer in continuous mode
			sta CRB2
			lda #%10000010			; Enable timer B underflow interrupts
			sta ICR2
			rts

SEVSEG		tya
			pha
			lda DIGN
			sta PRA2				; Select digit
			ldy DIGN
			lda DIG0,Y				; Get character
			tax
			lda SEGS,X				; Lookup shape
			sta PRB2				; Drive LED segments
			lda #05
			cmp DIGN				; * At last digit?				
			bne NEXTSEG				; * Yes, return to first one.
			lda #0
			sta DIGN
			beq ENDSEG
NEXTSEG		inc DIGN				; Go to the next digit
ENDSEG		pla
			tay
			rts
;=========================================================================
ISR			pha
			txa
			pha
			lda ICR2				; Acknowledge interrupt
			jmp (ISRL)				; Execute user interrupt
DUMMYISR	and #2					; Check timer B overflow
			beq NOSEVSEG			; No, don't refresh display
			jsr SEVSEG
NOSEVSEG	pla
			tax
			pla
			rti
;=========================================================================
LOADCAS		ldy #0
FLUSH		lda ACIA2_DAT			; Flush acia rx re before loading
			lda ACIA2_SR
			and #$01
			bne FLUSH
WAITLOAD	lda ACIA_SR	  			; Got user input?
			and #$01		  		;
			bne CASESC		 		; Yes, escape from loader.
GETMOD		lda ACIA2_SR	  		; *Check if a byte was received
			and #$01		  		; *on the modem.
			beq WAITLOAD	 		; *No, go back
			lda ACIA2_DAT			; Get byte from modem
			sta (STL),y				; Store byte
			lda #$2E
			sta ACIA_DAT			; Print dot to indicate activity
			inc STL					; Advance to next address
			bne WAITLOAD			; Low byte overflow?
			inc STH					; Yes, Increment high byte of address
CASESC		lda ACIA_DAT			; Load character
			cmp #$1B				; Is escape character?
			bne WAITLOAD			; No, go back.
ENDCAS		lda #<CMSG3
			sta MSGL
			lda #>CMSG3
			sta MSGH
			jsr SHWMSG				; Show load done message
			lda XAMH
			jsr PRBYTE				; Print start and end address
			lda XAML				
			jsr PRBYTE
			lda #"."
			jsr ECHO
			lda STH
			jsr PRBYTE
			lda STL
			jsr PRBYTE
			lda #$0D				; CR NL
			jsr ECHO
			lda #$0A
			jsr ECHO
			rts						; Return

SAVECAS		lda #<CMSG2
			sta MSGL
			lda #>CMSG2
			sta MSGH
			jsr SHWMSG
WAITREC		lda ACIA_SR	  			; Got user input?
			and #$01		  		;
			beq WAITREC		 		; Yes, escape from loader.
			lda ACIA_DAT
			ldy #0
WAITSAVE	lda ACIA_SR	  			; Got user input?
			and #$01		  		;
			bne CASESC		 		; Yes, escape from loader.
SENDMOD		lda ACIA2_SR			; *Can send?
			and #$02				;
			beq	WAITSAVE			; *No, go back
			lda (STL),y	 			; *Get byte from ram
			sta ACIA2_DAT			; *Send trough FSK modem
			lda L
			cmp STL
			bne NOTDONE
			lda H
			cmp STH
			beq ENDCAS
NOTDONE		inc STL					; Advance to next address
			bne WAITSAVE			; Low byte overflow?
			inc STH					; Yes, Increment high byte of address
			jmp WAITSAVE			; Repeat for all bytes



MSG1		.asc "Welcome to EWOZ 1.0.",0
MSG2		.asc "Start Intel Hex code Transfer.",0
MSG3		.asc "Intel Hex Imported OK.",0
MSG4		.asc "Intel Hex Imported with checksum error.",0
CMSG1		.asc "Press PLAY on tape.",0
CMSG2		.asc "Press RECORD and PLAY on tape.",0
CMSG3		.asc "Done!",0
DMSG1		.asc "READY "
CLR			.asc	0,0,0,0,0,0

SEGS		.byte $00, $82, $21, $00, $00, $00, $00, $02, $39, $0F	; Symbols
			.byte $00, $00, $00, $40, $80, $52
			.byte $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F	; Numbers

			.byte $00, $00, $00, $48, $00, $53, $00					; Symbols

			.byte $77, $7C, $39, $5E, $79, $71, $6F, $76, $06, $1E	; Letters
			.byte $76, $38, $55, $54, $3F, $73, $67, $50, $6D, $78
			.byte $3E, $FE, $1C, $76, $6E, $5B

END		
#ifdef ROM4K
		.dsb ($1000-(END-RESET)-6),$FF
		.word RESET
		.word RESET
		.word ISR
#endif
#ifdef ROM8K
		.dsb ($2000-(END-RESET)-6),$FF
		.word RESET
		.word RESET
		.word ISR
#endif