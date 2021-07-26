// https://github.com/im-tomu/fomu-workshop/blob/master/hdl/verilog/blink/blink.v
// Simple tri-colour LED blink example.

// assuming production board! 
`define GREENPWM RGB0PWM
`define REDPWM   RGB1PWM
`define BLUEPWM  RGB2PWM

module serialTalker (
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

    /*// Configure user pins so that we can detect the user connecting
    // 1-2 or 3-4 with conductive material.
    assign user_2 = 1'b0;
    assign user_3 = 1'b0;
*/

    // Connect to system clock (with buffering)
    wire clk;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk)
    );
    
    parameter numColumns = 128;

    reg [31:0] counter = 32'b0;
    reg [3:0] txstatecounter = 4'b0;
    reg [7:0] currentdatatosend = 8'b0;
    reg [numColumns - 1:0] numbertosend = 0;

    reg [numColumns - 1:0] n1 = 0;
    reg [numColumns - 1:0] n2 = 1;

    // please remember to change this !
    reg [10:0] currentColumn = numColumns;

    reg [0:0] state = 1'b0;

    always @ (posedge clk) begin
        // about 9600 baud
        // 48,000,000 / 9600 = every 5000 clock cycles
        if (counter == 5000 ) begin

            if (currentColumn == 0) begin
                currentdatatosend[7:0] <= "\n";
            end else begin            
                currentdatatosend[7:0] <= "0" + numbertosend[currentColumn - 1];
            end
            // 1 start bit, 8 data bits, 1 stop bit

            case(txstatecounter) 
                4'b0000: state <= 1'b0;                  // start bit - pulled low
                4'b0001: state <= currentdatatosend[0];  // bit 0
                4'b0010: state <= currentdatatosend[1];  // bit 1
                4'b0011: state <= currentdatatosend[2];  // bit 2
                4'b0100: state <= currentdatatosend[3];  // bit 3
                4'b0101: state <= currentdatatosend[4];  // bit 4
                4'b0110: state <= currentdatatosend[5];  // bit 5
                4'b0111: state <= currentdatatosend[6];  // bit 6
                4'b1000: state <= currentdatatosend[7];  // bit 7
                4'b1001: state <= 1'b1;                  // stop bit - pulled high
            endcase
            // final bit of UART, need to wrap around again
            if (txstatecounter == 4'b1001 ) begin
                txstatecounter <= 0;
                
                // finished sending current number
                if (currentColumn == 0) begin
                    currentColumn <= numColumns;

                    // next number logic
                    n2 <= n2 + n1;
                    n1 <= n2;

                    numbertosend <= n2;
                end else begin
                    currentColumn <= currentColumn - 1;
                end
            end else begin
                // keep sending current UART frame
                txstatecounter <= txstatecounter + 1; // how far in current UART frame
            end
            
            // this is where the message gets send out
            user_2 <= state;

            counter = 0;
        end 

        counter = counter + 1;
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
        .`BLUEPWM(state),     // Blue
        .`REDPWM(counter[24]),      // Red
        .`GREENPWM(counter[23]),    // Green
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );

endmodule
