module frequency_generator (
    input  clk,// System clock, when instantiated in top_module, it should be given a value of 500 
    //to 2000 Hz from the clock_divider module
    input  enable,// Enable signal
    input  [15:0] frequency_select, // Frequency selection (e.g., based on clock cycles)
    output reg buzzer_signal // Output to buzzer. This should be connected to FPGA pin P13
    //when instantiated in top_module
);

  reg [15:0] counter;

  always @(posedge clk) begin
    if (enable) begin
      if (counter < frequency_select/2) begin
        counter <= counter + 1;
        buzzer_signal <= 1;
      end else if (counter < frequency_select) begin
        counter <= counter + 1;
        buzzer_signal <= 0;
      end else begin
        counter <= 0;
      end
    end else begin
      buzzer_signal <= 0;
      counter <= 0;
    end
  end
//this file is generating the sqauare wave for the buzzer
//the frequency is determined by the frequency_select input
//The frequency_select determines how many clock cycles make up one period of the square wave.
// The enable signal allows you to turn the sound on and off.
endmodule