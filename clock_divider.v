// ============================================================
//The FPGA runs on a very fast 40MHz clock. This module divides that high frequency down to more useful frequencies
// needed by other parts of the system:
//1Hz: For the main timer to count seconds.
//500Hz: For refreshing the 7-segment display without flickering.
//2kHz: For driving the buzzer to make a sound.
// ============================================================

module clock_divider (
    input  wire clk_in,     // 40MHz input clock from FPGA 
    input  wire reset,      // async reset
    output reg clk_1Hz,     // 1Hz clock for timer that counts seconds
    output reg clk_500Hz,   // 500Hz for 7-seg
    output reg clk_1kHz,    // 1kHz optional
    output reg clk_2kHz     // 2kHz for buzzer
);

    // Counters
    reg [24:0] count_1Hz;     // needs up to 20M
    /*
    This register is used to count up to approximately 20 million (20,000,000) clock cycles
     of the input clock (clk_in) to generate the 1 Hz clock signal.
      Because the input clock is 40 MHz, it takes 20,000,000 cycles to represent 1 second.
      1 Hz: To generate a 1 Hz clock from a 40 MHz clock,
       you need to divide the frequency by 40,000,000.
        Since the clock is toggled (high for half the period, low for the other half),
         the counter only needs to count to 40,000,000 / 2 = 20,000,000.
      the same also applies to the other registers below.
      The code subtracts 1 from these values (>= 20000000-1, etc.) in the always block.
       This is a common practice in Verilog to ensure the correct timing of the output clock signals.
    */
    reg [15:0] count_500Hz;   // needs up to 40k
    reg [15:0] count_1kHz;    // needs up to 20k
    reg [15:0] count_2kHz;    // needs up to 10k
    /*
    These are comments explaining the maximum count value each register needs to reach
     to generate the desired clock frequency.
     The "k" stands for thousand, and "M" stands for million.
    */
    always @(posedge clk_in or posedge reset) begin //shouldn't reset always be negedge?
        if (reset) begin
            clk_1Hz   <= 0;
            clk_500Hz <= 0;
            clk_1kHz  <= 0;
            clk_2kHz  <= 0;
            count_1Hz   <= 0;
            count_500Hz <= 0;
            count_1kHz  <= 0;
            count_2kHz  <= 0;
        end else begin
            // 1Hz clock
            if (count_1Hz >= 20000000-1) begin
                clk_1Hz <= ~clk_1Hz;
                count_1Hz <= 0;
            end else
                count_1Hz <= count_1Hz + 1;

            // 500Hz clock
            if (count_500Hz >= 40000-1) begin
                clk_500Hz <= ~clk_500Hz;
                count_500Hz <= 0;
            end else
                count_500Hz <= count_500Hz + 1;

            // 1kHz clock
            if (count_1kHz >= 20000-1) begin
                clk_1kHz <= ~clk_1kHz;
                count_1kHz <= 0;
            end else
                count_1kHz <= count_1kHz + 1;

            // 2kHz clock
            if (count_2kHz >= 10000-1) begin
                clk_2kHz <= ~clk_2kHz;
                count_2kHz <= 0;
            end else
                count_2kHz <= count_2kHz + 1;
        end
    end

endmodule
