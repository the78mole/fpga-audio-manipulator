#if !defined __TIMER_H
#define __TIMER_H

#define FREQ_OSC_KHZ			8000
#define PRESCALE_TIMER2			8
#define FREQ_TIMER_KHZ			8

void timer2_init(void);
uint32_t timer2_uget(void);
uint32_t timer2_get(void);

// Waits for ~30.51 us
void timer2_uwait(uint32_t udelay);

void timer2_wait(uint32_t delay);

/* void timer_init(uint8_t,uint8_t,uint8_t,uint8_t,uint8_t); */
/* uint32_t timer_get(uint8_t); */
/* void timer_wait(uint8_t,uint32_t); */

#endif
