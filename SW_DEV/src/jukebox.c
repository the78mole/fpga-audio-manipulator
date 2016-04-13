/********************************************************************************
 * Project	: Jukebox - The test laboratory	project				*
 * File		: jukebox.c							*
 * Author	: Daniel Glaser							*
 * Copyright	: 2007, LRS, University Erlangen-Nuremberg			*
 *										*
 *										*
 * Revision History								*
 * ----------------								*
 * Revision	Date		Author		Description			*
 * 0.0.1	2007-08-27	daniel		created				*
 *										*
 * ---------------------------------------------------------------------------- *
 *                                 Description					*
 * ---------------------------------------------------------------------------- *
 * This file is the main file of the jukebox project. It interfaces a simple	*
 * terminal of some PC to the FPGA on the laboratory board. The purpose is to   *
 * make the setup of the nonlinearity and the noise, which is added to the	*
 * nearly ideal analog-to-digital converter values easier. The software has	*
 * a full featured menu to make this setup and stores the chosen values in the	*
 * EEPROM, which is integrated into the microcontroller. When reset occurs, the *
 * voltages of the power supply are checked and the auxiliary supplies are	*
 * switched on and watched and the settings of the FPGA are restored.		*
 *										*
 * After powering up, the communication with the PC is initialized and the menu *
 * is shown in the terminal.							*
 *										*
 * Have fun to use it,								*
 * Daniel									*
 *										*
 ********************************************************************************/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include "jukebox.h"
#include "timer.h"
#include "serial.h"
#include "adc.h"
#include "menu.h"
#include "eeprom.h"
#include "fpga.h"

volatile uint8_t power_fail=0;

void print_dline(void) {
  print_bars(30);
  printf("\r\n");
}

void power_error(int error_code) {
  const char color_on[]=COLOR_RED;
  const char color_off[]=COLOR_OFF;
  const char failed_string[]="failed!!!\r\n";
  const char failed_wso_string[]=" while switching on ";

  if (error_code & 0x01) printf("%s5V  %s%s", color_on, failed_string, color_off);
  if (error_code & 0x02) printf("%s3V3 %s%s", color_on, failed_string, color_off);
  if (error_code & 0x04) printf("%s2V5 %s%s", color_on, failed_string, color_off);
  if (error_code & 0x08) printf("%s1V2 %s%s", color_on, failed_string, color_off);
  if (error_code & 0x10) printf("%s2V5%s%s%s", color_on, failed_wso_string, failed_string, color_off);
  if (error_code & 0x20) printf("%s5 V%s2V5 %s%s", color_on, failed_wso_string, failed_string, color_off);
  if (error_code & 0x40) printf("%s1V2%s%s%s", color_on, failed_wso_string, failed_string, color_off);
  if (error_code & 0x80) printf("%s5V %s1V2 %s%s", color_on, failed_wso_string, failed_string, color_off);
  if (error_code == 0) {
    print_dline();
    printf(COLOR_GREEN"  Power OK"COLOR_OFF"\r\n");
    print_dline();
  } else {
    print_dline();

  }
}

void main_power_check(uint8_t initial, uint8_t show_volts, uint8_t check_channel) {
  float factor=1.0;
  uint16_t min=0, max=50;
  uint8_t error_code=0;
  switch(check_channel) {
    case ADC_CHANNEL_0:
      // 3V3 (must be between 3.135 and 3.465V)
      factor = SUPPLY_3V3_FACTOR; // 1.303 (alt), 1.702 (neu)
      
      min=3135;
      max=3465;
      error_code=0x02;
      break;
    case ADC_CHANNEL_1:
      // 2.5V (should be 0 but is pulled up a bit by 3V3)
      factor = SUPPLY_2V5_FACTOR; // 1.0 (alt), 1,213 (neu)
      if(initial) {
        max=2000;
        error_code=0x04;
      } else {
        min=2375;
	max=2625;
	error_code=0x10;
      }
      break;
    case ADC_CHANNEL_2:
      factor = SUPPLY_1V2_FACTOR; // 1.0
      if(initial) {
        // 1.2V (must be 0V, a few mV are allowed)
        error_code=0x08;
      } else {
        // 1.2V (must be between 1.140 and 1.160V)
        min=1120; // We have to build in some filter
	max=1280; // and then adjust it back to normal
        error_code=0x40;
      }
      break;
    case ADC_CHANNEL_3:
      // 5V (must be 5V -> 4.5-5.5V)
      factor = SUPPLY_5V0_FACTOR; // 2.0 (alt) 2.447 (neu)
      min=4500;
      max=5500;
      if(initial==1) error_code=0x01;
      else if(initial==2) error_code=0x20;
      else if(initial==3) error_code=0x80;
      break;
  }

  if(adc_check_power(check_channel, factor, min, max, show_volts)==-1) power_fail|=error_code;
}

