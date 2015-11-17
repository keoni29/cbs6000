; VDP test
; by Koen van Vliet <8by8mail@gmail.com>

MSGL		= $2C
MSGH		= $2D
GDEND		= $2E
CRX		= $2F
CRY		= $30

CS		= $01

PRBYTE		= $e006
ECHO		= $e00c

#include "../cbs.inc"
#include "gd.inc"

.word		START
.word		END - 1
*	=	$400
START		lda #5
		sta CRX
		sta CRY

		;jmp NEXTCHAR ; DEBUG
INITSPI		lda #5
		sta CRX
		sta CRY
		lda #$01
		sta TAL
		lda #$00
		sta TAH
		lda #%01010001			; Start timer in continuous mode, Serial port = output
		sta CRA
		lda #CS				; Device not selected 
		sta PRA
		sta DDRA
; Write 16 bit value to VDP.
GDINIT		wr(J1_RESET,1)			; Halt co-processor
		wr16(BG_COLOR,c_blue)
		ldx #$80			; Clear all sprite data
		ldy #$30
		lda #0
SPRITEFILL	stx GDEND
FILL1		jsr GDFILL256
		iny
		cpy GDEND
		bne FILL1
		ldx #$10			; All characters to spaces
		ldy #$00
		lda #$20
SCREENFILL	stx GDEND
FILL2		jsr GDFILL256
		iny
		cpy GDEND
		bne FILL2
		ldy #>VOICES			; Silence
		lda #0
		jsr GDFILL256
		wr16(PALETTE16A,$8000) 		; Set palette to transparent
		wr16(SCROLL_X, 0)
		wr16(SCROLL_Y,0)
		wr(JK_MODE,0)
		wr(SPR_DISABLE,0)
		wr(SPR_PAGE,0)
		wr(IOMODE,0)
		wr16(SAMPLE_L,0)
		wr16(SAMPLE_R,0)
		wr16(SCREENSHOT_Y,0)
		wr(MODULATOR,64)
		;lda #$41
		;jsr GDECHO
		;jsr GDECHO
		;jsr GDECHO
		;jsr GDECHO
		;jsr GDECHO
		;rts
NEXTCHAR	lda ACIA_SR	  		; See if we got an incoming char
		and #$01			; Test bit 1
		beq NEXTCHAR	 		; Wait for character
		lda ACIA_DAT	 		; Load char
		cmp #$1B			; Escape?
		beq STOP
		jsr GDECHO
		jmp NEXTCHAR
STOP		rts


GDECHO		pha
		pha
		lda #($FF^CS)			; Select device
		and PRA
		sta PRA
		lda CRY
		ror				; Addr = CRY*64 + CRX
		sec				; Write mode ($80)
		ror				
		and #$BF
		jsr SPI				; Transfer high address byte
		lda CRY
		ror
		ror
		and #$C0
		clc
		adc CRX
		jsr SPI				; Transfer low address byte
		pla
		jsr SPI				; Transfer character
		lda #CS				; Deselect device
		ora PRA
		sta PRA
		inc CRX				; Advance cursor position
NOECHO		pla
		rts				; Return

; Y = address high byte
GDFILL256	pha
		lda #($FF^CS)			; Select device
		and PRA
		sta PRA
		tya				; Get high address byte in A
		ora #$80
		jsr SPI
		lda #$00
		jsr SPI
		ldx $00
		pla
		pha
FILL256		jsr SPI				; Fill VDP ram with A
		dex
		bne FILL256
		lda #CS				; Deselect device
		ora PRA
		sta PRA
		pla
		rts

SPI		pha
		sta SDR				; Transfer byte
SPIWAIT		lda ICR				; Wait for transfer to complete
		and #(1<<3)
		beq SPIWAIT
		pla
		rts
END