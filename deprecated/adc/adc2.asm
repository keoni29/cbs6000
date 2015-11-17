#include "../cbs.inc"
PRBYTE	=	$e006
ECHO	=	$e00c
MSGL	=	$2C
MSGH	=	$2D
SHWMSG	=	$e00f

; Loader parameters		
	.word INIT
	.word END - 1

* = $6000
INIT		lda #<COFF
		sta MSGL
		lda #>COFF
		sta MSGH
		jsr SHWMSG
LOOP		lda ACIA_SR
		and #$01
		bne ESCAPE
		lda AD
		sta AD
		jsr PRBYTE
		lda #$0D
		jsr ECHO
		jmp LOOP
ESCAPE		lda #<CON
		sta MSGL
		lda #>CON
		sta MSGH
		jsr SHWMSG
		rts

CON		.asc $1B,"[>5h",$00
COFF		.asc "ADC test (C)2015 by Koen van Vliet",$0A,$0D,$1B,"[>5l",$00

END