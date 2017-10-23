//	biloader.c
//
// simple program to upload files to the blackice board
//
// syntax biloader [ -D device ] filename
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/termios.h>
#include <getopt.h>
#include <errno.h>
#include <pthread.h>

static int iofd = -1;

static void usage(void) {
  fprintf(stderr, "usage: biloader [ -D port ] file\n");
  exit(0);
}

static void openLink(char *device, speed_t speed) {
  struct termios tty;
  char buff[256];
  int retryct=0;
  
  for (;;) {
    iofd = open(device, O_RDWR/* |O_NONBLOCK */);
    if (iofd >= 0)
      break;
    if (errno == ENODEV) {
      fprintf(stderr, "device not found, plug it in and hit return: ");
      fgets(buff, 256, stdin);
    }
    if (errno == EBUSY) {
      fprintf(stderr, "device busy, pause and retrying\n");
      retryct++;
      if (retryct > 4) {
	fprintf(stderr, "retry count exceeded, giving up\n");
	exit(1);
      }
      sleep(5);
    }
    else {
      fprintf(stderr, "eserver: unable to open RS232 link\n");
      perror("open RS232");
      exit(1);
    }
  }
  tcgetattr(iofd, &tty);
  cfsetospeed(&tty, speed);		// set outgoing speed
  cfsetispeed(&tty, speed);		// set incoming speed
  tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8 | CSTOPB;	// set number of bits
  tty.c_iflag = IGNBRK;
  tty.c_lflag = 0;
  tty.c_oflag = 0;
  tty.c_cflag |= CLOCAL | CREAD;
  tcsetattr(iofd, TCSANOW, &tty);		// write attributes to kernel
  tcflush(iofd, TCIFLUSH);			// discard any initial messages
}

static void *reader(void *arg) {
  char buff[256];
  int n;

  for (;;) {
    n = read(iofd, buff, 256);
    if (n < 0) {
      fprintf(stderr, "I/O error reading link\n");
      perror("read()");
      exit(1);
    }
    if (n == 0) break;
    buff[n] = 0;
    fprintf(stderr, "%s\n", buff);
  }
  return NULL;
}

int main(int argc, char **argv) {
  int k, n, opt, size=0;
  char *device = "/dev/ttyACM0";
  char *d = getenv("BIPORT");
  FILE *in;
  char buff[4096];
  pthread_t thread;
  pthread_attr_t thread_attr;

  if (d != NULL) device = d;
  while ((opt = getopt(argc, argv, "D:")) != EOF) {
    switch (opt) {
    case 'D':
      device = strdup(optarg);
      break;
    default:
      usage();
    }
  }

  if (optind < argc)
    in = fopen(argv[optind], "r");
  else
    in = stdin;
  if (in == NULL) {
    fprintf(stderr, "biloader: unable to open binary file: %s\n", argv[optind]);
    exit(1);
  }
  openLink(device, B115200);
  pthread_attr_init(&thread_attr);
  pthread_create(&thread, &thread_attr, reader, NULL);

  while ((k = fread(buff, 1, 4096, in)) > 0) {
    n = write(iofd, buff, k);
    if (n != k) {
      if (n < 0) {
	fprintf(stderr, "I/O error on link\n");
	perror("write()");
	exit(1);
      }
      fprintf(stderr, "write failure: n=%d, k=%d\n", n, k);
      exit(1);
    }
    size += k;
  }
  printf("biloader: wrote %d bytes to %s\n", size, device);
  fclose(in);
  tcdrain(iofd);	// wait for last block to leave us
  close(iofd);		// before closing the device!
  return 0;
}

