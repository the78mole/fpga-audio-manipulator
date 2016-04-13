#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <inttypes.h>
#include "serial.h"
#include "timer.h"
#include "ringbuffer.h"

volatile uint8_t serial_local_echo=0;
uint8_t serial_rx_ringbuffer[RB_BUFSIZE(127)];
//uint8_t serial_tx_ringbuffer[RB_BUFSIZE(127)];

void serial_init(void){
  // TxD: PD1
  // RxD: PD0
  DDRD |= 1<<PD3; // TxD as Output
  PORTD &= ~(1<<PD3);
  DDRD &= ~(1<PD2); // RxD as Input
  PORTD |= 1<<PD2; // Pullup for PD2;
  DDRE |= 7<<PE2;
  // PE2: MAX3221_nEN
  // PE3: MAX3221_nFORCEOFF
  // PE4: MAX3221_FORCEON
  PORTE = (PORTE & ~(7<<PE2))|(0<<PE2)|(1<<PE3)|(1<<PE4);

  // Setting baud rate to this defined in h-file
  UBRR1H = (uint8_t)(SERIAL_UBRR_VALUE>>8);
  UBRR1L = (uint8_t)(SERIAL_UBRR_VALUE);
  
  UCSR1A &= ~(1<<U2X);
//  UCSR1B = (1<<RXCIE1)|(1<<UDRIE1)|(1<<RXEN1)|(1<<TXEN1);
  UCSR1B = (1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1);
  
  rb_init(serial_rx_ringbuffer, RB_BUFSIZE(127), NULL, timer2_get);
//  rb_init(serial_tx_ringbuffer, RB_BUFSIZE(127), NULL, timer2_get);
}

int serial_putc(char c) {
  switch(c)
    {
    case '\r':
      c='\n';
      break;
    case '\n':
      c='\r';
      break;
    }
 
//  rb_put(serial_tx_ringbuffer, c, 100);
  while(!(UCSR1A & 1<<UDRE1));
  UDR1 = c;
  //UCSR1B |= (1<<UDRIE1);

  return 0;
}

void serial_set_echo(uint8_t on_off)
{
  serial_local_echo=(on_off ? 1 : 0);
}

int serial_get(void) {
  uint8_t data;
  if (rb_get(serial_rx_ringbuffer, &data, 500)==0)
  {
/*    switch (data) {
      case '\r':
        data='\n';
        break;
      case '\n':
        data='\r';
        break;
      }*/
      if (data=='\r') return '\n';
      else return data;
  } else {
      return -1;
  }
}

SIGNAL(SIG_UART1_RECV) {
  uint8_t data;
  data=UDR1;
  
  if(serial_local_echo != 0) serial_putc(data);

  if (rb_put_avail(serial_rx_ringbuffer)>0) 
    rb_put(serial_rx_ringbuffer, data, 0);
}

/*
SIGNAL(SIG_UART1_DATA) {
  uint8_t data;
  if(rb_get_avail(serial_tx_ringbuffer)>0) {
    rb_get(serial_tx_ringbuffer, &data, 0);
    UDR1=data;
  } else {
    UCSR1B &= ~(1<<UDRIE1);
  }
  if(PIND & (1<<PD7)) PORTD &= ~(1<<PD7);
    else PORTD |= 1<<PD7;
}
*/
  
