ACIA2		  = $D800
ACIA2_CTRL	= ACIA+0
ACIA2_SR	  	= ACIA+0
ACIA2_DAT	 = ACIA+1
*	=	$5000
RESET
			lda #3					; Reset ACIA	
			sta ACIA2_CTRL
			lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA2_CTRL			; * Serial clock/16
									; * 8b 2s no parity
START		lda #"C"
			jsr FSKW
			lda #"B"
			jsr FSKW
			lda #"S"
			jsr FSKW
			lda #" "
			jsr FSKW
			lda #"C"
			jsr FSKW
			lda #"o"
			jsr FSKW
			lda #"m"
			jsr FSKW
			lda #"p"
			jsr FSKW
			lda #"u"
			jsr FSKW
			lda #"t"
			jsr FSKW
			lda #"e"
			jsr FSKW
			lda #"r"
			jsr FSKW
			lda #$0D
			jsr FSKW
			lda #$0A
			jsr FSKW
			jmp START

FSKW		STA ACIA2_DAT			;*Write character.
WAIT		LDA ACIA2_SR			;*Load status register for ACIA2
			AND #$02				;*Mask bit 2.
			BEQ	 WAIT				;*ACIA2 not done yet, wait.
			RTS	