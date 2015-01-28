; ISR Receive byte from CIA serial port
isr_rx:	pha
		txa
		pha
		tya
		pha

		ldx SDR								; Read character from CIA
		lda #64
		and rxcnt				 			; Check if buffer is full
		bne rx_full
		
		lda #63
		and rxp	            				; Limit buffer size to 64 bytes
		tay
		stx RX_BUFF,y	      				; Store character in buffer
		inc rxp              				; Advance buffer pointer
		inc rxcnt              				; Increase read offset

rx_full:pla
		tay
		pla
		tax
		pla
		rti