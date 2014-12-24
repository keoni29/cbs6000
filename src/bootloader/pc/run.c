/* 
 * Parallel port rom reader. Compile with `gcc -O2 -o send send.c',
 * and run as root with `./send [addr_from addr_to]'.
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/io.h>
#include <time.h>

#define BASEPORT 0x378 /* lp1 */
#define DATA BASEPORT
#define STAT BASEPORT + 1
#define CTL BASEPORT + 2
#define m_SCK 0
#define m_RUN 1

void ctlbit(int enable, int bit){
	char rctl = inb(CTL);
	if (enable) {outb(rctl | (1 << bit), CTL);} 
	else {outb(rctl & ~(1 << bit), CTL);}
}

int main() {
	/* Gain access to LPT & initialize LPT */
	if (ioperm(BASEPORT, 3, 1)) {perror("ioperm"); return 0;}
	ctlbit(0, m_SCK);
	usleep(100);
	ctlbit(1, m_RUN);
	usleep(100);
	ctlbit(0, m_RUN);
	printf("Now running program...\n");

	if (ioperm(BASEPORT, 3, 0)) {perror("ioperm"); return 0;}
	return 0;
}
