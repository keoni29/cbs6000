*=$5000
		sta $d820
		ldx #$FF
WAIT	nop
		nop
		nop
		dex
		bne WAIT
		lda $d820
		jsr $e13d
		rts
		;8D 20 D8 A2 FF EA EA EA CA D0 FA AD 20 D8 20 3D E1 60