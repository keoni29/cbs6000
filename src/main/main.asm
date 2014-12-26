; Filename	main.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

#include "../cbs.inc"
#include "zeropage.inc"
#define cbaud 1;				; Maximum serial transmission rate

* = $0200						; Program loads at $0200
;=====================================================================
; M A I N   P R O G R A M
;=====================================================================
init:	lda #(DISROM | STATLED)	; Disable the ROM & turn on status LED
		sta $00
		ora $01
		sta $01
		jsr serial_init			; Initialize the serial port
		jsr dbg_init			; Initialize debug features
		lda #<bootMsg			; Print a string over serial
		sta sstr
		lda #>bootMsg
		sta sstr + 1
		jsr puts
		lda #<doneMsg			; Print a string over serial
		sta sstr
		lda #>doneMsg
		sta sstr + 1
		jsr puts
loop:	jmp loop				; Loop forever

#include "serial.asm"
#include "string.asm"
#include "debug.asm"

;=====================================================================
; L E D   L I G H T   C O N T R O L
;=====================================================================
statled:lda #STATLED			; Toggle status LED
		eor $01
		sta $01
		rts
;=====================================================================
; D A T A
;=====================================================================
bootMsg:
.asc " *** 6510 Micro Computer System *** ", $0D
.asc " 128K RAM SYSTEM  126976 BYTES FREE ", $0D
.asc " READY to Rock! ", $0D, $00
doneMsg:
.asc "Done executing program!", $0D, $00
b2hex_lut:
.asc "0123456789ABCDEF"