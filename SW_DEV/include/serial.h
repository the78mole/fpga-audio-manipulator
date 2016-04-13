#if !defined __SERIAL_H
#define __SERIAL_H

#define F_OSC			8000
#define SERIAL_PRESCALE		16

#define SERIAL_BAUD_RATE	19200
#define SERIAL_PARITIY		0
#define SERIAL_STOP_BITS	1

#define SERIAL_UBRR_VALUE	25	
#define SERIAL_ECHO_ON		1
#define SERIAL_ECHO_OFF		0

#define WAIT8	asm volatile ("nop \n\t nop \n\t nop \n\t nop \n\t nop \n\t nop \n\t nop \n\t nop");

void serial_init(void);
int serial_putc(char);
void serial_set_echo(uint8_t);
int serial_get(void);

#endif
