//	miniserve.c
//
// Assumes RS232 port is on /dev/ttyUSB0, and a bit rate of 9600 baud
// 
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/termios.h>
#include <sys/types.h>
#include <sys/time.h>
#include <signal.h>
#include <getopt.h>
#include <pthread.h>

static int iofd = -1;
static FILE *iof = NULL;
static FILE *trf = NULL;
static FILE *log = NULL;
static unsigned char trace[8];
static int verbose = 0;
static char *iofn;			// initial orders file name
static char *trfn;			// tape reader file name
static int going = 1;
static short mem[1024];			// store image

static int speeds[] = { 50, 75, 110, 134, 150, 200, 300, 600, 1200,
			1800, 2400, 4800, 9600, 19200, 38400, 57600,
			115200, 230400 };
static speed_t bspeeds[] = { B50, B75, B110, B134, B150, B200, B300, B600, B1200,
			     B1800, B2400, B4800, B9600, B19200, B38400, B57600,
			     B115200, B230400 };

#define DEVICE "/dev/ttyUSB0"
#define SPEED 9600

static void terminate(int ret) {
  if (log != NULL) fclose(log);
  if (trf != NULL) fclose(trf);
  if (iof != NULL) fclose(iof);
  if (iofd > 0) close(iofd);
  exit(ret);
}

int parseIO(void) {
  // read lines from the Initial Orders file and do a crude parsing
  // return the presumed order as 16-bit int, return -1 at EOF
  char buff[256], *p;
  int op, address;

  while (fgets(buff, 256, iof)) {
    p = buff;
    if (isalpha(*p) || *p == '@') {
      op = *p++ & 0x1F;
      while (*p == ' ' || *p == '\t')
	p++;
      if (!isdigit(*p)) {
	fprintf(stderr, "miniserve: syntax error in initial orders: %s", buff);
	terminate(1);
      }
      address = 0;
      while (isdigit(*p))
	address = address * 10 + *p++ - '0';
      return (op << 11) + address;
    }
    else if (*p == ';')
      continue;
    else {
      fprintf(stderr, "miniserve: syntax error in initial orders: %s", buff);
      terminate(1);
    }
  }
  return -1;	// end of file
}

static void send(char x) {
  write(iofd, &x, 1);
  if (x > 32 && x < 127)
    fprintf(log, "\nsent: %c (0x%02x) ", x, x & 0xFF);
  else
    fprintf(log, "\nsent: 0x%02x ", x & 0xFF);
}

static void handler(int sig) {
  terminate(0);
}

static void tracer(int n) {
  int i, k, b, IR, SCT, Acc, op, addr;

  for (i=0; i<6; i++) {
    k = read(iofd, trace+i, 1);	// read debug info
    if (k != 1) {
      fprintf(stderr, "miniserve: I/O error on link\n");
      terminate(1);
    }	
  }
  SCT = (trace[0] << 8) + trace[1];
  IR = (trace[2]<<8) + trace[3];
  Acc = (trace[4]<<8) + trace[5];
  op = ((IR >> 11) & 0x1F) + '@';
  addr = IR & 0x3ff;
  b = IR & 0x400;	// check for the B digit
  fprintf(log, "SCT=%d, IR=%04x: (%c %c%d)", SCT, IR, op, b ? '*' : ' ', addr);
  if (n == 5) {
    if (op == 'B' || op == 'J' || op == 'K')
      fprintf(log, " B=%04x, %d", Acc, Acc);
    else
      fprintf(log, " Acc=%04x, %d", Acc, Acc);
  }
  fflush(log);
}

static void traceMem(void) {
  int i, k, b, IR, SCT, op, addr;

  for (i=0; i<6; i++) {
    k = read(iofd, trace+i, 1);	// read debug info
    if (k != 1) {
      fprintf(stderr, "miniserve: I/O error on link\n");
      terminate(1);
    }	
  }
  SCT = (trace[0] << 8) + trace[1];
  IR = (trace[2]<<8) + trace[3];
  op = ((IR >> 11) & 0x1F) + '@';
  addr = IR & 0x3ff;
  b = IR & 0x400;	// check for the B digit
  fprintf(log, "SCT=%d, IR=%04x: (%c %c%d)", SCT, IR, op, b ? '*' : ' ', addr);
  mem[SCT] = IR;
  fflush(log);
}

static int starting;
static int debug;

