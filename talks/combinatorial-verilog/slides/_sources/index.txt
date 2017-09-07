
.. What's New in High-Performance Python? slides file, created by
   hieroglyph-quickstart on Sat Apr 30 21:13:03 2016.


Combinatorial Verilog
=====================

| Al Wood

Wires and net declarations
--------------------------

.. code-block:: verilog

   wire a, b;
   wire y;
   wire [1:0] a2, b2;

Inputs and outputs to and from modules are automatically declared as wires,
*unless* they are subsequently declared as registers (next talk).

.. code-block:: verilog

   module mymod (
      input  [1:0] y2;
      output [2:0] y3;
     )

Logic bitwise primitives
------------------------

Negation

.. code-block:: verilog

   assign y = ~a;

AND, OR and exclusive-OR gates

.. code-block:: verilog

   assign y = a & b;
   assign y = a | b;
   assign y = a ^ b;

Reduction
---------

.. code-block:: verilog

   wire y;
   wire [1:0] a2;
   assign y = | a2;

is equivalent to:

.. code-block:: verilog

   wire y;
   wire [1:0] a2;
   assign y = a2[1] | a2[0];

Concatenation and Replication
-----------------------------

.. code-block:: verilog

   wire y;
   wire [1:0] y2;
   wire [2:0] y3;

   assign y2 = {a,b};            // creates a 2-bit signal of a with b
   assign y2 = {a,1'b0};         // a with 1 bit binary 0 (constant)
   assign y3 = {a,b,1'b1};       // a with b with binary 1 (constant)
   assign y3 = {a,2'b10};        // a with 2 binary bits 1, 0
   assign y3 = {a,a2};           // a with a2 (a2 is 2 bits)
   assign y3 = {a,a2[0],1'b1};   // a with single bit from a2 with 1
   assign {y2,y} = {y3[1:0],a};  // multiple assignment: creates y2 as
                                 // 2 bits from y3 and y as a
   assign y3 = {a,2{1'b1}};      // a with 2 lots of binary 1

Note use of ``//`` to introduce a comment.

Shifting
--------

Both arithmetic and logic shifts are provided. The following table illustrates
the difference.

.. code-block:: verilog

   a           a >> 2      a >>> 2     a << 2      a <<< 3
   01001111    00010011    00010011    00111100    00111100
   11001111    00110011    11110011    00111100    00111100

Examples:

.. code-block:: verilog

   assign y2 = a2 >> 1;    // Logical 0's shifted in
   assign y2 = a2 >>> 1;   // Arithemtic MSB sign bit shifted in
   assign y2 = a2 << 1;    // Logical shift left same result as
   assign y2 = a2 <<< 1;   // Arithmetic shift left

Rotation
--------

Rotate right 1 bit:

.. code-block:: verilog

   assign y4 = {y3[0],y3[2:1]};

Rotate right 2 bit:

.. code-block:: verilog

   assign y4 = {y3[1:0],y3[2]};

Conditional expressions
-----------------------

A tertiary operator:

.. code-block:: verilog

   assign max = (a > b) ? a : b;

Operator precedence
-------------------

::

   () [] :: .
   + - ! ~ & ~& | ~| ^ ~^ ^~ ++ -- (unary)
   **
   * / %
   + - (binary)
   << >> <<< >>>
   < <= > >= inside dist
   == != === !== =?= !?=
   & (binary)
   ^ ~^ ^~ (binary)
   | (binary)
   &&
   ||
   ? : (conditional operator)
   >
   = += -= *= /= %= &= ^= |= <<= >>= <<<= >>>= := :/ <=
   {} {{}}

Combinatorial always blocks
---------------------------

For use when simple expressions get too complicated

.. code-block:: verilog

   always @(*)
      a = b;

   always @(*)
      begin
         a = b;
         y = a | b;
       end

SystemVerilog offers a more explicit format

.. code-block:: verilog

   always_comb
      a = b;

If/Else (1)
-----------

.. code-block:: verilog

   wire [7:0] a, b;
   wire [7:0] min;

   always_comb
      if(a < b)
         min = a;
      else
         min = b;

If/Else (2)
-----------

More generally:

.. code-block:: verilog

   always_comb
      if(boolean)
         begin     // need begin...end if >1 line of code within block
                   // if code
         end
      else
         begin
                   // else code
         end

Conditional example: 4-bit decoder
----------------------------------

Given a 2 bit value input, set that bit in the output, but only if the enable
input is asserted (high). Truth table:

.. code-block:: verilog

   en      a1      a2      y
   0       -       -       0000
   1       0       0       0001
   1       0       1       0010
   1       1       0       0100
   1       1       1       1000

Conditional example: implementation
-----------------------------------

.. code-block:: verilog

   module decoder (
      input [1:0]  a,
      input        en,
      output [3:0] y
     )

      always_comb
         if (~en)
            y = 4'b0000;  // 4-bit wide, binary representation: 0000
         else if(a == 2'b00)
            y = 4'b0001;
         else if(a == 2'b01)
            y = 4'b0010;
         else if(a == 2'b10)
            y = 4'b0100;
         else
            y = 4'b1000;

   endmodule

Conditional example: improved
------------------------------

.. code-block:: verilog

   module decoder (
      input [1:0]  a,
      input        en,
      output [3:0] y
     )

      always_comb
         case ({en,a})
            3'b000, 3'b001,3'b010,3'b011: y = 4'b0000;
            3'b100: y = 4'b0001;
            3'b101: y = 4'b0010;
            3'b110: y = 4'b0100;
            3'b111: y = 4'b1000;
         endcase    // {en,a}

   endmodule

Uncertainty: X and Z values
---------------------------

X is the "don't care" value. Specifiying this can make for more efficient
synthesis, since the tools can choose whichever value is most efficient.

Z is the "high impedence" value, typically used for connections that can be
both inputs and outputs, typically under the control of an enable signal.

.. code-block:: verilog

   assign y = (oen) ? a : 1'bz;

Decoder example using X
-----------------------

.. code-block:: verilog

   module decoder (
      input  [1:0] a,
      input        en,
      output [3:0] y
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

There is also ``casez``.

Multiple assignment
-------------------

.. code-block:: verilog

   always_comb
       if (en) y = 1'b0;

   always_comb
       y = a & b;

Won't synthesize because ``y`` is the output of two circuits which is
contraditory.  It should be written as:

.. code-block:: verilog

   always_comb
    if (en)
       y = 1'b0;
    else
       y = a & b;

Exercise 2
----------

Start with ``button_led.v`` in the ``basic_verilog/button_led``
directory. Complete it so that the LED which is lit up depends on whether the
button is pressed.

Build it with::

  make button_led

Then experiment using both buttons, so that each combination of buttons lights
a different LED. Use a ``case`` statement for this.
