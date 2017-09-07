#### UART Protocol Introduction

UART communication is typically byte based and uses a very simple protocol on a single wire. Each byte is sent individually serially, beginning with a _start_ bit and finishing with an _end_ or _stop_ bit. The receiving end synchronises to the start bit, samples (measures) the line at periods when it's known to be stable (this is why a rate of transmission must by known) and re-assembles the bits into a byte.

It couldn't be simpler than that! So 10 bits for every 8-bit byte transmitted. The _start_ bit is `0` and the _end_ bit is `1`.

![UART protocol basic](http://upload.wikimedia.org/wikipedia/commons/3/3d/Charactercode.png)

The UART line is logically _high_ when it is idle. This is why the start bit is `0` so the receiver can sample for this falling edge, and based on the transmission rate, know when to sample the middle of each bit period.

**The data is transmitted _least significant bit_ first.**

![UART protocol diagram](http://www.societyofrobots.com/images/microcontroller_uart_async.gif)

#### UART Protocol Implementation

The major parts of a UART transmitter are

* a state machine to organise when the start, data bits and stop bits are represented on the line
* a clock division (counting) scheme to determine when to change the output bit when transmitting

#### Clock divider

The _baud_ rate (bit rate) we'll use is `115200`. That's a transmission rate of `115200` bits a second.

The board's `100MHz` clock must be divided down to this rate to drive the transmit logic.

You do this by: `115200/(2*<BaudRate>)`

#### What to design

Build a system which takes the 100MHz clock and generates a 115.2kHz clock.

Use this to run a state machine which

* starts off by transmitting the data `0x30` (ASCII '0') after reset
* then detects if the pushbutton `1` (Key 1) has been pressed, and if so
 * transmits current word
 * increments word counting
* Once the data reaches the final word, should start the sequence again

A majority of the design has been provided. You will have to:

* Determine the number at which the clock divider should wrap
* Finish the state machine to control the states transmitting the start, 8 data, and stop bits.

#### Attaching UART to the PC

Getting UART output back to your PC requires 2 steps:

* Making the physical connection between the board and the PC
* Getting the PC software to read the UART input

Then attach the UART board to the PC via a USB cable.

#### Running UART terminal software

**Linux**:

We can monitor the UART by running the _screen_ tool. We will assume the UART device has appeared in the system's /dev directory as `/dev/ttyUSB0`. We will use the buad rate (as already mentioned) of **115200**.

> screen /dev/ttyUSB0 115200

If `screen` exits citing permissions errors, run the following:

> sudo chmod a+rwx /dev/ttyUSB0

.. and try launching screen again.

**Note**: To _exit_ screen once you're done, press: `ctrl+a` then `k` and `y` for _yes_ to _Really kill this window [y/n]_.

Optionally, if you _don't_ have `screen` installed you can try

> cat /dev/ttyUSB0

#### Stimulate the UART

Press **KEY1** to make the UART transmit the next chracter. You should see it turn up on the UART console.
