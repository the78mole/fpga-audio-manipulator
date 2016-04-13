/*
 * --------------------------------------------
 * Praktikum: Eingebettete Mikrocontroller-Systeme
 * (PEMSY)
 *
 * Ringpuffer
 *
 */

#if !defined __RINGBUFFER_H
#define __RINGBUFFER_H

#include <inttypes.h>

// Verwaltungsstruktur f�r den Puffer
// (Wird nur intern genutzt)
typedef struct {
  uint8_t size;   // Gr��e des Buffers
  uint8_t free;   // Anzahl freier Bytes
  uint8_t write_idx; // Schreib Index (n�chste zu schreibende Position)
  uint8_t read_idx;  // Lese Index (n�chste zu lesende Position)

  void (*idle_func)(void);
  uint32_t (*get_time_func)(void);

  uint8_t buffer[]; // Anschliessender Buffer
} ringbuffer_t;



// Macro um die Buffergr��e f�r vorgegebene Queuel�nge zu bestimmen
#define RB_BUFSIZE(queue_len) (sizeof(ringbuffer_t)+(queue_len))



// Initialisiert den Ringpuffer in dem Speicher, der mit buffer 
// �bergeben wird. buf_len enth�lt die Gesamtl�nge des Puffers.
// idle_func wird aufgerufen wenn aus dem Puffer
// gelesen werden soll, aber gerade keine Daten vorhanden sind oder
// aber wenn in den Puffer geschrieben werden soll, dieser aber
// schon voll ist.
// Die Funktion get_time_func wird vom Ringpuffer aufgerufen wenn
// Wartezeiten berechnet werden sollen. Die Zeit sollte in Millisekunden
// zur�ckgegeben werden.
void rb_init(void *buffer, uint8_t buf_len, void (*idle_func)(void),
	     uint32_t (*get_time_func)(void));


  
// Speichert ein Zeichen (b) in dem Puffer. Ist der Puffer voll, wird
// gewartet bis wieder ein Zeichen frei wird oder der Timeout abgelaufen
// ist.
// Ein Timeoutwert von 0 deaktiviert die Zeit�berwachung.
// R�ckgabewert:
//    0  Alles ok
//    -1 Zeit�berschreitung
int rb_put(void *buffer, uint8_t b, uint32_t timeout);



// Liest ein Zeichen aus dem Puffer (nach *b). Ist der Puffer leer, wird 
// gewartet bis der Puffer mindestens ein Zeichen enth�lt oder der
// Timeout abgelaufen ist.
// Ein Timeout von 0 deaktiviert die Zeit�berwachung.
// R�ckgabewert:
//    0  Alles ok
//   -1  Zeit�berschreitung
int rb_get(void *buffer, uint8_t *b, uint32_t timeout);



// Wartet solange bis ein Zeichen in den Puffer geschrieben werden
// kann ohne zu blockieren oder aber der Timeout erreicht wird.
// R�ckgabewert:
//    0  Alles ok
//   -1  Zeit�berschreitung
int rb_put_wait(void *buffer, uint32_t timeout);



// Wartet solange bis ein Zeichen aus dem Puffer gelesen werden
// kann ohne zu blockieren oder aber der Timeout erreicht wird.
// R�ckgabewert:
//    0  Alles ok
//   -1  Zeit�berschreitung
int rb_get_wait(void *buffer, uint32_t timeout);



// Liefert die Anzahl von Zeichen, die in den Puffer geschrieben
// werden k�nnen bis er voll ist und daher blockieren w�rde.
uint8_t rb_put_avail(void *buffer);



// Liefert die Anzahl von Zeichen, die aus dem Puffer gelesen 
// werden k�nnen bis er leer ist und daher blockiert.
uint8_t rb_get_avail(void *buffer);



#endif
