; Modem loopback test

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
RESET		lda #(1<<4)|(1<<0)		; Initialize ACIA
			sta ACIA2_CTRL			; 
GETCHAR		lda ACIA_SR	  			; Got char?
			and #$01		  		;
			bne SENDMOD		 		; Yes, send to modem
GETMOD		lda ACIA2_SR	  		; *Check if a character was received
			and #$01		  		; *on the modem.
			beq GETCHAR	 			; *No, go back
ECHO		lda ACIA_SR				; Can send?
			and #$02				;
			beq	ECHO				; No, try again
			lda ACIA2_DAT	 		;
			sta ACIA_DAT			; Print character
			jmp GETCHAR
SENDMOD		lda ACIA2_SR			; *Can send?
			and #$02				;
			beq	GETMOD				; *No, go back
			lda ACIA_DAT	 		; *Get char
			sta ACIA2_DAT			; *Send trough FSK modem
			jmp GETCHAR