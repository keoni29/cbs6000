; Filename: fdmusic.asm
; Author: Koen van Vliet <8by8mail@gmail.com>

#include "../cbs.inc"
; Load at $0200
*			=	$0200

; Move the head to TRK00
TRK00		lda #$40
			sta TAL
			lda #$A0
			sta TBL
			lda #$00
			sta TAH
			sta TBH
			
			lda #1<<7
			sta PRB			; DIR = 1
			sta DDRB		; (Moves the head back)
			lda #%01010101	; Start counter B. Count timer A underflows.
			sta CRB			; One-shot mode.
			lda #%10010111	; Start timer A. Count phase2 clock pulses.
			sta CRA			; Toggle PB6 on underflow. Controls STEP pin.
			lda #$FF
SEEK		cmp TBL			; If counter B value has changed...
			beq SEEK
			lda TBL			; Print character
			pha
			jsr PRBYTE
			pla
			bne SEEK		; Repeat until on TRK00
			rts
			; Note might not have to stop Timer A.
			; lda #%10010110  ; Stop timer A. Count phase2 clock pulses.
			; sta CRA			; Toggle PB6 on underflow. Controls STEP pin.
			; lda #%01010111	; Start counter B. Count timer A underflows.
			; sta CRB			; Toggle PB7 on underflow. Controls DIR pin.