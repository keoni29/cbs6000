; Assemble using xa printtest.asm
#include "../cbs.inc"

MSGL		= $2C
MSGH		= $2D

ECHO		= $E182
*		=($800-4)
	.word	START		; Loader parameters
	.word	END

START		sei		; Disable interrupts
		lda #$90	; Set strobe high
		sta PRB
		lda #$FF	; Set data pins to all outputs
		sta DDRB
		lda #<MSG1
		sta MSGL
		lda #>MSG1
		sta MSGH
		jsr PRINTMSG	; Print the message
		cli		; Enable interrupts
		rts		; Return to woz monitor
PRINTMSG	ldy #$00
BUSY		lda #$02
		and PRA		; Check if busy
		bne BUSY	; Yes, wait for ready
		lda (MSGL),Y	; Get character from string
		beq DONE	; 0? Yes, we're done
		ora #$80	; Set strobe high
		sta PRB		; Put data on I/O port
		nop
		;nop
		;nop
		and #$7F	; Set strobe low
		sta PRB		; Data is latched now
		nop
		;nop
		;nop
		ora #$80	; Set strobe high
		sta PRB		; Put data on I/O port
		nop
		;nop
		;nop
		clc
		inc MSGL	; Advance to next character
		bne BUSY
		inc MSGH
		bne BUSY
DONE		rts		; Done printing characters

MSG1	.asc $02		; This is beautiful!
	.asc "              .,-:;/;;:=,",$0A,$0D
	.asc "          . :H@@@MM@M#H/.,+%;,",$0A,$0D
	.asc "       ,/X+ +M@@M@MM%=,-%HMMM@X/,",$0A,$0D
	.asc "     -+@MM; $M@@MH+-,;XMMMM@MMMM@+-",$0A,$0D
	.asc "    ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/.",$0A,$0D
	.asc "  ,%MM@@MH ,@%=             .---=-=:=,.",$0A,$0D
	.asc "  =@#@@@MX.,                -%HX$$%%%:;",$0A,$0D
	.asc " =-./@M@M$                   .;@MMMM@MM:",$0A,$0D
	.asc " X@/ -$MM/                    . +MM@@@M$",$0A,$0D
	.asc ",@M@H: :@:                    . =X#@@@@-",$0A,$0D
	.asc ",@@@MMX, .                    /H- ;@M@M=",$0A,$0D
	.asc ".H@@@@M@+,                    %MM+..%#$.",$0A,$0D
	.asc " /MMMM@MMH/.                  XM@MH; =;",$0A,$0D
	.asc "  /%+%$XHH@$=              , .H@@@@MX,",$0A,$0D
	.asc "   .=--------.           -%H.,@@@@@MX,",$0A,$0D
	.asc "   .%MM@@@HHHXX$$$%+- .:$MMX =M@@MM%.",$0A,$0D
	.asc "     =XMMM@MM@MM#H;,-+HMM@M+ /MMMX=",$0A,$0D
	.asc "       =%@M@M#@$-.=$@MM@@@M; %M%=",$0A,$0D
	.asc "         ,:+$+-,/H#MMMMMMM@= =,",$0A,$0D
	.asc "               =++%%%%+/:-.",$0A,$0D
	.asc "This was a triumph.",$0A,$0D
	.asc "I'm making a note here: HUGE SUCCESS.",$0A,$0D
	.asc "It's hard to overstate my satisfaction.",$0A,$0D
	.asc "",$0A,$0D
	.asc "Aperture Science. ... We do what we must because we can.",$0A,$0D
	.asc "For the good of all of us",$0A,$0D
	.asc "Except the ones who are dead.",$0A,$0D
	.asc "",$0A,$0D
	.asc "But there's no sense crying over every mistake.",$0A,$0D
	.asc "You just keep on trying till you run out of cake.",$0A,$0D
	.asc "And the science gets done and you make a neat gun.",$0A,$0D
	.asc "For the people who are still alive.",$0A,$0D
	.asc "",$0A,$0D
	.asc "I'm not even angry.",$0A,$0D
	.asc "I'm being so sincere right now.",$0A,$0D
	.asc "Even though you broke my heart and killed me.",$0A,$0D
	.asc "And tore me to pieces.",$0A,$0D
	.asc "And threw every piece into a fire.",$0A,$0D
	.asc "As they burned it hurt because",$0A,$0D
	.asc "I was so happy for you!",$0A,$0D
	.asc "Now these points of data make a beautiful line.",$0A,$0D
	.asc "And we're out of beta, we're releasing on time.",$0A,$0D
	.asc "So I'm GLaD I got burned.",$0A,$0D
	.asc "Think of all the things we learned",$0A,$0D
	.asc "For the people who are still alive.",$0A,$0D
	.asc "Go ahead and leave me.",$0A,$0D
	.asc "I think I prefer to stay inside.",$0A,$0D
	.asc "Maybe you'll find someone else to help you.",$0A,$0D
	.asc "Maybe Black Mesa...",$0A,$0D
	.asc "THAT WAS A JOKE. Haha. FAT CHANCE.",$0A,$0D
	.asc "Anyway, this cake is great.",$0A,$0D
	.asc "It's so delicious and moist.",$0A,$0D
	.asc "",$0A,$0D
	.asc "Look at me still talking when there's science to do.",$0A,$0D
	.asc "When I look out there it makes me GLaD I'm not you.",$0A,$0D
	.asc "I've experiments to run there is research to be done",$0A,$0D
	.asc "On the people who are still alive",$0A,$0D
	.asc "And believe me I am still alive.",$0A,$0D
	.asc "I'm doing science and I'm still alive.",$0A,$0D
	.asc "I feel FANTASTIC and I'm still alive.",$0A,$0D
	.asc "While you're dying I'll be still alive.",$0A,$0D
	.asc "And when you're dead I will be still alive.",$0A,$0D
	.asc "",$0A,$0D
	.asc "Still alive ... Still alive",$0C,$04,0
		
END	.byte 0