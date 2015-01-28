#define DISROM  16
#define STATLED  4
#define BANKSEL  32

DDR = $00
PORT = $01

CIA = $D000
PBDAT = CIA + $1
PBDDR = CIA + $3
TBL = CIA + $6
TBH = CIA + $7
ICR = CIA + $D
CRB = CIA + $F
addr = $02


#define cbaud 1;
#define delay 125

#define CS 1

* = $1000
init:	lda #(DISROM | STATLED)		; Disable the ROM
		sta $00
		ora $01
		sta $01

		lda #$FF					; Set port B to output for r2r dac
		sta PBDDR

		lda #<isr					; Set interrupt vector
		sta $FFFE
		lda #>isr
		sta $FFFF

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
		lda (addr),y				; Load sound data from ram
		sta PBDAT
		sec							; Jump to next byte in ram
		tya
		adc addr
		sta addr
		tya
		adc addr + 1
		sta addr + 1
		cmp #>soundend				; Check if sample is done playing yet
		beq res1
		rti
res1:	lda addr
		cmp #<soundend
		beq res
		rti
res:	lda #<sound					; Loop sample
		sta addr
		lda #>sound
		sta addr + 1
		rti
sound:
.bin	0,0,"dj.bin"
soundend:
