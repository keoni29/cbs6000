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

		brk						; Break point: dump registers
		jsr statled
		lda #$A7				; Print hexadecimal number $A7	
		jsr b2hex
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
.asc " *** 6510 Micro Computer System *** ", $0D, $0A
.asc " 128K RAM SYSTEM  126976 BYTES FREE ", $0D, $0A
.asc " READY to Rock! ", $0D, $0A, $00
.asc $0,$0,$0D,$0A