; Filename	string.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

; Byte to hexadecimal string
; input		A
; uses		A,Y
; output	Writes string at string pointer
b2hex:	pha
		ror:ror:ror:ror
		and #$0F
		tay
		lda b2hex_lut,y
		ldy #0
		sta (sstr),y		; 4 most significant bits
		pla
		and #$0F
		tay
		lda b2hex_lut,y
		ldy #1
		sta (sstr),y		; 4 least significant bits
		rts

; Increment string pointer by 1 + A
sstr_inca:
		sec
		adc sstr
		sta sstr
		lda #0
		adc sstr + 1
		sta sstr + 1
		rts