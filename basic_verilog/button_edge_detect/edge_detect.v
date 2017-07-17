// edge detect module
// Commandeered from Dr. Saar Drimer (https://www.boldport.com/blog/2015/4/3/edge-detect-ad-nauseam)
module edge_detect(
  input  clk,
  input [1:0] buttons,
  output [3:0] led,
  output OUT
  );

  reg a, b;
  reg [3:0] count;

// What on earth is up with this??? /////

  //assign led[3] = buttons[0]; //Works when led[3] is showing something?? but not else?!?
  //assign led[2] = buttons[0];
  assign led[3:0] = count;

//////////////////////////////////////////////

  // the edge detect signal is (b AND (NOT a))
  assign OUT = a & !b;

  always @(posedge clk) begin
    // It's always good to have a reset condition, otherwise
    // the state of the register will show up as undertemined
    // in simulation ('x')
    if (buttons[0] == 1'b1) begin
       a <= 0;
       b <= 0;
     end
     else begin
       a <= buttons[1];
       b <= a;
     end
  end

  // Testing edge detect in module:

  always @(negedge OUT) begin
    count <= count + 1;
  end

endmodule