static void *run(void *arg) {
  int k, tapechar, bootword, printPending=0;
  char cmd;
  char buff[256];

  for (;;) {
    k = read(iofd, &cmd, 1);			// wait for command from FPGA
    if (k != 1) {
      fprintf(stderr, "I/O error on link\n");
      terminate(1);
    }
    fprintf(log, "\nreceived: %c (0x%02x) ", cmd, cmd & 0xFF);
    fflush(log);
    if (printPending) {
      printf("%c", cmd);
      printPending = 0;
      send('A');
      fflush(stdout);
    }
    else
      switch (cmd) {
      case 'Z':
	fprintf(log, "Halted!\n");
	printf("Halted!\n");
	tracer(3);
	fflush(log);
	break;
      case 'H':
	fprintf(log, "Illegal opcode\n");
	printf("Illegal opcode\n");
	tracer(3);
	fflush(log);
	break;
      case 'B':
	bootword = parseIO();
	send((bootword >> 8) & 0xFF);
	break;
      case 'C':
	send (bootword & 0xFF);
	break;
      case 'D':
	bootword = parseIO();
	if (bootword < 0)
	  send('S');		// terminate boot loading
	else {
	  send('B');
	  send((bootword >> 8) & 0xFF);
	}
	break;
      case 'K':
	k = read(iofd, &cmd, 1);
	fprintf(log, "Reset: %d\n", cmd);
	break;
      case 'R':
	for (;;) {
	  tapechar = fgetc(trf);
	  if (tapechar < 0) {	// EOF
	    printf("EOF on input tape, abandoning run\n");
	    terminate(1);
	  }
	  if (tapechar == ';') {
	    fgets(buff, 256, trf);
	    tapechar = '\n';
	  }
	  send(tapechar);
	  break;
	}
	break;
      case 'T':
	send ('T');
	printPending = 1;
	break;
      case 's':
	send('S');
	break;
      case 'S':
	send ('G'+debug);
	starting = 0;
	break;
      case 'Q':
	tracer(5);
	break;
      case 'M':
	traceMem();
	break;
      default:
	if (starting) {
	  send('S');	// retry start command?
	}
	else
	  printf("illegal character: %02x!\n", cmd);
	break;
      }
  }
  return NULL;
}

static void openLink(char *device, speed_t speed) {
  struct termios tty;

  iofd = open(device, O_RDWR/* |O_NONBLOCK */);
  if (iofd < 0) {
    fprintf(stderr, "eserver: unable to open RS232 link\n");
    perror("open RS232");
    terminate(1);
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
  signal(SIGTERM, handler);
  signal(SIGINT, handler);			// trap ^c to flush log
}

static void usage(void) {
  fprintf(stderr, "usage: miniserve [ options ]\n");
  fprintf(stderr, "where options are:\n");
  fprintf(stderr, "      -d devicename	serial port device, default: /dev/ttyUSB0\n");
  fprintf(stderr, "      -s speed       baud rate, default 9600\n");
  fprintf(stderr, "      -g             request debug tracing, default off\n");
  fprintf(stderr, "      -i filename	initial orders, default \"initialorders.txt\"\n");
  fprintf(stderr, "      -l filename    logging file, sefault \"session.log\"\n");
  fprintf(stderr, "      -m             enable memory dump after login, default off\n");
  fprintf(stderr, "      -t filename    tape reader file, default null\n");
  fprintf(stderr, "      -v             verbosity, additional messages\n");
  exit(0);
}

static speed_t convertSpeed(char *arg) {
  // compare arg to list of valid speeds,
  // abort if not in list!
  int a = atoi(arg);		// first convert to integer
  int i, n=sizeof(speeds)/sizeof(speeds[0]);

  for (i=0; i<n; i++) {
    if (speeds[i] == a)
      return bspeeds[i];
  }
  fprintf(stderr, "invalid speed specified: %s\n", arg);
  usage();
  return B0;	// never happens, usage() calls exit()
}

static void runProg(int trace, int mem) {
  if (iof != NULL) {
    fclose(iof);
    iof = NULL;
  }
  if (trf != NULL) {
    fclose(trf);
    trf = NULL;
  }
  iof = fopen(iofn, "r");
  if (iof == NULL) {
    fprintf(stderr, "miniserve: unable to access Initial Orders file: %s\n", iofn);
    terminate(1);
  }
  trf = fopen(trfn, "r");
  if (trf == NULL) {
    fprintf(stderr, "miniserve: unable to access program file: %s\n", trfn);
    terminate(1);
  }
  debug = trace+mem;
  starting = 1;					// indicate in startup  
  send('S');					// send a 'START' command
}

static int toggleTracing(int trace) {
  trace = trace ? 0 : 1;
  printf("tracing now %s\n", trace ? "on" : "off");
  return trace;
}

static void setTape(char *name) {
  char *q;

  name++;	// space over 't' command
  while (*name == ' ' || *name == '\t') name++;
  q = strchr(name, '\n');
  if (q != NULL) {
    *q = 0;
    while (--q > name && *q == ' ')
      *q = 0;
  }
  trfn = strdup(name);
  printf("tape set to read %s\n", name);
}

static void clearmem(void) {
  int i;
  for (i=0; i<1024; i++)
    mem[i] = 0;
}

static void printMem(char *cmd) {
  int a=0, n=0, i, len=0, mode=0;
  int w;

  cmd++;
  if (*cmd == 'l') {
    len = 1;
    cmd++;
  }
  if (*cmd == 'd') {
    mode = 1;
    cmd++;
  }
  while (*cmd == ' ' || *cmd == '\t') cmd++;
  if (isdigit(*cmd)) {
    while (isdigit(*cmd)) {
      a = a*10 + *cmd - '0';
      cmd++;
    }
  }
  while (*cmd == ' ' || *cmd == '\t') cmd++;
  if (isdigit(*cmd)) {
    while (isdigit(*cmd)) {
      n = n*10 + *cmd - '0';
      cmd++;
    }
  }
  for (i=0; i<n; i++) {
    w = mem[a];
    if (len)
      w = (mem[a] << 16) | mem[a+1];
    if (mode == 1)
      printf("mem[%d] = %d\n", a, w);
    else if (len)
      printf("mem[%d] = 0x%08x\n", a, w);
    else
      printf("mem[%d] = 0x%04x\n", a, w & 0xFFFF);
    a += len ? 2 : 1;
  }
}

int main(int argc, char **argv) {
  char *device = DEVICE;
  int trace = 0;
  int mem = 0;
  int opt;
  speed_t speed = B9600;
  char *tSpeed = "9600";
  char cmd[80];
  char *logfn;
  char *t;
  pthread_t thread;
  pthread_attr_t thread_attr;

  // set default file names
  iofn = "initialorders.txt";
  trfn = "/dev/null";
  logfn = "session.log";
  t = getenv("BIPORT");
  if (t != NULL)
    device = t;		// get device name from environment
  t = getenv("BISPEED");
  if (t != NULL) {
    tSpeed = t;
    speed = convertSpeed(t);
  }
  while ((opt = getopt(argc, argv, "d:i:t:l:s:gmv")) != EOF) {
    switch (opt) {
    case 'd':
      device = optarg;	break;
    case 'g':
      trace = 1;		break;
    case 'i':
      iofn = optarg;		break;
    case 'l':
      logfn = optarg;		break;
    case 'm':
      mem = 2;			break;
    case 's':
      tSpeed = optarg;
      speed = convertSpeed(optarg);	break;
    case 't':
      trfn = optarg;		break;
    case 'v':
      verbose = 1;		break;
    default:
      usage();
    }
  }
  log = fopen(logfn, "w");
  if (log == NULL) {
    fprintf(stderr, "miniserve: unable to open log file: %s\n", logfn);
    terminate(1);
  }
  openLink(device, speed);
  printf("miniserve version 1.5\n");
  printf("using port: %s and speed: %s baud\n", device, tSpeed);
  printf("commands are:\n");
  printf("	r	run the program\n");
  printf("	g	toggle tracing\n");
  printf("	t file	specify new tape reader file\n");
  printf("	q	quit\n\n");
  pthread_attr_init(&thread_attr);
  pthread_create(&thread, &thread_attr, run, NULL);
  while (going) {
    printf(": ");
    if (fgets(cmd, 80, stdin) == NULL) break;
    switch (cmd[0]) {
    case 'q':
      going = 0;
      break;
    case 'r':
      runProg(trace, mem);
      break;
    case 'g':
      trace = toggleTracing(trace);
      break;
    case 't':
      setTape(cmd);
      break;
    case 'z':
      clearmem();
      break;
    case 'p':
      printMem(cmd);
      break;
    default:
      printf("!?!?!\n");
    }
  }
  terminate(0);
  return 0;
}
