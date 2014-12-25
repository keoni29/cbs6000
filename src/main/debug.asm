; Filename	debug.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

dbg_init:
		lda #<dbg_regdump
		sta $FFFE
		lda #>dbg_regdump
		sta $FFFF
		rts

dbg_regdump:
		sta bk_ACC:jsr putc		; Dump accumulator
		pla						; Dump status 
		sta bk_STAT:jsr putc
		tya						; Dump index Y
		sta bk_INY:jsr putc
		txa						; Dump index X
		sta bk_INX:jsr putc
		tsx						; Dump stack pointer
		dex
		dex
		txa
		sta bk_SP:jsr putc
		pla						; Dump program counter
		sta bk_PCL:jsr putc
		pla
		sta bk_PCH:jsr putc
		lda bk_STAT				; Restore processor status
		pha
		plp
		jsr statled
		jmp (bk_PC)				; Return from interrupt