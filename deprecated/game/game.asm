; Dungeon crawler

; Routine: Redraw
; Redraws map screen
REDRAW		ldy #0
DRAW		lda (MAPL),y
		sta TILE
		lda #1
		bit TILE
		bne WALL
		iny
		cmp #8
		bne DRAW
WALL		pha
		lda #"#"
		jsr ECHO
		pla
		jmp DRAW

ECHO		PHA			; *Save A
		AND #$7F		; *Change to "standard ASCII"
		STA ACIA_DAT	 	; *Send it.
WAIT		LDA ACIA_SR	  	; *Load status register for ACIA
		AND #$02		; *Mask bit 2.
		BEQ	 WAIT	 	; *ACIA not done yet, wait.
		PLA			; *Restore A
		RTS			; *Done, over and out...

; Routine: Prompt
; Ask user for input

; Routine: ShwMsg
; Show message

; Routine: Random
; Returns random 8 bit integer value

*	=	$1000
INIT		; Game starts here


MAP	.asc "###################"
	.asc "###################"
	.asc "###################"
	.asc "###################"
	.asc "###################"
