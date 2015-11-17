; Assemble using xa printtest.asm
#include "../cbs.inc"

; Operating system parameters
		MSGL		= $2C
		MSGH		= $2D
		XAML		= $24
		XAMH		= $25
		STL		= $26
		STH		= $27
		L		= $28
		H		= $29
; Operating system routines
		ECHO		= $E00C
		SHWMSG		= $E00F
		BCOPY		= $E02D
; Switch macro for switching banks.
#define SWITCH	lda #(1<<BANKSW) : eor PORT : sta PORT


.word		START			; Loader parameters
.word		END - 1
*=$300
START		sei			; Disable interrupts
		lda #0
		sta PORT
		lda #(1<<BANKSW) | (1<<ROMDIS)
		sta DDR
		lda #<MSG1
		sta MSGL
		lda #>MSG1
		sta MSGH
		jsr SHWMSG		; "This is bank number #"
		jsr BANKSHOW		; Show bank number
		lda #<MSG3
		sta MSGL
		lda #>MSG3
		sta MSGH
		jsr SHWMSG		; "Switching banks..."
		SWITCH
		lda #<MSG1
		sta MSGL
		lda #>MSG1
		sta MSGH
		jsr SHWMSG		; "This is bank number #"
		jsr BANKSHOW		; Show bank number
		SWITCH
		lda #<MSG4
		sta MSGL
		lda #>MSG4
		sta MSGH
		jsr SHWMSG		; "Done!"
		cli			; Enable interrupts
		rts			; Return to woz monitor

BANKSHOW	lda PORT
		and #(1<<BANKSW)
		bne BANK1		; Is bit high?
		lda #"0"
		bne BANKSHOW1
BANK1		lda #"1"
BANKSHOW1	jsr ECHO
		lda #$0D
		jsr ECHO
		lda #$0A
		jsr ECHO
		rts


MSG1	.asc "This is bank number #",0
MSG2	.asc "Now copying this program to other bank...",$0D,$0A,0
MSG3	.asc "Switching banks...",$0D,$0A,0
MSG4	.asc "Done!",$0D,$0A,0
END