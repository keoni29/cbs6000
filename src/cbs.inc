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