SHWMSG = $E191
PRBYTE = $E16f
MSGDONE = $E446
ECHO = $E182

XAML		= $24			;*Index pointers
XAMH		= $25
STL			= $26
STH			= $27
L			= $28
H			= $29
MSGL		= $2C
MSGH		= $2D

#include "../cbs.inc"

*	=	$0800
LOADER		ldy #0
FLUSH		lda ACIA_DAT		; Flush acia rx before loading
			lda ACIA_SR
			and #$01
			bne FLUSH
PARAMETERS	lda ACIA_SR
			and #$01
			beq PARAMETERS
			lda ACIA_DAT		; Get byte
			sta STL,y			; Store to parameter
			iny
			cpy #4				; Get 4 parameters
			bne PARAMETERS
			lda STL				; Set start address for running
			sta XAML
			lda STH
			sta XAMH
			ldy #0
LOAD		lda ACIA_SR
			and #$01
			beq LOAD
			lda ACIA_DAT		; Get byte
			sta (STL),y			; Store in ram
			lda H
			cmp STH				; Check if we're at the last address already
			bne NOTDONE
			lda L
			cmp STL
			beq DONE
NOTDONE		inc STL				; Advance to next byte
			bne LOAD
			inc STH
			jmp LOAD
DONE		lda #<MSGDONE
			sta MSGL
			lda #>MSGDONE
			sta MSGH
			jsr SHWMSG			; Show done message
			lda XAMH			; Print Start.End address
			jsr PRBYTE
			lda XAML
			jsr PRBYTE
			lda #"."
			jsr ECHO
			lda STH
			jsr PRBYTE
			lda STL
			jsr PRBYTE
			rts					; Return to woz monitor