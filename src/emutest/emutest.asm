; Assemble using xa emutest.asm
#include "../cbs.inc"

MSGL		= $2C
MSGH		= $2D

*=$E000
START		lda #<MSG1
			sta MSGL
			lda #>MSG1
			sta MSGH
			jsr SHWMSG
			jmp START

PRBYTE		PHA				; Save A for LSD.
			LSR
			LSR
			LSR				; MSD to LSD position.
			LSR
			JSR PRHEX		; Output hex digit.
			PLA				; Restore A.
PRHEX		AND #$0F		; Mask LSD for hex print.
			ORA #$B0		; Add "0".
			CMP #$BA		; Digit?
			BCC ECHO		; Yes, output it.
			ADC #$06		; Add offset for letter.
ECHO		PHA				; *Save A
			AND #$7F		; *Change to "standard ASCII"
			STA ACIA_DAT	; *Send it.
WAIT		LDA ACIA_SR	  	; *Load status register for ACIA
			AND #$02		; *Mask bit 2.
			BEQ	 WAIT	 	; *ACIA not done yet, wait.
			PLA				; *Restore A
			RTS				; *Done, over and out...

SHWMSG		LDY #$0
PRINT		LDA (MSGL),Y
			BEQ DONE
			JSR ECHO
			INY 
			BNE PRINT
DONE		RTS

ISR			rti				; Return from interrupt

MSG1		.asc "Hello, World!",$0A, $0D,"This program can run on the cbs6000 computer!", $0A, $0D, $00
END			
			; Padding to 8k
			.dsb ($2000-(END-START)-6),$FF
			.word START
			.word START
			.word ISR