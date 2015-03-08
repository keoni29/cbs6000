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
SCROLL		jsr SSHOWMSG
		rts

PRASC		ldx #0
		sec
		sbc #$20
		bmi PADONE
		sta DIGA
PUTASC		lda DIG1,X		; Move all digits one to the left
		sta DIG0,X
		inx
		cpx #6
		bne PUTASC
PADONE		rts

SSHOWMSG	ldy #0			
SPUTDIS		lda (MSGL),Y		; Copy string
		beq SDONE		; Done if character is $0
		jsr PRASC		; Put character on display
		iny
		cpy #6
		bmi SPUTDIS
		bne SSDEL
		jsr DELAY
		jsr DELAY
SSDEL		jsr DELAY		; Add delay for strings 
		jmp SPUTDIS		; longer than 6 characters.
SDONE		rts

DELAY		pha
		tya
		pha
		ldx #128
OUTER		ldy #0
INNER		dey
		bne INNER
		dex
		bne OUTER
		pla
		tay
		pla
		rts
MSG1		.asc "CBS6000 COMPUTER. HELLO WORLD!",0
CLR		.asc "      "
END