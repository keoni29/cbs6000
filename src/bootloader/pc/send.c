/* 
 * Parallel port rom reader. Compile with `gcc -O2 -o send send.c',
 * and run as root with `./send filename'.
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
#define m_ACK 7

void ctlbit(int enable, int bit){
	char rctl = inb(CTL);
	if (enable) {outb(rctl | (1 << bit), CTL);} 
	else {outb(rctl & ~(1 << bit), CTL);}
}

int main(int argc, char *argv[]) {
	char dat;
	clock_t begin = clock();
	double time_spent;
	FILE *src;
	int i, b, filesize;
	
	/* Process user input. */
	// printf("CBS6000 Data Transfer Tool (c)2014 Koen van Vliet.\nSend a file via the parallel port to the CBS6000 computer.\nStart address in ram is 0x0200. File must be raw binary.\n"
	if (argc < 2){
		printf("Usage: %s filename\n", argv[0]);
		return 0;
	}
	
	/* Open source file and determine filesize. */
	src = fopen(argv[1], "rb+");
	if (src == NULL){printf("Error opening file for reading.\n"); return 0;}
	fseek(src, 0, SEEK_END);
	filesize = ftell(src);
	printf("File Size = %d\n",filesize);
	fseek(src, 0, SEEK_SET);
	
	/* Gain access to LPT & initialize LPT */
	if (ioperm(BASEPORT, 3, 1)) {perror("ioperm"); return 0;}
	ctlbit(0, m_SCK);
	ctlbit(0, m_RUN);
	
	//printf("Hit any key to start file transfer...\n");
	//getc(stdin);
	//fflush(stdin);

	/* Shift out file. */
	for (i = 0; i <= filesize; i++) {
		dat = fgetc(src);						// Get byte from file
		for(b = 0; b < 8; b++) {
			outb((char)((dat & 0x80) >> 7), DATA);		// Put bit on D0
			dat <<= 1;							// Next bit
			ctlbit(1, m_SCK);					// Pulse Latch Enable line
			usleep(10);
			ctlbit(0, m_SCK);
			usleep(10);
		}
		usleep(10);
		if ((inb(STAT) & (1 << m_ACK)) == 1){
			printf("Did not get ACKnowledge. Device busy?\r");
			break;
		}
		if (i == filesize/40)
		printf("[%d]\r", i);
	}

	/* Run the program. */
	printf("File transfer complete!\n");
	usleep(100);
	ctlbit(1, m_RUN);
	usleep(100);
	ctlbit(0, m_RUN);
	printf("Now running program...\n");

	/* Show elapsed time and the amount of bytes that were sent. */
	time_spent = (double)(clock() - begin) / CLOCKS_PER_SEC;
	printf("Elapsed time: %f seconds.\n", time_spent);
	if (ioperm(BASEPORT, 3, 0)) {perror("ioperm"); return 0;}
	if (fclose(src) == EOF){printf("Error closing file.\n"); return 0;}
	printf("Sent %d bytes.\n", filesize);
	return 0;
}
