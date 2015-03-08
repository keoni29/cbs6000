; VDP test
; by Koen van Vliet <8by8mail@gmail.com>

MSGL		= $2C
MSGH		= $2D
GDEND		= $2E
CRX		= $2F
CRY		= $30

CS		= $01

PRBYTE		= $E16f
ECHO		= $E182

#include "../cbs.inc"

*	=	($1000 - 4)
.word		START
.word		END
START
INITSPI		lda #5
		sta CRX
		sta CRY
		lda #$01
		sta TAL
		lda #$00
		sta TAH
		lda #%01010001	; Start timer in continuous mode
		sta CRA		; and Serial port = output
CLOCKGEN	sta SDR		; Start 8 clock pulses
		bne CLOCKGEN	; Infinite loop
END	.asc $0