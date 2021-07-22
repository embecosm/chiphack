// https://github.com/im-tomu/fomu-workshop/blob/master/hdl/verilog/blink/blink.v
// Simple tri-colour LED blink example.

// assuming production board! 
`define GREENPWM RGB0PWM
`define REDPWM   RGB1PWM
`define BLUEPWM  RGB2PWM

module top (
    // 48MHz Clock input
    // --------
    input clki,
    // User touchable pins
    // touch 1 
    input  user_1,
    output user_2,
    // touch 2
    output user_3,
    input  user_4,
    // LED outputs
    // --------
    output rgb0,
    output rgb1,
    output rgb2,
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

    // Configure user pins so that we can detect the user connecting
    // 1-2 or 3-4 with conductive material.
    assign user_2 = 1'b0;
    assign user_3 = 1'b0;

    // Connect to system clock (with buffering)
    wire clk;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk)
    );

    // Use counter logic to divide system clock.  The clock is 48 MHz,
    // so we divide it down by 2^28.
    reg [28:0] counter = 0;
    // reg [8*11:0 ] message = "I LOVE FOMU";
    parameter MESSAGELENGTH = 11;
    reg [8*MESSAGELENGTH:0 ] message = "ABABABABABA";
    reg [4:0] characterIndex = MESSAGELENGTH;
    reg [2:0] state = 0;


    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 12_000_000) begin
            case (message[8*characterIndex: 8*(characterIndex-1)])
                "A": state <= 3'b100; // red
                "B": state <= 3'b010; // greeb
                "C": state <= 3'b001; // blue
                default: state <= 3'b111; // white. everything is wrong
            endcase 
            // MSB first so we must count backwards! 
            characterIndex <= characterIndex -1;
            if (characterIndex == 0) begin 
                characterIndex <= MESSAGELENGTH;
            end
            counter <= 0;
            
        end
    end
    // Instantiate iCE40 LED driver hard logic, connecting up
    // counter state and LEDs.
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
        .`BLUEPWM(state[0]),     // Blue
        .`REDPWM(state[2]),      // Red
        .`GREENPWM(state[1]),    // Green
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );

endmodule
