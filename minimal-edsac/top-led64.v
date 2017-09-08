module top (
	input clk_in,
	input RX,
	output TX,
	input [1:0] BUTTON,
	output [3:0] leds,
	output [7:0] PMOD7_8, PMOD9_10
);

`define MULTICYCLE 1
	localparam ABITS=9;

	// hold in reset for a while at power-up while BRAMS initialise
	reg [9:0] resetting = 10'd1000;
	always @(posedge clk_in)
		if (resetting != 0)
			resetting <= resetting - 1;
	wire rst = (~BUTTON[0]) || (resetting != 0);

	reg [20:0] slowclk;
	always @(posedge clk_in)
		slowclk <= slowclk + 1;
`ifdef MULTICYCLE
	// system clock = 50Mhz
	localparam UARTDIV = 50000000 / 9600;
	wire clk = slowclk[0];
`else
	// system clock = 25Mhz
	localparam UARTDIV = 25000000 / 9600;
	wire clk = slowclk[1];
`endif
	wire scanclk = slowclk[15];

	wire memrd, memwr, memwait;
	wire [ABITS-1:0] memaddr;
	wire [15:0] memrdata, memwdata;
	wire [7:0] txdata, rxdata;
	wire txwait, txstart, rxwait, rxstart;
	wire [31:0] acc;
	wire [15:0] iaddr;

	led64 MATRIX (
		.clk(clk),
		.scanclk(scanclk),
		.pmods({PMOD9_10,PMOD7_8}),
		.d({iaddr,16'b0,acc})
	);
	cpu #(.ABITS(ABITS)) TESTCPU (
		.clk(clk),
		.rst(rst),
		.memrd(memrd),
		.memwr(memwr),
		.memwait(memwait),
		.memaddr(memaddr),
		.memrdata(memrdata),
		.memwdata(memwdata),
		.txdata(txdata),
		.rxdata(rxdata),
		.rxwait(rxwait),
		.txwait(txwait),
		.txstart(txstart),
		.rxstart(rxstart),
		.iaddrout(iaddr),
		.accout(acc),
	);
	uarttx #(.CLKDIV(UARTDIV)) UTX (
		.clk(clk),
		.rst(rst),
		.d(txdata),
		.start(txstart),
		.tx(TX),
		.wait(txwait)
	);
	uartrx #(.CLKDIV(UARTDIV)) URX (
		.clk(clk),
		.rst(rst),
		.start(rxstart),
		.q(rxdata),
		.wait(rxwait),
		.rx(RX)
	);
	mem #(.ABITS(ABITS)) MEM (
		.clk(clk),
		.rd(memrd),
		.wr(memwr),
		.wait(memwait),
		.addr(memaddr),
		.d(memwdata),
		.q(memrdata)
	);
endmodule
