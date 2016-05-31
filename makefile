#CC = gcc
CFLAGS = `sdl2-config --cflags` -g
LD = ld
LINKFLAGS = -m64 `sdl2-config --libs` -lm
LDFLAGS = 
AS = nasm
ASFLAGS = -f elf64 -g

C_SOURCES = \
	main.c \

C_OBJECTS=$(C_SOURCES:.c=.o)

ASM_SOURCES = \
	mandel.asm
	
ASM_OBJECTS=$(ASM_SOURCES:.asm=.o)

all: app 

%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o : %.asm
	$(AS) $(ASFLAGS) $< -o $@

ifdef C_SOURCES
app : $(ASM_OBJECTS) $(C_OBJECTS)
	$(CC) $(ASM_OBJECTS) $(C_OBJECTS) -o $@ $(LINKFLAGS)
else
app : $(ASM_OBJECTS) $(C_OBJECTS)
	$(LD) $(LDFLAGS) $(ASM_OBJECTS) -o $@
endif

.PHONY: clean

clean:
	- rm *.o
