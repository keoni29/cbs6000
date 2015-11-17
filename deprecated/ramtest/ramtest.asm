RAM_START = $1000
RAM_END = $CFFF
ptr = $02
ptrl = $02
ptrh = $03

* = $0200

init	lda #4			; Turn on status LED
		sta $00

		lda #<RAM_END
		sta ptrl
		lda #>RAM_END
		sta ptrh
		ldy #0
writeloop
		lda #$55
		sta (ptr),y
		sec				; Decrement ram address
		lda #1
		sbc ptrl
		sta ptrl
		lda #0
		sbc ptrh
		sta ptrh
		lda #$10
		and ptrh
		bne writeloop
		lda #<RAM_END
		sta ptrl
		lda #>RAM_END
		sta ptrh
readloop
		lda #$55
		cmp (ptr),y
		bne error
		sec				; Decrement ram address
		lda #1
		sbc ptrl
		sta ptrl
		lda #0
		sbc ptrh
		sta ptrh
		lda #$10
		and ptrh
		bne readloop
end		eor #4 
		sta $01
		jsr delay2
		jmp end

error	eor #4 
		sta $01
		jsr delay1
		jmp error

delay2	ldx #$10		; Initialize delay counter
		jmp outer
delay1	ldx #$80		; Initialize delay counter
outer	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner	dey
		bne inner
		dex
		bne outer
		beq error		; Jump back to the start