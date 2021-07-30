module button(
    input wire clk,
    input wire pad1,
    output wire pad2,
    output wire buttonStatus
);

    assign pad2 = 1'b0;

    localparam SB_IO_TYPE_SIMPLE_INPUT = 6'b000001;
    SB_IO #(
        .PIN_TYPE(SB_IO_TYPE_SIMPLE_INPUT),
        .PULLUP(1'b1)
    ) buttonIO (
        .PACKAGE_PIN(pad1),
        .OUTPUT_ENABLE(1'b0),
        .INPUT_CLK(clk),
        .D_IN_0(buttonStatus),
    );

endmodule