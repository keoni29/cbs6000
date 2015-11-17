; CBS6000 memory map
ACIA2		= $D800
ACIA2_CTRL	= ACIA2+0
ACIA2_SR	= ACIA2+0
ACIA2_DAT	= ACIA2+1

; Zero Page
MSGL		= $2C
MSGH		= $2D

*	=	$5000
RESET
			;lda #3					; Reset ACIA	
			;sta ACIA2_CTRL
			lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA2_CTRL			; * Serial clock/16
									; * 8b 2s no parity
			lda #<MSG
			sta MSGL
			lda #>MSG
			sta MSGH
START		jsr SHWMSG
			jmp START

FSKW		STA ACIA2_DAT			;*Write character.
WAIT		LDA ACIA2_SR			;*Load status register for ACIA2
			AND #$02				;*Mask bit 2.
			BEQ	 WAIT				;*ACIA2 not done yet, wait.
			RTS
SHWMSG		LDY #$0
PRINT		LDA (MSGL),Y
			BEQ DONE
			JSR FSKW
			INY 
			BNE PRINT
DONE		RTS 
MSG			.asc "CBS Computer",$0A,$0D,$0