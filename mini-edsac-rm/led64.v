module led64 (
	input clk,
	input scanclk,
	inout [15:0] pmods,
	input [63:0] d
);

	wire [15:0] pins, enable_pins;
	SB_IO #(
		.PIN_TYPE(6'b101001),
		.PULLUP(1'b0),
	) tristate[15:0] (
		.PACKAGE_PIN(pmods[15:0]),
		.OUTPUT_ENABLE(enable_pins[15:0]),
		.D_OUT_0(pins[15:0]),
	);

	wire [15:0] set, clr;
	assign enable_pins = set | clr;
	assign pins        = set;

	wire [8:1] row, col;
	assign set[15:0] = {
		col[3], col[2], 1'b0, 1'b0,
		col[1], 1'b0, col[7], col[8],
		1'b0, col[4], col[6], 1'b0,
		1'b0, 1'b0, 1'b0, col[5]
	};
	assign clr[15:0] = {
		1'b0, 1'b0, row[7], row[5],
		1'b0, row[2], 1'b0, 1'b0,
		row[1], 1'b0, 1'b0, row[8],
		row[4], row[3], row[6], 1'b0
	};
	reg [7:0] rowscan = 8'b10000000;
	reg [63:0] pix;

	reg [1:0] sc;
	always @(posedge clk)
		sc <= {sc[0],scanclk};
	wire sc_rising = sc == 2'b01;
	wire sc_falling = sc == 2'b10;
	always @(posedge clk) begin
		if (sc_rising) begin
			if (rowscan == 8'b10000000)
				pix <= d;
			else
				pix <= pix << 8;
			rowscan <= {rowscan[6:0],rowscan[7]};
		end
	end
	assign row[8:1] = rowscan[7:0];
	integer c;
	always @*
		for (c = 0; c < 8; c = c + 1)
			col[8-c] = pix[56+c];
endmodule
