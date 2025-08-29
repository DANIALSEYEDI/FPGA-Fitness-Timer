module timer (
    input clk,          // System clock
    input rst,          // Reset
    input enable,       // Start the timer
    input [31:0] duration, // Duration in clock cycles
    output reg timeout      // High when timer expires
);

  reg [31:0] count;

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
      timeout <= 0;
    end else if (enable) begin
      if (count < duration) begin
        count <= count + 1;
        timeout <= 0;
      end else begin
        count <= 0;
        timeout <= 1;
      end
    end else begin
      timeout <= 0;
    end
  end
//This module implements a basic timer.
// It counts clock cycles until it reaches a specified duration, then asserts its timeout output.
endmodule