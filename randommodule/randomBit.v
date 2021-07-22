// pseduo random number generator
// you don't need to understand how it works, just how it 
// it fits in with your main project

// http://svn.clifford.at/handicraft/2015/ringosc/ringosc.v
`timescale 1ns / 1ps

module randomBit(
    input CLK, 
    input seed,
    output wire randomt
);  
    reg [30:0] randomEdge;
    reg [30:0] counter = 0;
    reg [30:0] pbrs = 25;

    assign randomt = randomEdge[2];

	always @(posedge CLK) begin
        counter <= counter + 1;
        prbs[30:0] <= {prbs[29:0] , prbs[30]^prbs[27]};
        if (counter[25]) begin
            randomEdge[30:0] <= prbs[30:0];
        end
    end
endmodule
