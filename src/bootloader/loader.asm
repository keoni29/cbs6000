// Simple loader for loading data via SPI
// Author:		Koen van Vliet <8by8mail@gmail.com>
// Date:		7 nov 2014
// Notes:
//	- Use kickassembler to assemble
//	- Included PC program for sending data to the CBS (linux-only)
//	- Pin 0 is reserved for data-in (because of optimizations)
.const din 		= 1
.const sck 		= 2 
.const dout	 	= 4
.const run		= 8
.const buff 	= $02
.const addr 	= $03
.const base		= $0200
.const ddr 		= $00
.const port 	= $01

// Pseudocode:
// Repeat 8 times
//   Wait for SCK to go LOW / Execute program if RUN is LOW
//   DOUT = 0
//   Wait for SCK to go HIGH again
//   Read bit from DIN and store to buffer
// End
// Move byte from buffer to address
// Increment address
// DOUT = 1
// Otherwise: receive another byte
.pc = $e000
reset:
		ldx #$FF
		txs
		sei
		cld
		ldy #0
		lda #dout
		sta ddr
		lda #0			// Clear DOUT
		sta port
		lda #<base
		sta addr
		lda #>base
		sta addr + 1
rbyte:	ldx #8
rbit:	lda #run		// Execute program if RUN is low
		and port
		beq exec
		lda #sck		// Wait for SCK to go LOW
		and port
		bne rbit
		lda #0			// Clear DOUT
		sta port
waithi:	lda #sck		// Wait for SCK to go HIGH again
		and port
		beq waithi
		dex				// Advance to next bit
		clc
		rol buff
		lda #1
		and port		// Read bit from DIN
		ora buff
		sta buff		// Store bit
		cpx #0
		bne rbit
		lda buff
		sta (addr),y	// Move byte to address
		sec
		lda #0			// Increment address
		adc addr
		sta addr
		lda #0
		adc addr + 1
		sta addr + 1 
		lda #dout		// Set DOUT
		sta port
		jmp rbyte
exec:
		jsr base		// Execute loaded program
		jmp reset