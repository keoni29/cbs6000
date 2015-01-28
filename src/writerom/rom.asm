CIA = $D000
PADAT = CIA + $0
PBDAT = CIA + $1
PADDR = CIA + $2
PBDDR = CIA + $3
ROM = $E000

#define ROMOE 1
* = $0200

init:	sei
		lda #$FF						; Set all pins of PORTB to output
		sta PBDDR
		lda #(ROMOE)				; Disable eeprom write-protection
		sta PADAT
		sta PADDR
		lda #$57						; Change a byte in the eeprom
		sta ROM + 1
		tsx							; When this program runs for the second time this should
		stx PBDAT					; Result in a fancy bit pattern
		lda #0						; Enable eeprom write-protection again
		sta PADDR
		rts