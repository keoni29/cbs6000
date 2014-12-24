#define DISROM  16
#define STATLED  4
#define BANKSEL  32

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

#define cbaud 1
#define delay 225

#define CS 1

* = $0200
init:	lda #(DISROM | STATLED)		; Disable the ROM
		sta $00
		ora $01
		sta $01

		lda #CS						; Chip select for DAC
		sta PBDAT
		sta PBDDR

		lda #<isr					; Set interrupt vector
		sta $FFFE
		lda #>isr
		sta $FFFF

		lda #<cbaud
		sta TAL
		lda #>cbaud
		sta TAH
		lda #%01010001				; Start timer in continuous mode, Serial port = output
		sta CRA

		lda #<delay					; Set timer B delay
		sta TBL
		lda #>delay
		sta TBH

		lda #<sound
		sta addr
		lda #>sound
		sta addr + 1

		lda #%00010001				; Start timer in continuous mode
		sta CRB
		lda #%10000010				; Enable timer B interrupts
		sta ICR
		ldx #0
		ldy #0
		cli							; Enable interrupts
loop:	jmp loop

isr:	lda ICR						; Acknowledge interrupt
		lda #CS
		sta PBDAT
		lda #0
		sta PBDAT
		lda (addr),y
		pha
		clc:ror:ror:ror:ror
		and #$0F
		ora #%01110000
		sta SDR
		pla
		rol:rol:rol:rol
		sta SDR
		sec
		tya
		adc addr
		sta addr
		tya
		adc addr + 1
		sta addr + 1
		cmp #>(sound+51516)
		beq res1
		rti
res1:	lda addr
		cmp #<(sound+51516)
		beq res
		rti
res:	lda #<sound
		sta addr
		lda #>sound
		sta addr + 1
		rti
sound: