;===========================================================================
; G A M E D U I N O   A D D R E S S E S
;===========================================================================
RAM_PIC     	=	$0000    ; Screen Picture, 64 x 64 = 4096 bytes
RAM_CHR     	=	$1000    ; Screen Characters, 256 x 16 = 4096 bytes
RAM_PAL     	=	$2000    ; Screen Character Palette, 256 x 8 = 2048 bytes

IDENT         	=	$2800
REV           	=	$2801
FRAME         	=	$2802
VBLANK        	=	$2803
SCROLL_X      	=	$2804
SCROLL_Y      	=	$2806
JK_MODE       	=	$2808
J1_RESET      	=	$2809
SPR_DISABLE   	=	$280a
SPR_PAGE      	=	$280b
IOMODE        	=	$280c

BG_COLOR      	=	$280e
SAMPLE_L      	=	$2810
SAMPLE_R      	=	$2812

MODULATOR     	=	$2814

SCREENSHOT_Y 	=	$281e

PALETTE16A 	=	$2840   ; 16-color palette RAM A, 32 bytes
PALETTE16B 	=	$2860   ; 16-color palette RAM B, 32 bytes
PALETTE4A  	=	$2880   ; 4-color palette RAM A, 8 bytes
PALETTE4B  	=	$2888   ; 4-color palette RAM A, 8 bytes
COMM       	=	$2890   ; Communication buffer
COLLISION  	=	$2900   ; Collision detection RAM, 256 bytes
VOICES     	=	$2a00   ; Voice controls
J1_CODE    	=	$2b00   ; J1 coprocessor microcode RAM
SCREENSHOT 	=	$2c00   ; screenshot line RAM

RAM_SPR     	=	$3000    ; Sprite Control, 512 x 4 = 2048 bytes
RAM_SPRPAL  	=	$3800    ; Sprite Palettes, 4 x 256 = 2048 bytes
RAM_SPRIMG  	=	$4000    ; Sprite Image, 64 x 256 = 16384 bytes

;===========================================================================
; C O L O R   V A L U E S
;===========================================================================
c_red		=	$7C00
c_green		=	$03E0
c_dkgreen	=	$00E0
c_blue		=	$001F
c_black		=	$0000
c_white		=	$7FFF
c_alpha		=	$8000

#define wr16(addr,val)lda #($FF^CS):and PRA:sta PRA:lda #>addr:ora #$80:jsr SPI:lda #<addr:jsr SPI:lda #<val:jsr SPI:lda #>val:jsr SPI:lda #CS:ora PRA:sta PRA:
#define wr(addr,val)lda #($FF^CS):and PRA:sta PRA:lda #>addr:ora #$80:jsr SPI:lda #<addr:jsr SPI:lda #val:jsr SPI:lda #CS:ora PRA:sta PRA