#define DISROM  16
#define STATLED  4
#define BANKSEL  32
#define RUN 1

DDR = $00
PORT = $01

CIA = $D000
PRA = CIA + $0
PRB = CIA + $1
DDRA = CIA + $2
DDRB = CIA + $3
TAL = CIA + $4
TAH = CIA + $5
TBL = CIA + $6
TBH = CIA + $7
SDR = CIA + $C
ICR = CIA + $D
CRA = CIA + $E
CRB = CIA + $F

ACIA = $D800
ACIA_CR = ACIA + $0
ACIA_SR = ACIA + $0
ACIA_DR = ACIA + $1
#define ACDIV 0
#define AWSEL 2
#define ATCTL 5
#define ARXIE 7