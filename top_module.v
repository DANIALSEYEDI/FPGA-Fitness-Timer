module top_module (
    input clk,          // System clock (e.g., 50 MHz). This should be connected to FPGA pin p 184
    input rst,          // Reset
    input [15:0] bcd_data,   // 4-digit BCD input (4 digits * 4 bits)
    //Each digit is 4 bits. For example, if you want to display "1234", bcd_data would be 16'b0001001000110100.
    output buzzer,       // Buzzer output (connected to FPGA pin P13)
    output [7:0] seg_data,   // 7-segment data output (should be connected to 74AC245SC)
    output [3:0] digit_enable // Digit enable signals (should be connected to ULN2003L)
);

  wire beep_enable;
  wire buzzer_signal;
  wire timer_timeout;

  // Parameters for frequency and duration
  localparam CLK_FREQ = 40000000; // 40 MHz clock = the clock frequency of the FPGA board
  localparam BEEP_FREQ = 1000;    // 1 kHz beep (?)
  //Experiment with different BEEP_FREQ values to find a sound that you like.

  localparam BEEP_DURATION = 1;   // 1 second

    /*
    the volume of the buzzer is determined by the voltage and current supplied by the FPGA pin.
     You might need to add an external transistor driver if the FPGA pin can't supply enough current.
      Be careful not to exceed the maximum current rating of the FPGA pin.
    */
  // Calculate clock cycles for frequency and duration
  localparam FREQUENCY_SELECT = CLK_FREQ / BEEP_FREQ;
  //The FREQUENCY_SELECT calculation ensures that the correct number of clock cycles are used for the desired frequency.
  localparam DURATION_CYCLES = CLK_FREQ * BEEP_DURATION;
  //not sure how these calculations are done yet.

  // Timer instantiation
  timer beep_timer (
      .clk(clk),
      .rst(rst),
      .enable(1), // Always enabled
      .duration(DURATION_CYCLES),
      .timeout(timer_timeout)
  );

  // Frequency generator instantiation
  frequency_generator freq_gen (//for generating the sqauare wave for the buzzer
      .clk(clk),
      .enable(beep_enable),
      .frequency_select(FREQUENCY_SELECT),
      .buzzer_signal(buzzer_signal)
  );

  //Assign beep_enable based on timer
  assign beep_enable = ~timer_timeout;

  // Assign buzzer output to FPGA pin
  assign buzzer = buzzer_signal;

// This is the top-level module that connects everything together.
//It instantiates the timer and frequency_generator modules.
//It calculates the appropriate FREQUENCY_SELECT and DURATION_CYCLES based on your desired beep frequency and duration.
//It connects the timer_timeout signal to the enable input of the frequency_generator, so the beep turns on and off according to the timer.
//It assigns the buzzer_signal to the buzzer output, which should be connected to the FPGA pin P13 in your constraints file.

  // Parameters for 7 segment display
  localparam NUM_DIGITS = 4;
  localparam DIGIT_SEL_BITS = 2; // log2(NUM_DIGITS)

  // Internal signals for 7 segment display
  reg [DIGIT_SEL_BITS - 1:0] digit_sel;
  wire [3:0] current_digit_bcd;
  wire [7:0] current_seg_data;

  // Instantiate the BCD to 7-segment decoder
  bcd2seven_seg bcd_decoder (
      .a(current_digit_bcd),
      .SEG_DATA(current_seg_data)
  );

  // Multiplexing logic for 7 segment display
  always @(posedge clk) begin
    if (rst) begin
      digit_sel <= 0;
    end else begin
      digit_sel <= digit_sel + 1;
    end
  end

  // Select the current digit's BCD value
  assign current_digit_bcd = bcd_data[(digit_sel * 4) +: 4]; // Select 4 bits starting from digit_sel * 4
  //current_digit_bcd is The 4-bit BCD value for the currently selected digit.
  
  // Assign the 7-segment data output
  assign seg_data = current_seg_data;
  //current_seg_data is The 7-segment data for the currently selected digit.

  // Digit enable logic (common cathode)
  always @* begin
    case (digit_sel)
    //digit_sel is A 2-bit counter that selects which digit to display.
      2'b00: digit_enable = 4'b1110; // Enable digit 0
      2'b01: digit_enable = 4'b1101; // Enable digit 1
      2'b10: digit_enable = 4'b1011; // Enable digit 2
      2'b11: digit_enable = 4'b0111; // Enable digit 3
      default: digit_enable = 4'b1111; // Disable all digits
    endcase
  end

endmodule