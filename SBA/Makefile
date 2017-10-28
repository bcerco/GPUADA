INCL:=$(shell echo *.h)
SRC:=$(shell echo *.c)
OBJ=$(SRC:.c=.o)
EXE=SBA

CC=gcc
CFLAGS= -Wall -pedantic
LDFLAGS= -o $(EXE)

%.o: %.c
	$(CC) -c $(CFLAGS) $*.c

$(EXE): $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ)

$(OBJ): $(INCL)

clean:
	rm $(OBJ) $(EXE)
