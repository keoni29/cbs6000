#include "../cbs.inc"

; Operating system parameters
		MSGL		= $2C
		MSGH		= $2D
; Operating system routines
		ECHO		= $E00C
		DELAY		= $E01B

#define dat()lda #(1<<SPI_DC):ora PRA:sta PRA
#define cmd()lda #($FF^(1<<SPI_DC)):and PRA:sta PRA

#define wr(val)lda #($FF^(1<<SPI_EN)):and PRA:sta PRA:lda #val:jsr SPI:lda #(1<<SPI_EN):ora PRA:sta PRA


.word		START			; Loader parameters
.word		END - 1
*=$800
START		lda #$06
		sta TAL
		lda #$00
		sta TAH
		lda #%01010001		; Start timer in continuous mode, Serial port = output
		sta CRA
		lda #(1<<SPI_EN)
		sta PRA
		lda #((1<<SPI_EN) | (1<<SPI_RST) | (1<<SPI_DC));
		sta DDRA		; Reset LCD screen
		lda #(1<<SPI_RST)
		ora PRA
		cmd()
		wr($21)			; LCD Extended Commands.
		wr($C1)			; Set LCD Vop (Contrast). E1,A1,D1
		wr($04)			; Set Temp coefficent. //0x04
		wr($14)			; LCD bias mode 1:48. //0x13
		wr($0C)			; LCD in normal mode.
		wr($20)
		wr($0C)
		dat()
  		;wr($FF)

  		; Set cursor position:
  		;cmd()
  		;wr($80)		; Column 0 
  		;wr($40)		; Row 0 
  		;dat()
  		wr($0F)
  		wr($02)
  		wr($0F)
  		wr($02)
  		wr($0F)
  		wr($02)
  		wr($0F)
  		wr($02)
		rts

SPI		pha
		sta SDR			; Transfer byte
SPIWAIT		lda ICR			; Wait for transfer to complete
		and #(1<<3)
		beq SPIWAIT
		pla
		rts
END