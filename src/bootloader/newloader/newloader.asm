#define DISROM  16
#define STATLED  4
#define BANKSW  32
#define RUN 8

DDR = $00
PORT = $01

CIA = $D000
PBDAT = CIA + $1
PBDDR = CIA + $3
TAL = CIA + $4
TAH = CIA + $5
TBL = CIA + $6
TBH = CIA + $7
SDR = CIA + $C
ICR = CIA + $D
CRA = CIA + $E
CRB = CIA + $F
addr = $02

#define startaddr $1000
#define LED 1

* = $0200

init:	lda #(DISROM | STATLED )	; Disable the ROM
		sta $00
		ora $01
		sta $01

		lda #<isr					; Set interrupt vector
		sta $FFFE
		lda #>isr
		sta $FFFF

		lda #<startaddr				; Software will be loaded at this address
		sta addr
		lda #>startaddr
		sta addr + 1

		lda #%10001000				; Enable serial interrupts
		sta ICR

		ldy #0
waitrun:
		lda PORT
		and #RUN
		beq waitrun
		cli							; Enable interrupts
loop:	lda PORT
		and #RUN
		bne loop
		sei							; Disable interrupts
		jmp startaddr

isr:	pha
		lda #STATLED
		eor PORT
		sta PORT
		lda ICR						; Acknowledge interrupt
		lda SDR						; Get incoming byte
		ldy #0
		sta (addr),y
		sec							; Go to next memory address
		tya
		adc addr
		sta addr
		tya
		adc addr + 1
		sta addr + 1
		pla
		rti
