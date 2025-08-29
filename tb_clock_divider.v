`timescale 1ns/1ps
module tb_clock_divider;

    reg clk_in = 0, reset = 1;
    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;

    // Instantiate
    clock_divider uut (
        .clk_in(clk_in),
        .reset(reset),
        .clk_1Hz(clk_1Hz),
        .clk_500Hz(clk_500Hz),
        .clk_1kHz(clk_1kHz),
        .clk_2kHz(clk_2kHz)
    );

    // Generate 40MHz clock (25ns period)
    always #12.5 clk_in = ~clk_in;
    //the clock is generated in the FPGA itself and not from an external source
    // , so it is not necessary to simulate it here

    initial begin
        // Reset pulse
        #50 reset = 0;

        // Run simulation for a while
        #1000000 $finish;
    end

endmodule
