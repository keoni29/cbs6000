#define DISROM  16
#define STATLED  4
#define BANKSEL  32

DDR = $00
PORT = $01

CIA = $D000
TAL = CIA + $4
TAH = CIA + $5
TBL = CIA + $6
TBH = CIA + $7
SDR = CIA + $C
ICR = CIA + $D
CRA = CIA + $E
CRB = CIA + $F

#define cbaud 1;(1000000 / (baud*2))
#define delay 65535

* = $0200

init:	lda #(DISROM | STATLED)		; Disable the ROM
		sta $00
		ora $01
		sta $01

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

		lda #%00010001				; Start timer in continuous mode
		sta CRB
		lda #%10000010				; Enable timer B underflow interrupts
		sta ICR

		ldx #0
		cli							; Enable interrupts
loop:	jmp loop

isr:	lda #STATLED
		eor $01
		sta $01
		lda ICR						; Acknowledge interrupt
		and #((1 << 7) | (1 << 1)) 	; Check if interrupt comes from CIA timer B
		cmp #((1 << 7) | (1 << 1))
		bne endisr
		lda myText,x
		cmp #0
		beq repeat
		inx
		sta SDR
endisr:	rti
repeat:	ldx #0
		rti

myText:
.asc "Hello World", $0D, $0A, $00