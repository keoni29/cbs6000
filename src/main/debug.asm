; Filename	debug.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

dbg_init:
		lda #<dbg_regdump
		sta $FFFE
		lda #>dbg_regdump
		sta $FFFF
		rts

dbg_regdump:
		sta	bk_ACC				; Dump accumulator and index registers
		stx bk_INX				
		sty bk_INY
		tsx						; Get stack pointer in X
		inx
		lda $0100,x				; Get status and program counter from stack
		sta bk_STAT
		inx
		lda $0100,x
		sta bk_PCL
		inx
		lda $0100,x
		sta bk_PCH
		stx bk_SP 

		lda #'A' : jsr putc		; Present register contents as hex numbers
		lda #'=' : jsr putc
		lda bk_ACC :jsr puth
		lda #',' : jsr putc
		lda #'X' : jsr putc
		lda #'=' : jsr putc
		lda bk_INX :jsr puth
		lda #',' : jsr putc
		lda #'Y' : jsr putc
		lda #'=' : jsr putc
		lda bk_INY :jsr puth
		lda #',' : jsr putc
		lda #'P' : jsr putc
		lda #'=' : jsr putc
		lda bk_STAT :jsr puth
		lda #',' : jsr putc
		lda #'S' : jsr putc
		lda #'=' : jsr putc
		lda bk_SP :jsr puth
		lda #',' : jsr putc
		lda #'P' : jsr putc
		lda #'C' : jsr putc
		lda #'=' : jsr putc
		lda bk_PCH :jsr puth
		lda bk_PCL :jsr puth
		lda #',' : jsr putc
		lda #$0d : jsr putc

		lda bk_ACC				; Restore accumulator and index X
		ldx bk_INX
		rti