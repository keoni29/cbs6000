; VDP test
; by Koen van Vliet <8by8mail@gmail.com>

MSGL		= $2C
MSGH		= $2D
ADL		= $2E
ADH		= $2F
CS		= $01

#include "../cbs.inc"
#include "gd.inc"

*	=	($1000 - 4)
.word		INITSPI
.word		END
INITSPI		lda #$01
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
		wr16(BG_COLOR,c_black)
		wr16(SAMPLE_L,0)
		wr16(SAMPLE_R,0)
		wr16(SCREENSHOT_Y,0)
		wr(MODULATOR,64)
		rts

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
FILL		jsr SPI				; Fill VDP ram with A
		dex
		bne FILL
		lda #CS				; Deselect device
		ora PRA
		sta PRA
		rts

SPI		pha
		sta SDR				; Transfer byte
SPIWAIT		lda ICR				; Wait for transfer to complete
		and #(1<<3)
		beq SPIWAIT
		pla
END		rts