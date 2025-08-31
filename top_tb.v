`timescale 1ns/1ps
module tb_top_module;

    // Inputs
    reg clk;
    reg rst;
    reg [8:0] switches;
    reg btn_start, btn_skip, btn_reset;

    // Outputs
    wire buzzer;
    wire [7:0] seg_data;
    wire [3:0] digit_enable;
    // LCD outputs
    wire RS, RW, E;
    wire [7:4] lcd_data;

    // Instantiate DUT
    top_module uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .btn_start(btn_start),
        .btn_skip(btn_skip),
        .btn_reset(btn_reset),
        .buzzer(buzzer),
        .seg_data(seg_data),
        .digit_enable(digit_enable),
        .RS(RS), .RW(RW), .E(E), .lcd_data(lcd_data)
    );

    // Clock generation: 40MHz (25ns period)
    initial clk = 0;
    always #12.5 clk = ~clk;

    // Test procedure
    initial begin
        // Dump VCD for GTKWave
        $dumpfile("tb_top_module.vcd");
        $dumpvars(0, tb_top_module);

        // Init
        rst = 1;
        switches = 8'b00001010; // e.g., T=5 (arbitrary input for minutes)
        btn_start = 0;
        btn_skip  = 0;
        btn_reset = 0;

        // Hold reset
        #100;
        rst = 0;

        // Press START
        #200;
        btn_start = 1; #50; btn_start = 0;

        // Let system run for some time
        #200000;

        // Press SKIP mid-way
        btn_skip = 1; #50; btn_skip = 0;

        #100000;

        // Press RESET
        btn_reset = 1; #50; btn_reset = 0;

        #100000;

        $display("Simulation finished.");
        $finish;
    end

endmodule
