
.. What's New in High-Performance Python? slides file, created by
   hieroglyph-quickstart on Sat Apr 30 21:13:03 2016.


UART Design
===========

| Philipp Wagner


State Machines
--------------

.. figure:: state-machine.png

Image courtesy Wikipedia

UART
----

Two wire serial connection protocol

* Tx wire to transmit

* Rx wire to receive

.. figure:: ehw5-uart.jpg

The EHW5 UART: Set to 3.3V!
---------------------------

.. figure:: ehw5-uart-top.jpg

UART protocol
-------------

The UART protocol sends a start bit, 8 data bits and a stop bit

.. figure:: uart-timing-diagram.png

The idle state is high, so start bit is low. The stop bit is high.

.. figure:: uart-example.png

Exercise 4: Hardware
--------------------

.. figure:: uart-wiring.png

The EHW5 UART: Set to 3.3V!
---------------------------

.. figure:: ehw5-uart-top.jpg

Exercise 5
----------

Two exercises

* Build a UART Transmitter (``uart`` directory)
* Build a UART Receiver (``uart_receiver`` directory)

The UART to USB will need a suitable terminal program on the PC (*Teraterm* on
PC, *screen* or *miniterm* on Mac/Linux).
