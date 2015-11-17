; Filename	zeropage.inc
; Author	Koen van Vliet	<8by8mail@gmail.com>

; String
str = $02
sstr = str
swp_str = str + 2

; Debug
bk = $06
bk_ACC 	= bk 
bk_INX	= bk + 1
bk_INY	= bk + 2
bk_PCL	= bk + 3
bk_PCH	= bk + 4
bk_PC	= bk_PCL
bk_SP	= bk + 5
bk_STAT	= bk + 6

; RX buffer
rx = $0D
rxcnt = rx
rxp = rx + 1