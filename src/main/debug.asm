; Filename	debug.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

dbg_init:
		lda #<dbg_regdump
		sta $FFFE
		lda #>dbg_regdump
		sta $FFFF
		rts

dbg_regdump:
		sta bk_ACC:jsr puth		; Dump accumulator
		pla						; Dump status 
		sta bk_STAT:jsr puth
		tya						; Dump index Y
		sta bk_INY:jsr puth
		txa						; Dump index X
		sta bk_INX:jsr puth
		tsx						; Dump stack pointer
		inx
		inx
		txa
		sta bk_SP:jsr puth
		pla						; Dump program counter
		sta bk_PCL:jsr puth
		pla
		sta bk_PCH:jsr puth
		lda bk_STAT				; Restore processor status
		pha
		plp
		jsr statled
		jmp (bk_PC)				; Return from interrupt