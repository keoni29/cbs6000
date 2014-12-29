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

#define delay 65535

*=$1000

init:	lda #$FF
		sta PBDDR		// Set port to all Outputs
		sta $00
		lda #(DISROM | STATLED)	// Disable the ROM
		sta $00
		ora $01
		sta $01

		lda #<isr		// Set interrupt vector
		sta $FFFE
		lda #>isr
		sta $FFFF

		lda #<delay		// Set timer delay
		sta TAL
		lda #>delay
		sta TAH
		lda #%10000001	// Enable timer A underflow interrupts
		sta ICR
		lda #%00010001	// Start timer in continuous mode
		sta CRA
		ldy #0
		cli				// Enable interrupts
loop:	jmp loop

isr:	ldx ICR			// Acknowledge interrupt
		iny
		sty PBDAT		// Blink LED's
		lda #STATLED
		eor $01
		sta $01
		rti