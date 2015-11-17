System Specifications
	
CPU	MOS technology 6510 @ 0.96MHz
RAM	128KB
ROM	8KB (contains bootloader)
PIO	Complex interface adapter (CIA) : Has 16 I/O pins, a serial port and two timers
IO (other)	ADC, UART, FSK modem, Line Printer, Seven segment display, Casette tape
Power	Single 5V supply
What is the cbs6000?

The CBS6000 is an 6510-based system with lots of interface options including: ADC, UART, FSK modem, Line Printer, Seven segment display.
The system contains 128KB of ram as well as an 8kb eeprom which holds the firmware

The operating system is a customized version of the woz monitor. Added features are:
ACIA input/output, casette load/save, serial load and a seven segment display driver.
Hardware overview

There are 4 parts that make up the computer. The first one being the main board. This board contains the cpu, ram, rom and address decoder. It also has the first CIA (Complex interface adapter) and a system clock generator which feeds a 1MHz clock signal to CIA#1 and CPU.

The second part is the I/O board which contains the rest of the peripherals:
2x ACIA, ADC, CIA#2, LED display, FSK modem and additional decoders for selecing the various devices.

The main board connects to the I/O board via a backboard connector. The I/O board and the main board have an I/O connector on the left side which connects to another backboard. This backboard contains additional level shifting and input protection.
Both the I/O and the main board receive power from the backboard.

CIA#1 has its two parallel ports, serial port and handshaking lines broken out to a connector on the left side of the computer.
I/O board
CIA#2 is used to drive the display and the unused pins are broken out fo a connector on the left side of the computer.

ACIA#1 is used for communication between the computer and the operator. The data transfer rate can go up to 57600 baud.

ACIA#2 is wired up to the FSK modem. This ACIA's clock line is driven by the clock output of the modem. The modem can generate baudrates up to 1200 baud. Because the fsk frequency is well within the audible range the signal can be recorded on casette tape and later played back to the input of the modem to recover the original data. The computer can save 120 characters to the casette tape per second. Therefore it is recommended to use ACIA#1 and a serial loader program for large programs, since ACIA#1 can transfer up to 5760 characters per second.
Pinouts

System bus connector on right backboard:
#       1     2     3     4     5     6    7..14   15..22   23
Label: 5v+   RES   ph2   RW   IOEN   IRQ   D0..7   A0..7   GND

CIA#1 I/O connector:
#       1     2     3     4     5     6    7..14   15   16   17   18..22  23
Label: GND   PA0   SP    CNT   PA1   PA2   PB0..7  PC  FLAG  5V+  PA3..7  P0

I/O board connector:
#       1     2..18     19     20     21     22     23
Label: GND    n.c.     TXA    RXA    RXD    TXD    ADC

TXA and RXA are from the modem interface
TXD and RXD are digital UART
	
