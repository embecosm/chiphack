
.. What's New in High-Performance Python? slides file, created by
   hieroglyph-quickstart on Sat Apr 30 21:13:03 2016.


Sequential Verilog
==================

| Al Wood

Registers
---------

A simple memory to hold state, normally implemented as D-type flip-flop.

.. code-block:: verilog

   reg  y;
   reg [1:0] a2, b2;

Inputs and outputs can be declared as registers:

.. code-block:: verilog

   module mymod (
      input reg [1:0] y2;
      output reg [2:0] y3;

By convention usually only outputs are registers and inputs are wires.

Example: Decoder with register
------------------------------

.. code-block:: verilog

   module decoder (
      input  [1:0]     a,
      input            en,
      output reg [3:0] y
     )

      always_comb
         casex ({en,a})
            3'b0xx: y = 4'b0000;
            3'b100: y = 4'b0001;
            3'b101: y = 4'b0010;
            3'b110: y = 4'b0100;
            3'b111: y = 4'b1000;
         endcase    // {en,a}

   endmodule

Sequential always blocks
------------------------

.. code-block:: verilog

   always @(posedge clk)
      a <= b;

At the next positive edge of the clock, register ``a`` will acquire the value
held in ``b`` (which could be a register or wire).

SystemVerilog provides:

.. code-block:: verilog

   always_ff @(posedge clk)
      a <= b;

Delayed (non-blocking) assignments
----------------------------------

``<=`` causes the value to be transferred on the next clock edge. It should
only be used in sequential always blocks.

Conversely ``=`` (aka blocking assignment) happens immediately and should only
be used in combinatorial always blocks.

This means you can do surprising things with registers:

.. code-block:: verilog

   always_ff @(posedge clk)
      begin
         a <= b;
         b <= a;
      end

Common problems
---------------

You now know Verilog :-)  Here are the common "gotchas".

* Variable assigned in multiple always blocks
* Incomplete branch or output assignment

.. code-block:: verilog

   always_comb
      if (a > b)
         gt = 1'b1; // no eq assignment in branch
      else if (a == b)
         eq = 1'b1; // no gt assignment in branch
     // final else branch omitted

According to Verilog definition ``gt`` and ``eq`` keep their previous values when
not assigned which implies internal state, unintended latches are inferred.

Fixing incomplete output assignment (1)
---------------------------------------

These sort of issues cause endless hair pulling avoid such things. Here is how
we could correct this:

.. code-block:: verilog

   always_comb
      if (a > b) begin
         gt = 1'b1;
         eq = 1'b0;
      end
      else if (a == b) begin
         gt = 1'b0;
         eq = 1'b1;
      end
      else begin
         gt = 1'b0;
         eq = 1'b0;
      end

Fixing incomplete output assignment (2)
---------------------------------------

Or we can use default values.

.. code-block:: verilog

   always_comb
      begin
         gt = 1'b0;
         eq = 1'b0;
         if (a > b)
            gt = 1'b1;
         else if (a==b)
            eq = 1'b1;
      end

Incomplete output with case statements (1)
------------------------------------------

Similar problems can occur with ``case`` statements:

.. code-block:: verilog

   always_comb
      case (a)
         2'b00: y = 1'b1;
         2'b10: y = 1'b0;
         2'b11: y = 1'b1;
      endcase

Incomplete output with case statements (2)
------------------------------------------

A default clause is a good catchall.

.. code-block:: verilog

   always_comb
      case (a)
         2'b00:    y =1'b1;
         2'b10:    y =1'b0;
         2'b11:    y =1'b1;
         default : y = 1'b1;
      endcase

Exercise 4
----------

Which is actually lots of exercises, all in ``basic_verilog``

* ``blink``: Make the LED flash. Extend to make LED's flash in a pattern.

* ``fibonacci``: Count through the LEDs in a fibonacci sequence.

* ``button``: Make the LED's count when you press the button. Why won't it
  count nice and smoothly?

* ``button_edge_detect``: This solves the problem of detecting a button press.

* ``lock``: Unlock the device with a password. This leads into the next talk.
