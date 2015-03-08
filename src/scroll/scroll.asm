#include "../cbs.inc"

DIGN		= $43			; Seven segment digits
DIG0		= $44
DIG1		= $45
DIG2		= $46
DIG3		= $47
DIG4		= $48
DIG5		= $49
DIGA		= $4A

MSGL		= $2C
MSGH		= $2D

	.word START
	.word END - 1
*	=	$1000

START		lda #<MSG1
		sta MSGL
		lda #>MSG1
		sta MSGH
		jmp MAIN
MSG1	.asc "HELLO WORLD!",0
MAIN		lda ACIA_SR	  	; *See if we got an incoming char
		and #$01		; *Test bit 1
		beq MAIN	 	; *Wait for character
		lda ACIA_DAT	 	; *Load char
		cmp #$1B		; ESC?
		beq SCROLL		; Yes, go to scroller
		cmp #$60		; *Is it Lower case
		bmi CONVERT		; *Nope, just convert it
		and #$5F		; *If lower case, convert to Upper case
CONVERT		jsr PRASC		; Print character on display
		jmp MAIN

SCROLL		ldy #0
LOOP		lda (MSGL),Y
		beq MAIN
		jsr PRASC
		iny
		jsr DELAY
		jmp LOOP

PRASC		ldx #0
		sec
		sbc #$20
		sta DIGA
PUTASC		lda DIG1,X	; Move all digits one to the left
		sta DIG0,X
		inx
		cpx #6
		bne PUTASC
		rts

DELAY		pha
		txa
		pha
		tya
		pha
		ldx #0
OUTER		ldy #0
INNER		dey
		bne INNER
		dex
		bne OUTER
		pla
		tay
		pla
		tax
		pla
		rts
END