; Filename	main.asm
; Author	Koen van Vliet	<8by8mail@gmail.com>

#include "../cbs.inc"
#include "zeropage.inc"
#define cbaud 1					; Maximum serial transmission rate

* = $0200						; Program loads at $0200
;* = $E000

start:
;=====================================================================
; M A I N   P R O G R A M
;=====================================================================
init:	sei						; Disable interrupts
		ldx #$FF				; Initialize stack
		txs
		cld						; Clear decimal mode

		lda #(STATLED | DISROM)	; Turn on status LED
		sta $00
		ora $01
		sta $01
		lda #(1<<3)				; Disable CIA serial port interrupts

		jsr serial_init			; Initialize the serial port
		
		lda #<bootMsg			; Print a string over serial
		sta sstr
		lda #>bootMsg
		sta sstr + 1
		jsr puts

		cli
		jsr serial_int_en
loop:	;lda rxcnt
		;beq loop
		;dec rxcnt
		;jsr statled
		jmp loop

delay:	ldx #$50		; Initialize delay counter
outer:	ldy #$00		; 256*(7 + 256*(2+3)) = 329472 cycles ~=1.5Hz
inner:	dey
		bne inner
		dex
		bne outer
		rts

#include "serial.asm"

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
.asc "*** 6510 Micro Computer System ***", $0A, $0D
.asc "128K RAM SYSTEM  126976 BYTES FREE", $0A, $0D
.asc "READY to Rock!", $0A, $0D, $00
doneMsg:
.asc "Done executing program!", $0A, $0D, $00
rxMsg:
.asc "Got byte!", $0D, $0A, $00
;end:
;		.dsb ($1000-(end-start)-4),$FF
;		.word init
;		.word isr_rx