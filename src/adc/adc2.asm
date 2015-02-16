AD		=	$D840
PRBYTE	=	$E16F
ECHO	=	$E182
*		=	$6000
LOOP	lda AD
		sta AD
		jsr PRBYTE
		lda #$0D
		jsr ECHO
		jmp LOOP