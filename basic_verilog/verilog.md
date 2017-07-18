Verilog Tutorial, from myStorm
==============================

## Wires

```verilog
wire input a,b;
wire output y;
wire input a2[1:0],b2[1:0];
wire output y2[1:0];
wire output y3[2:0];
```

## Logic bitwise primitives

### Negation

```verilog
assign y = ~a;
```

### AND Gate

```verilog
assign y = a & b;
```

### OR Gate

```verilog
assign y = a | b;
```

### Exclusive OR Gate

```verilog
assign y = a ^ b;
```

## Reduction

```verilog
assign y = | a2;
```

### is equivalent to:

```verilog
assign y = a2[1] | a2[0];
```

## Concatenation and Replication

```verilog
assign y2 = {a,b};            // creates a 2-bit signal of a with b
assign y2 = {a,1'b0};         // a with 1 bit binary 0 (constant)
assign y3 = {a,b,1'b1};       // a with b with binary 1 (constant)
assign y3 = {a,2'b10};        // a with 2 binary bits 1, 0
assign y3 = {a,a2};           // a with a2 (a2 is 2 bits)
assign y3 = {a,a2[0],1'b1};   // a with single bit from a2 with 1
assign {y2,y} = {y3[1:0],a};  // multiple assignment: creates y2 as 2 bits from y3 and y as a
assign y3 = {a,2{1'b1}};      // a with 2 lots of binary 1
```

## Shifting

```verilog
// a         a >> 2    a >>> 2   a << 2    a << 3
// 01001111  00010011  00010011  00111100  00111100
// 11001111  00110011  11110011  00111100  00111100
assign y2 = a2 >> 1; // Logical 0's shifted in
assign y2 = a2 >>> 1; // Arithemtic MSB sign bit shifted in
assign y2 = a2 << 1; // Logical shift left same result as
assign y2 = a2 <<< 1; // Arithmetic shift left
```

## Rotation

### Rotate right 1 bit

```verilog
assign y3 = {y3[0],y3[2:1]};
```

### Rotate right 2 bit

```verilog
assign y3 = {y3[1:0],y3[2]};
```

## Operator precedence

```verilog
!,~,+,-(uni),**,*,/,%,+,-(bin),>>,<<,>>>,<<<,==,!=,===,!==,&,^,|,&&,||,?: */
```

## Conditionals

### Tertiary

```verilog
assign max = (a > b) ? a : b;
```

## If/Else

(NB not sequential, actually 'network routings')

```verilog
if(a < b)
	assign min = a;
else
	assign min = b;
```

```verilog
if(boolean)
	// if code
else if (boolean)
	// if else 1 code
else
	// else code
```

```verilog
if(boolean)
	begin  // need begin...end if >1 line of code within condition
		// begin code
	end
else
	begin
		// else code
	end
```

## Synthesis of Z and X Values

Z values can only be synthesized by tristate buffers and thus infer them
these have output enable inputs to control their output state for example here
is a single bit tristate buffer with an output enable

```verilog
assign y = (oen) ? a : 1'bz;
```

This sort of construuct is useful for biderectional ports or buses.

The synthesis of X is don't care, the value may be either 0 or 1, this can
improve the efficiency or optimisation of combinational circuits

```verilog
assign y = (a == 2'b00) ? 1'b0:
					 (a == 2'b01) ? 1'b1:
					 (a == 2'b10) ? 1'b1:
					 1'bx; // i == 2'b11
```

## Behavioural Blocks

Procedural blocks using always block, these black box sections describe
behaviour using procedural statements, always behavioural blocks are defined
with an event control expression or sensitivity list

```verilog
always @(sensitivity list)
	begin [Optional label]
		[optional local variable declarations];

		[procedural statements];
	end [optional label]
```

### Procedural Assignment


```verilog
[variable] = [expression];  // blocking, assigned before next statement
                            // like normal C
[variable] <= [expression]; // non blocking, assigned at end of always block
```

Blocking tends to be used for combinational circuits, non-blocking for
sequential

In a procedural assignment, an expression can only be assigned to an output
with one of the variable data types, which are reg, integer, real, time, and
realtime.  The reg data type is like the wire data type but used with a
procedural output.  The integer data type represents a fixed-size (usually 32
bits) signed number in 2's-complement format. Since its size is fixed, we
usually don't use it in synthesis.  The other data types are for modelling and
simulation and cannot be synthesized.

## Registers

A register is simple memory wire to hold state, normally implemented as
D-Types

```verilog
output reg   // single-bit, use [] syntax above for >1 bit registers
```

## Conditional Examples

### binary encoder

```
en      a1      a2      y
0       -       -       0000
1       0       0       0001
1       0       1       0010
1       1       0       0100
1       1       1       1000
```

```verilog
module pri_encoder
	(  // 4 bit input, 3 bit output
		input wire [4:1] r,
		output wire [2:0] y
	)

	always @*
		if(r[4])
			y = 3'b000;
		else if(r[3])
			y = 3'b011;
		else if(r[2])
			y = 3'b010;
		else if(r[1])
			y = 3'b001;
		else
			y = 3'b000;

endmodule
```

```verilog
module decoder_1
	(
		input wire [1:0] a,
		input wire en,
		output reg [3:0] y
	)
	always @*  // @* means 'Anything needed'; clearer to list required resources but danger of missing items
		if(~en)
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
```

### Case

