/*
 * --------------------------------------------
 * DIY-MCP
 * Do-it-yourself Mikrocontroller Praktikum
 * 
 * Support: Ringpuffer
 *
 */

#include <stdlib.h>
#include "ringbuffer.h"


// Leere Idle Funktion
void rb_no_idle(void) { }

// Leere Zeit Funktion
uint32_t rb_no_get_time(void) { return 0; }



void rb_init(void *buffer, uint8_t buf_len, void (*idle_func)(void),
	     uint32_t (*get_time_func)(void)) {

  // Die Kontrollstruktur liegt gleich am Anfang
  ringbuffer_t *rb = (ringbuffer_t *) buffer;

  // Ringbuffer initialisieren
  rb->size = buf_len - sizeof(ringbuffer_t);
  rb->free = rb->size;
  rb->write_idx = 0;
  rb->read_idx = 0;

  // Idle Funktion belegen
  if (idle_func != NULL) rb->idle_func = idle_func;
  else rb->idle_func = rb_no_idle;
  
  // Zeit Funktion belegen
  if (get_time_func != NULL) rb->get_time_func = get_time_func;
  else rb->get_time_func = rb_no_get_time;
}



int rb_put(void *buffer, uint8_t b, uint32_t timeout) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;

  // Warten bis Platz verfügbar
  if (rb_put_wait(buffer, timeout)!=0) return -1;

  // In den Buffer schreiben
  rb->buffer[rb->write_idx] = b;

  // Zeiger anpassen
  if (rb->write_idx == (rb->size-1)) rb->write_idx = 0;
  else rb->write_idx++;

  // Platz wegnehmen
  rb->free--;
  return 0;
}



int rb_get(void *buffer, uint8_t *b, uint32_t timeout) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;

  // Warten bis Zeichen verfügbar
  if (rb_get_wait(buffer, timeout)!=0) return -1;

  // Es liegt mindestens ein Zeichen vor. Dieses jetzt
  // auslesen.
  *b = rb->buffer[rb->read_idx] & 0xff;

  // Lesepointer anpassen
  if (rb->read_idx==(rb->size-1)) rb->read_idx = 0;
  else rb->read_idx++;

  // Wieder ein Zeichen mehr Platz
  rb->free++;

  return 0;
}



uint8_t rb_put_avail(void *buffer) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;
  return rb->free;
}



uint8_t rb_get_avail(void *buffer) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;
  return rb->size - rb->free;
}



int rb_get_wait(void *buffer, uint32_t timeout) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;

  // Warten bis ein Zeichen vorliegt
  uint32_t start_time = (*rb->get_time_func)();
  while (rb_get_avail(buffer)==0) {
    if (timeout!=0)
      if (((*rb->get_time_func)()-start_time)>=timeout) return -1;
    (*rb->idle_func)();
  }
  return 0;
}



int rb_put_wait(void *buffer, uint32_t timeout) {
  ringbuffer_t *rb = (ringbuffer_t *) buffer;

  // Warten bis Platz im Buffer ist oder Timeout erreicht
  uint32_t start_time = (*rb->get_time_func)();
  while (rb_put_avail(buffer)==0) {
    if (timeout!=0)
      if (((*rb->get_time_func)()-start_time)>=timeout) return -1;
    (*rb->idle_func)();
  }

  return 0;
}
