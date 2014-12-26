#include "../cbs.inc"
#define cbaud 1;				; Maximum serial transmission rate
sstr = $02						; String pointer

* = $0200						; Program loads at $0200
;=====================================================================
; M A I N   P R O G R A M
;=====================================================================
init:	lda #(DISROM | STATLED)	; Disable the ROM & turn on status LED
		sta $00
		ora $01
		sta $01
		jsr serial_init			; Initialize the serial port
		lda #<bootMsg			; Print a string over serial
		sta sstr
		lda #>bootMsg
		sta sstr + 1
		jsr puts
loop:	jmp loop				; Loop forever

;=====================================================================
; S E R I A L  O U T P U T
;=====================================================================
serial_init:
		lda #<cbaud				; Set baudrate
		sta TAL
		lda #>cbaud
		sta TAH
		lda #%01010001			; Start timer in continuous mode
		sta CRA					; Serial port = output
		rts

puts:	tya
		pha
puts_nextch:
		ldy #0
		lda (sstr),y			; Load character from ram
		cmp #0
		beq puts_strterm		; Terminate if zero
		sta SDR
		sec						; Advance to next character
		tya
		adc sstr
		sta sstr
		tya
		adc sstr + 1
		sta sstr + 1
		jmp puts_nextch
puts_strterm:
		pla
		tay
		rts
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