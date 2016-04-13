#include <avr/interrupt.h>
#include <inttypes.h>
//#include "reg_access.h"
#include "timer.h"

volatile uint32_t counter[3];
uint8_t timer_init_done = 0;

void timer2_init(void) {
  counter[2] = 0;
  // CTC-Mode(WG=10), Prescale 8(CS=010)
  TCCR2 = (1<<WGM21)|(0<<WGM20)|(0<<CS22)|(1<<CS21)|(0<<CS20);
  TIFR	|= (1<<OCF2)|(1<<TOV2);
  TIMSK |= (1<<OCIE2)|(1<<TOIE2);
//  ref. DS p.152 ==> 8000 kHz/(8*8 kHz)-1 = 249;
  OCR2 = FREQ_OSC_KHZ/(PRESCALE_TIMER2*FREQ_TIMER_KHZ)-1;
//  OCR2 = 249;
  sei();
  timer_init_done=1;
}

uint32_t timer2_get(void) {
  // returns the ms
  return (counter[2]/8);
}

uint32_t timer2_uget(void) {
  // 0.125 ms
  return counter[2];
}

void timer2_uwait(uint32_t udelay) {
  uint32_t starttime, endtime;
  starttime = timer2_uget();
  endtime = starttime + udelay;
  while(timer2_uget() < endtime);
}

void timer2_wait(uint32_t delay) {
  uint32_t starttime, endtime;
  starttime = timer2_get();
  endtime = starttime + delay;
  while(timer2_get() < endtime);
}

/* void timer_init(uint8_t timer,  */
/* 		uint8_t clk_source,  */
/* 		uint8_t prescale,  */
/* 		uint8_t mode, */
/* 		uint8_t int_en) { */
/*   switch (timer)  */
/*     { */
/*     case TIMER0: */
/*       writereg(TIMER0_CLK_PRESCALE_REG, TIMER_CLK_PRESCALE_MASK, prescale); */
/*       writereg(TIMER0_MODE_REG, 0xFF, mode); */
/*       writereg(TIMER_INT_REG, TIMER0_INT_MASK, int_en); */
      
/*       break; */
/*       //    case TIMER1: */
/*       //      break; */
/*     case TIMER2: */
/*       writereg(TIMER2_CLK_SRC_REG, TIMER_CLK_SRC_MASK, clk_source); */
/*       writereg(TIMER2_CLK_PRESCALE_REG, TIMER_CLK_PRESCALE_MASK, prescale); */
/*       writereg(TIMER2_MODE_REG, 0xFF, mode); */
/*       writereg(TIMER_INT_REG, TIMER2_INT_MASK, int_en); */

/*       break; */
/*     } */

/*   //  TCCR0 = (1<<CS01); */
/*   //  TIMSK |= 1<<TOIE0; */
/*   sei(); */
/* } */

/* uint32_t timer_get(uint8_t timer){ */
/*   return counter[timer]; */
/* } */

/* void timer_wait(uint8_t timer, uint32_t waittime){ */
/*   uint32_t starttime = timer_get(timer); */
/*   uint32_t endtime = starttime + waittime; */
/*   while(timer_get(timer) < endtime); */
/* } */

SIGNAL(SIG_OVERFLOW0){
  counter[0]++;
}

SIGNAL(SIG_OVERFLOW1){
  counter[1]++;
}

SIGNAL(SIG_OUTPUT_COMPARE2){
  counter[2]++;
}
