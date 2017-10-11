CFLAGS = -Wall

all:	miniserve

miniserve:	miniserve.o
	$(CC) $(CFLAGS) -o miniserve miniserve.o -lpthread

clean:
	rm -f miniserve.o miniserve
	rm -f *~
