// Button example.
// modified from https://github.com/im-tomu/fomu-workshop/blob/master/hdl/verilog/blink-expanded/blink.v

// assuming production board! 
`define GREENPWM RGB0PWM
`define REDPWM   RGB1PWM
`define BLUEPWM  RGB2PWM

`include "button.v"

module blink (
    // 48MHz Clock input
    // --------
    input clki,
    // LED outputs
    // --------
    output rgb0,
    output rgb1,
    output rgb2,
    // User touchable pins
    // --------
    // Connect 1-2 to enable blue LED
    input  user_1,
    output user_2,
    // Connect 3-4 to enable red LED
    output user_3,
    input  user_4,
    // USB Pins (which should be statically driven if not being used).
    // --------
    output usb_dp,
    output usb_dn,
    output usb_dp_pu
);

    // Assign USB pins to "0" so as to disconnect Fomu from
    // the host system.  Otherwise it would try to talk to
    // us over USB, which wouldn't work since we have no stack.
    assign usb_dp = 1'b0;
    assign usb_dn = 1'b0;
    assign usb_dp_pu = 1'b0;

    // Connect to system clock (with buffering)
    wire clk;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk)
    );

    // Configure user pins so that we can detect the user connecting
    // 1-2 or 3-4 with conductive material.
    //
    // We do this by grounding user_2 and user_3, and configuring inputs
    // with pullups on user_1 and user_4.
    wire user_1_pulled;
    wire user_4_pulled;
    button leftButton(.clk(clk), .pad1(user_1), .pad2(user_2), .buttonStatus(user_1_pulled));
    button rightButton(.clk(clk), .pad1(user_4), .pad2(user_3), .buttonStatus(user_4_pulled));

    // the user inputs are inverted as they go low when pressed! 
    // sum (A xor B)
    wire enable_blue = (~user_1_pulled) ^ (~user_4_pulled); 
    // carry (A and B)
    wire enable_red  = (~user_1_pulled) && (~user_4_pulled);

    // Use counter logic to divide system clock.  The clock is 48 MHz,
    // so we divide it down by 2^28.
    reg [28:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
    end

    // Instantiate iCE40 LED driver hard logic, connecting up
    // latched button state, counter state, and LEDs.
    //
    // Note that it's possible to drive the LEDs directly,
    // however that is not current-limited and results in
    // overvolting the red LED.
    //
    // See also:
    // https://www.latticesemi.com/-/media/LatticeSemi/Documents/ApplicationNotes/IK/ICE40LEDDriverUsageGuide.ashx?document_id=50668
    SB_RGBA_DRV #(
        .CURRENT_MODE("0b1"),       // half current
        .RGB0_CURRENT("0b000011"),  // 4 mA
        .RGB1_CURRENT("0b000011"),  // 4 mA
        .RGB2_CURRENT("0b000011")   // 4 mA
    ) RGBA_DRIVER (
        .CURREN(1'b1),
        .RGBLEDEN(1'b1),
        .`BLUEPWM(enable_blue),     // Blue
        .`REDPWM(enable_red),      // Red
        .`GREENPWM(0),    // Green
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );
endmodule