void initial_power_check(void) {
  printf(COLOR_BLUE"Disabling the power supplies (2,5V, 1,2V)"COLOR_OFF"\r\n");
  DDRB |= (3<<PB6);	// Power supply enables are outputs
  PORTB &= ~(3<<PB6);	// Deactivate the power supplies
  timer2_wait(STD_DELAY);
  
  main_power_check(1, 1, ADC_CHANNEL_3);
  main_power_check(1, 1, ADC_CHANNEL_0);
  main_power_check(1, 1, ADC_CHANNEL_1);
  main_power_check(1, 1, ADC_CHANNEL_2);
 
  timer2_wait(500);

  power_error(power_fail);

  // Power up sequence
  printf(COLOR_BLUE"Switching on 2.5V"COLOR_OFF"\r\n");

  PORTB |= 1<<PB6;
  timer2_wait(300); main_power_check(0, 1, ADC_CHANNEL_1);
  timer2_wait(100); main_power_check(2, 1, ADC_CHANNEL_3);

  power_error(power_fail);

  printf(COLOR_BLUE"Switching on 1.2V"COLOR_OFF"\r\n");
  PORTB |= 1<<PB7;
  timer2_wait(300); main_power_check(0, 1, ADC_CHANNEL_2);
  timer2_wait(100); main_power_check(3, 1, ADC_CHANNEL_3);
 
  power_error(power_fail);

  // power up finished
}

void operation_power_check(void) {
  main_power_check(0,0,ADC_CHANNEL_0);
  main_power_check(0,0,ADC_CHANNEL_1);
  main_power_check(0,0,ADC_CHANNEL_2);
  main_power_check(0,0,ADC_CHANNEL_3);
  if(power_fail) PORTD |= 1<<PD5; // Switch on red LED
}

void main_init(void) {
  uint8_t itmp;

  serial_init();
 
  PORTD |= 7<<PD5;
  DDRD |= 15<<PD4;
  fdevopen((void*)serial_putc, (void*)serial_get); 
  
  serial_set_echo(SERIAL_ECHO_OFF);

  for(itmp=0; itmp<20; itmp++) printf("\r\n");
  printf("Initialization\r\n");

  printf("Initializing delay timer (2)...\r\n");
  timer2_init();
  adc_init();
  
  timer2_wait(STD_DELAY);

  printf("Disable JTAG...\r\n");
  cli();
  MCUCSR |= (1<<JTD);
  MCUCSR |= (1<<JTD); // 2 mal in Folge ,vgl. Datenblatt fuer mehr Information
  sei();
  timer2_wait(STD_DELAY);

  initial_power_check();

  printf("EEPROM Check:");
  if(eeprom_is_config_valid()==1) printf(COLOR_GREEN" Valid!"COLOR_OFF);
  else printf(COLOR_RED" Invalid!"COLOR_OFF);
  printf("\r\n");
}

int main(void) {
  int itmp;

  ////////////////////////////////////////////////////////////////
  // Initialization

  main_init();
//  while(1);

  while(power_fail) {
    printf(".");
    timer2_wait(1000);
  }

  fpga_init();
  
  print_menu(0);

/*  fpga_put_eeprom_uint16(FPGA_COEFF_BASE, (uint16_t)(-12288));
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+2, 4096);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+4, 16384);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+6, 0);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+8, 8192);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+10, 0);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+12, -16384);
  fpga_put_eeprom_uint16(FPGA_COEFF_BASE+14, 0);*/
  
  ////////////////////////////////////////////////////////////////
  // Main loop

  serial_set_echo(SERIAL_ECHO_OFF);

/*  while(1) {
    DDRG = 0xFF;
    PORTG = 0x00;
    PORTD |= (1<<PD7);
    timer2_wait(10000);
    PORTG = 0xFF;
    PORTD &= ~(1<<PD7);
    timer2_wait(10000);
  }*/

  itmp = -1;
  
//  while(1) {
  while(power_fail==0) {
    itmp = serial_get();
    if(fpga_check_cfg_done()==0) {
      printf("\r\nFPGA Configuring");
      while(fpga_check_cfg_done()==0) {
        printf(".");
	timer2_wait(500);
      }
      itmp=0;
    }
    if(itmp != -1) {
      print_menu((unsigned char)(itmp));
    }
    operation_power_check();
  }

  // Main loop exited with power failure
  PORTD &= ~(1<<PD5);
  PORTB &= ~((1<<PB6)|(1<<PB7)); // Power off
  printf(COLOR_RED"Power failed while operating (Code %x)! Shut down and abort!"COLOR_OFF, power_fail);
  power_error(power_fail);

  while(1) {
    timer2_wait(500);
    printf(".");
  }
  
  // We should never get to this point
  return 0;
}