```verilog
module decoder_2
	(
		input wire [1:0] a,
		input wire en,
		output reg [3:0] y
	)

	always @*
		case ({en,a})
			3'b000, 3'b001,3'b010,3'b011: y = 4'b0000;
			3'b100: y = 4'b0001;
			3'b101: y = 4'b0010;
			3'b110: y = 4'b0100;
			3'b111: y = 4'b1000;
		endcase // {en,a}

endmodule
```

```verilog
module decoder_3
	(
		input wire [1:0] a,
		input wire en,
		output reg [3:0] y
	)

	always @*
		case ({en,a})
			3'b100: y = 4'b0001;
			3'b101: y = 4'b0010;
			3'b110: y = 4'b0100;
			3'b111: y = 4'b1000;
			default: y = 4'b0000;
		endcase // {en,a}

endmodule
```

### Casex

```verilog
module decoder_4
	(
		input wire [1:0] a,
		input wire en,
		output reg [3:0] y
	)

	always @*
		casex ({en,a})
			3'b0xx: y = 4'b0000;
			3'b100: y = 4'b0001;
			3'b101: y = 4'b0010;
			3'b110: y = 4'b0100;
			3'b111: y = 4'b1000;
		endcase // {en,a}

endmodule
```

When the values in the item expressions are mutually exclusive (i.e., a value
appears in only one item expression), the statement is known as a parallel
case statement. When synthesized, a parallel case statement usually infers a
multiplexing routing network and a non-parallel case statement usually infers
a priority routing network. Unlike C where conditional constructs are executed
serially using branches and jumps, with HDL these are realised by routing
networks.

### Casez

```verilog
module decoder_4
	(
		input wire [1:0] a,
		input wire en,
		output reg [3:0] y
	)

	always @*
		casez ({en,a})
			3'b0??: y = 4'b0000;  // casez also offers '?'
			3'b100: y = 4'b0001;
			3'b101: y = 4'b0010;
			3'b110: y = 4'b0100;
			3'b111: y = 4'b1000;
		endcase // {en,a}

endmodule
```

In casez, the `?` is used to indicate either X or Z state.

## Common Errors

* Variable assigned in multiple always blocks
* Incomplete sensitivity list
* Incomplete branch and incomplete output assignment

### Multiple assignment

```verilog
always @*
	if(en) y = 1'b0;

always @*
	y = a & b;
```

`y` is the output of two circuits which could be contradictary, this is not
synthesizable.  Below is how this should have been written:

```verilog
always @*
	if(en)
		y = 1'b0;
	else
		y = a & b;
```

### Incomplete sensitivity list

Incomplete sensitivity list (missing `b`).  `b` could change but the y output
would not, causing unexpected behaviour again this is not synthesizable.

```verilog
always @(a)
	y = a & b;
/* Fixed versions */
always @(a,b)
	y = a & b;
/* or simple cure all */
always @*
	y = a & b;
```

### incomplete branch or output assignment

Incomplete branch or output assignment, do not infer state in combinational
circuits.

```verilog
always @*
	if(a > b)
		gt = 1'b1; // no eq assignment in branch
	else if(a == b)
		eq = 1'b1; // no gt assignment in branch
	// final else branch omitted
```

Here we break both incomplete output assignment rules and branch.  According to
Verilog definition `gt` and `eq` keep their previous values when not assigned
which implies internal state, unintended latches are inferred, these sort of
issues cause endless hair pulling avoid such things. Here is how we could
correct this:

```verilog
always @*
	if(a > b)
		begin
			gt = 1'b1;
			eq = 1'b0;
		end
	else if (a == b)
		begin
			gt = 1'b0;
			eq = 1'b1;
		end
	else
		begin
			gt = 1'b0;
			eq = 1'b0;
		end
```

Or easier still assign default values to variables at the beginning of the
always block

```verilog
always @*
	begin
		gt = 1'b0;
		eq = 1'b0;
		if(a > b)
			gt = 1'b1;
		else if (a==b);
			eq = 1'b1;
	end
```

Similar errors can creep into case statements

```verilog
case(a)
	2'b00: y = 1'b1;
	2'b10: y = 1'b0;
	2'b11: y = 1'b1;
endcase
```

Here the case `2'b01` is not handled, is a has this value y gets it's previous
value and a latch is assumed, the solution is to include missing case, assign
`y` a value before the case or add a default clause.

```verilog
case(a)
	2'b00: y =1'b1;
	2'b10: y =1'b0;
	2'b11: y =1'b1;
	default : y = 1'b1;
endcase
```

## Adder with carry

```verilog
module adder #(parameter N=4)  // input parameter N, default value of 4 if not specified. N will be the adder width here
	(
	input wire [N-1:0] a,b,
	output wire [N-1:0] sum,
	output wire cout   // carry bit
	);

	/* Constant Declaration */
	localparam N1 = N-1;  // localparam: only visible within module

	/* Signal Declaration */
	wire [N:0] sum_ext;  // NB not N-1

	/* module body */
	assign sum_ext = {1'b0, a} + {1'b0, b}; // excludes Nth bit
	assign sum = sum_ext[N1:0];
	assign cout = sum_ext[N];

endmodule

module adder_example
	(
		input wire [3:0] a4,b4,
		output wire [3:0] sum4,
		output wire c4
		)
	// Instantiate a 4 bit adder - .N specifies parameter name N; connect a to a4, b to b4, sum to sum4, cout to c4
	adder #(.N(4)) four_bit_adder (.a(a4), .b(b4), .sum(sum4), .cout(c4));

endmodule
```

## LocalParams

```verilog
localparam N = 4
```
