## CBS6000 Microcomputer System
The CBS6000 is a 6502-based computer I built back in 2014. Back then I took great interest in retro computing especially Commodore 64 computers. Some of these computers did not work, so they would be repaired or scrapped for parts. I had a spare 6510 CPU (6502 with some extra features), two 6526 CIA's (IO with timers) and assorted logic IC's. Combined with parts I could salvage from the dumpster at the college electronics lab I could make this microcomputer. The computer consists of a CPU board and an I/O board. The CPU board is a self-contained microcomputer and can work without the I/O board attached. 

## System Specifications
A quick overview of the computer specifications.
- **CPU**:	MOS Technology 6510 @ 0.96MHz
- **RAM**:	128KB
- **ROM**:	8KB (contains operating system)
- **Timers**:	4x Timer with interrupt
- **IO**:	16x GPIO, ADC, UART, USART, FSK modem, Line Printer, Seven segment display
- **Power**:	Single 5V supply

## Software
The "operating system" is a customized version of "The Woz" Monitor created by Steve Wozniak for the original Apple 1 computer, which used the 6502 processor. This monitor program allows the user to view and alter the computer's memory and I/O registers. I have added drivers for the CBS6000 built-in peripherals
- Serial input/output
- Loading/saving memory to casette
- Loading memory from serial port
- Seven segment display output
- Line printer

I placed operating system in quotes, because it lacks essential operating system functionality, such as a task scheduler. 

## Hardware
There are 4 parts that make up the computer.
- Main CPU Board
- I/O Board
- Backplane
- Interface Board

The **CPU board** is a self-contained microcomputer containing a processor, memory and some I/O. The IO is provided by a CIA (Complex interface adapter). The system clock is also generated on this board.

The **I/O Board** adds various interfacing options to the computer.
- Two **UARTs** one for the command line interface and the other for the FSK modem. The command line interface runs at 57600 baud and can also be used for binary data transfer.
- **FSK modem** works with an audio signal, which can be sent over telephone lines or can be used to access data on audio casette. It runs at 1200 baud.
- Additional GPIO and Timers provided by a second CIA
- LED **Seven Segment Display** controlled by the second CIA
- 8-bit resolution **Analog to Digital Converter** 

The main board connects to the I/O board via the **Backplane**. It distributes power and data trough the system.

The **Interface Board** contains level shifting and input protection for the I/O on the CPU Board and I/O board signals.

## Pinouts

The backplane connector on the right side of the CPU and I/O board is located on the right side of the computer. The layout is shared between the CPU board and the I/O board. Signal directions are referenced from the CPU board.
```
#       1     2     3     4     5     6    7..14   15..22   23
Label: 5v+  /RES   ph2   R/W  IOEN  /IRQ   D0..7   A0..7   GND
```
- 5V+ - Power +5V
- /RES - System Reset
- ph2 - System Clock 0.9216 MHz output
- R/W - CPU Read Write output
- IOEN - Address Decoder I/O board enable output
- /IRQ - CPU Maskable Interrupt Request input
- Dx - CPU Data bus pin input/output
- Ax - CPU Addres bus pin input/output

The CPU board I/O connector is located on the left side of the board. It provides access to the CIA's GPIO pins, serial port and handshaking lines and power.
```
#       1     2     3     4     5     6    7..14   15   16   17   18..22  23
Label: GND   PA0   SP    CNT   PA1   PA2   PB0..7  PC  FLAG  5V+  PA3..7  P0
```
- GND - Power ground
- PAx - GPIO pin port A input/output
- PBx - GPIO pin port B input/output
- SP - Serial port shift register data input/output
- CNT - Serial port shift register clock pin input/output
- PC - Serial port data ready output
- FLAG - Serial port data ready input
- 5V+ - Power +5V
- P0 - CPU Internal I/O port P0 input/output 


The I/O board I/O connector is located on the left side of the board. It provides access to the FSK modem, UART and ADC signals.
```
#       1     2..18     19     20     21     22     23
Label: GND    n.c.     TXA    RXA    RXD    TXD    ADC
```
- GND - Power ground
- TXA - FSK Modem transmit data output
- RXA - FSK Modem receive data input
- TXD - UART transmit data output
- RXD - UART receive data input
- ADC - AD Converter analog input
- n.c. - Pins reserved for future expansion. Do not connect
	
