# Praktikum: Eingebettete Mikrocontroller-Systeme
# (PEMSY)
# 
# Beispiel MAKEFILE. 
#
# Quelldateien werden im Unterverzeichnis src erwartet.
# Für jedes neue Programm wird ein entsprechendes
# Target benötigt.

# Der verwendete Controller
MCU 		:= atmega64
JUKEBOX_OBJS	:= main.o timer.o serial.o ringbuffer.o

# Unser Quellverzeichnis
SRCDIR		:= ./src

# Diverse Verzeichnisse
IMGDIR		:= ./images

# Pfade zu den verschiedenen Programmen
CC		:= avr-gcc
OBJCOPY 	:= avr-objcopy
SIZE   		:= avr-size
AVARICE		:= avarice
GDB		:= avr-gdb

# AVRDUDE Settings
DUDE		:= avrdude
DUDEPORT	:= /dev/ttyS1 
DUDEMCU		:= m64
DUDEFUSES 	:= -U efuse:w:0xFF:m
DUDEFUSES	+= -U lfuse:w:0xEF:m 
DUDEFUSES	+= -U hfuse:w:0x89:m
EEPROMFILE	:= eeprom.hex
#DUDEEEPROM	:= -U eeprom:w:$(EEPROMFILE):i

# Verschiedene Parameter 
CFLAGS 		:= -Os -g -Wall -Wstrict-prototypes -mmcu=$(MCU) -I. -Iinclude/
#CFLAGS		:= -g -Wall -Wstrict-prototypes -mmcu=$(MCU) -I. -Iinclude/
LDFLAGS         = -Wl,-u,vfprintf,-Map=$(@:.elf=.map),--cref -L/usr/lib/binutils/avr/2.16.1/ -lprintf_flt -lm
OBJCOPY_OPT 	:= -R .eeprom
JTAG_OPT	:= -B 500KHz -j /dev/ttyS0

#Old
#LDFLAGS         := -Wl,--cref -L/usr/lib/binutils/avr/2.16.1/
#LDFLAGS         := -Wl,--cref -L/usr/local/avr/lib/ldscripts/
#LDFLAGS          = -Wl,-Map=$(@:.elf=.map),--cref
#LDFLAGS         := -Wl,-Map=$(@:.elf=.map),--cref -L/usr/local/avr/lib/ldscripts/
#LDFLAGS         := -Wl,-Map=$(@:.elf=.map),--cref
#LDFLAGS 	:= -Wl,--cref

# Debug-Optionen
DEB_HOST	:= localhost
DEB_PORT	:= 4242
DEB_INITFILE	:= .gdbcmds


# Dieses Target wird ausgeführt wenn hinter make
# kein Parameter angegeben wurde
#all: $(SRCDIR)/main.o $(SRCDIR)/bar.o main.elf main.hex

all:	program

reset:
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) -U signature:r:/dev/null:h

stay_reset:
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) -E noreset -U signature:r:/dev/null:h

read_eeprom:
	cp $(EEPROMFILE) $(EEPROMFILE).`date "+%Y%m%d%H%M%S"`
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) -U eeprom:r:$(EEPROMFILE):i

write_eeprom:
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) -U eeprom:w:$(EEPROMFILE):i

notarget:
	@echo Keine Paramter. Stopp!

# Hier können die jeweiligen Targets erzeugt werden.
# Für jedes Programm muss dabei angegeben werden welche 
# .o-Dateien zu der ELF Datei gebunden werden sollen.
#
# Beispiel 1: 
# Ein Programm besteht aus der C Datei p1.c und soll
# in die Datei p1.elf bzw. dann später in die Datei p1.hex
# übersetzt werden. Es muss jetzt lediglich angegeben werden
# wie die .elf Datei erzeugt wird:
#
# 	p1.elf: $(SRCDIR)/p1.o
#
# Dabei wurde davon ausgegangen, dass sich die Quelldatei
# in dem Untervereichnis src befindet.
#
# Beispiel 2:
# Ein Programm besteht aus den C Dateien p1.c und p2.c.
# Das fertige Programm soll den Namen prg.hex tragen:
#
# 	prg.elf: $(SRCDIR)/p1.o $(SRCDIR)/p2.o
#
# Falls eine Zeile nicht für alle .o Dateien ausreichen sollte,
# kann mit dem "\" Zeichen auf der nächsten Zeile weitergeschrieben
# werden.
#
#
#
# HIER BITTE DIE EIGENEN TARGETS HINSCHREIBEN:
#
#p1.elf: $(SRCDIR)/p1.o
#program.elf: $(SRCDIR)/program.o
#prg.elf: $(SRCDIR)/p1.o $(SRCDIR)/p2.o

