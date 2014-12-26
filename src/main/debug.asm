; Filename	debug.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

dbg_init:
		lda #<dbg_regdump
		sta $FFFE
		lda #>dbg_regdump
		sta $FFFF
		rts

dbg_regdump:
		pha
		lda #'A':jsr dbg_l
		pla
		sta bk_ACC:jsr puth		; Dump accumulator

		jsr dbg_s
		lda #'P':jsr dbg_l
		pla						; Dump status 
		sta bk_STAT:jsr puth

		jsr dbg_s
		lda #'X':jsr dbg_l
		txa						; Dump index X
		sta bk_INX:jsr puth

		jsr dbg_s
		lda #'Y':jsr dbg_l
		tya						; Dump index Y
		sta bk_INY:jsr puth

		jsr dbg_s
		lda #'S':jsr putc:lda #'P':jsr dbg_l
		tsx						; Dump stack pointer
		inx
		inx
		txa
		sta bk_SP:jsr puth
		
		jsr dbg_s
		lda #'P':jsr putc:lda #'C':jsr dbg_l
		pla						; Dump program counter
		sta bk_PCL
		pla
		sta bk_PCH:jsr puth
		lda bk_PCL:jsr puth
		lda bk_STAT				; Restore processor status
		pha
		plp
		lda bk_INX
		tax
		lda #$0d
		jsr putc
		lda bk_ACC
		jmp (bk_PC)				; Return from interrupt
dbg_s:	lda #','
		jsr putc
		rts
dbg_l:	jsr putc
		lda #'='
		jsr putc
		rts