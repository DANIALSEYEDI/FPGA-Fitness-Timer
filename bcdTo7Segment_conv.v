module bcd2seven_seg (
    input  [3:0] a,          // BCD input (0-9)
    output reg [7:0] SEG_DATA // 7-segment output (a-g, dp)
);

  always_comb begin
    case (a)
      4'b0000: SEG_DATA = 8'b11111100; // 0
      4'b0001: SEG_DATA = 8'b01100000; // 1
      4'b0010: SEG_DATA = 8'b11011010; // 2
      4'b0011: SEG_DATA = 8'b11110010; // 3
      4'b0100: SEG_DATA = 8'b01100110; // 4
      4'b0101: SEG_DATA = 8'b10110110; // 5
      4'b0110: SEG_DATA = 8'b10111110; // 6
      4'b0111: SEG_DATA = 8'b11100000; // 7
      4'b1000: SEG_DATA = 8'b11111110; // 8
      4'b1001: SEG_DATA = 8'b11110110; // 9
      default: SEG_DATA = 8'b00000000; // Invalid input (all segments off)
    endcase
  end
    //this Converts a 4-bit BCD value to the corresponding 7-segment pattern.
    /*
    The output SEG_DATA corresponds to the segments a-g, dp (decimal point). The bit order in the SEG_DATA assignment is important and must match the physical connection of your display. The corrected code handles digits 0-9.
    */
endmodule