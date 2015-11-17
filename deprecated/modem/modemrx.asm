; CBS6000 memory map
ACIA		= $D800
ACIA_CTRL	= ACIA+0
ACIA_SR		= ACIA+0
ACIA_DAT	= ACIA+1

ACIA2		= $D820
ACIA2_CTRL	= ACIA2+0
ACIA2_SR	= ACIA2+0
ACIA2_DAT	= ACIA2+1

; Zero Page
MSGL		= $2C
MSGH		= $2D

* = $5000
RESET		;lda #3					; Reset ACIA	
			;sta ACIA2_CTRL
			lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA2_CTRL			; 
									; 
NEXTCHAR	LDA ACIA_SR	  			; Wait for user input
			AND #$01		  		;
			BEQ NEXTCHAR	 		;
			LDA ACIA_DAT	 		;

			STA ACIA2_DAT			; Send trough FSK modem 
WAIT1		LDA ACIA2_SR			;
			AND #$02				;
			BEQ	 WAIT1				;

			LDA ACIA2_SR	  		; Check if a character was received
			AND #$01		  		; on the modem.
			BEQ NOCHAR	 			; No character received
			LDA ACIA2_DAT	 		;
ECHO		STA ACIA_DAT			; Print character
WAIT2		LDA ACIA_SR				;
			AND #$02				;
			BEQ	 WAIT2				;
			JMP NEXTCHAR
NOCHAR		LDA #"?"				;
			JMP ECHO