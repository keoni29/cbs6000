; Address $0000 - $03FF can be fixed to bank 1
; HIGH to disable this feature
#define RAML	3
; HIGH to disable rom (default LOW)
#define ROMDIS	4
; LOW: Bank 0 selected, HIGH: Bank 1 selected (default LOW)
#define BANKSW	5

; SPI Expansion port
#define SPI_EN 0
#define SPI_DC 2
#define SPI_RST 3

;#define DISROM  16
;#define STATLED  4
;#define BANKSEL  32
;#define RUN 1

; CBS6000 memory map
DDR 	= $00
PORT 	= $01
ACIA	= $D800			; UART
ACIA2	= $D820			; Modem
AD		= $D840			; Analog to Digital Converter
CIA 	= $D000			; I/O lower
CIA2 	= $D860			; I/O upper + 7 segment digits

PRA 	= CIA + $0
PRB 	= CIA + $1
DDRA 	= CIA + $2
DDRB 	= CIA + $3
TAL 	= CIA + $4
TAH 	= CIA + $5
TBL 	= CIA + $6
TBH 	= CIA + $7
SDR 	= CIA + $C
ICR 	= CIA + $D
CRA 	= CIA + $E
CRB 	= CIA + $F
PRA2 	= CIA2 + $0
PRB2 	= CIA2 + $1
DDRA2 	= CIA2 + $2
DDRB2 	= CIA2 + $3
TAL2 	= CIA2 + $4
TAH2 	= CIA2 + $5
TBL2 	= CIA2 + $6
TBH2	= CIA2 + $7
SDR2 	= CIA2 + $C
ICR2 	= CIA2 + $D
CRA2 	= CIA2 + $E
CRB2 	= CIA2 + $F
ACIA_CTRL	= ACIA+0
ACIA_SR		= ACIA+0
ACIA_DAT	= ACIA+1
ACIA2_CTRL	= ACIA2+0
ACIA2_SR	= ACIA2+0
ACIA2_DAT	= ACIA2+1

#define ACDIV 0
#define AWSEL 2
#define ATCTL 5
#define ARXIE 7