program: $(IMGDIR)/jukebox.hex
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) $(DUDEEEPROM) -V -U flash:w:$<

setfuses:
	$(DUDE) -P $(DUDEPORT) -p $(DUDEMCU) $(DUDEFUSES)

jukebox.elf: $(SRCDIR)/jukebox.o \
	$(SRCDIR)/timer.o \
	$(SRCDIR)/serial.o \
	$(SRCDIR)/ringbuffer.o \
	$(SRCDIR)/adc.o \
	$(SRCDIR)/menu.o \
	$(SRCDIR)/eeprom.o \
	$(SRCDIR)/fpga.o


#
# ENDE DER EIGENEN TARGETS
#


# Dieses Target löscht alle Zwischendateien
clean:
	rm -f $(IMGDIR)*.hex
	rm -f *.hex
	rm -f *.bin
	rm -f *.elf
	rm -f *.map
	rm -f $(SRCDIR)/*.o
	rm -f $(SRCDIR)/*.s

#$(SRCDIR)/eeprom.o: $(SRCDIR)/eeprom.c
#	$(CC) $(CFLAGSNOOPT) -c $< -o $@

# Rule, um aus einer .c Datei eine .o Datei zu erzeugen
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Rule, um eine ELF Datei zu erzeugen
# Rule, um eine ELF Datei zu erzeugen
# %.elf: $(SRCDIR)/%.o
#         $(CC) $(LDFLAGS) -mmcu=$(MCU) $^ -o $@
#                 chmod a-x $@
%.elf: $(SRCDIR)/%.o
	@echo ""
	@echo "-------------------------------"
	@echo "--    Generating ELF-File    --"
	@echo "-------------------------------"
	$(CC) $(LDFLAGS) -mmcu=$(MCU) $^ -o $@
	$(SIZE) $@
	chmod a-x $@

# Rule, um eine ELF Datei in das Intel HEX Format umzuwandeln
$(IMGDIR)/%.hex: %.elf
	@echo ""
	@echo "-------------------------------"
	@echo "-- Generating Intel HEX-File --"
	@echo "-------------------------------"
	$(OBJCOPY) -O ihex $(OBJCOPY_OPT) $< $@
	$(SIZE) $@

# Rule, um eine ELF Datei in das binäre Format umzuwandeln
%.bin: %.elf
	@echo ""
	@echo "-------------------------------"
	@echo "--    Generating BIN-File    --"
	@echo "-------------------------------"
	$(OBJCOPY) -O binary $(OBJCOPY_OPT) $< $@
	chmod a-x $@

# Dieses Target startet alle benötigten Programme um den OCD-
# Debugger zu benutzen. 
%.debug: %.elf %.prog
	-killall $(AVARICE)
	$(AVARICE) $(JTAG_OPT) --detach $(DEB_HOST):$(DEB_PORT)
	echo "target remote $(DEB_HOST):$(DEB_PORT)" >$(DEB_INITFILE) 
#	$(GDB) -x $(DEB_INITFILE) $<
	ddd --args -x $(DEB_INITFILE) $<
	-rm -f $(DEB_INITFILE)

# Target programmiert die Datei in den Mikrocontroller
# mit Hilfe des JTAGICE von Atmel
%.prog: %.bin
	$(AVARICE) $(JTAG_OPT) -e -p -v -f $< 
