`timescale 1ns / 1ps

module top_tb;

// Declare inputs to the top module
reg [7:0] W;      // Weight (8 bits for example)
reg [7:0] Cal;    // Calories (8 bits for example)
reg [3:0] MET;    // MET values (4 bits)
reg G;            // Gender (1 bit)

// Declare outputs from the top module
wire [7:0] T;     // Time (in minutes)
wire [3:0] workout_num; // Current workout number
wire [6:0] seg_display; // Segment display for remaining time
wire buzzer_signal; // Signal for the buzzer

// Instantiate the top-level module
top_module uut (
    .W(W),
    .Cal(Cal),
    .MET(MET),
    .G(G),
    .T(T),
    .workout_num(workout_num),
    .seg_display(seg_display),
    .buzzer_signal(buzzer_signal)
	 
);

// Clock signal for driving simulation
reg clk;
initial clk = 0;
always #5 clk = ~clk;  // 10 ns period (100 MHz)

// Countdown counter
reg [7:0] countdown_time;  // 8-bit register to hold countdown time

initial begin
    // Display header for the simulation
    $display("Starting simulation with countdown for each test case...\n");

    // Test Case 1 - Countdown from 45 seconds
    #10;
    W = 8'b00000100;   // Example: Weight = 4 kg
    Cal = 8'b00000100; // Example: Calories = 4
    MET = 4'b0001;     // Example: MET = 1
    G = 1'b0;          // Example: Gender = Male (0)

    // Set countdown to 45 seconds
    countdown_time = 45;
    $display("Test Case 1: W = %b, Cal = %b, MET = %b, G = %b => Starting countdown from %d seconds", W, Cal, MET, G, countdown_time);

    // Countdown loop (every clock cycle decreases the time)
    while (countdown_time > 0) begin
        #10;  // Wait for next clock cycle (simulate 10ns)
        countdown_time = countdown_time - 1;
        $display("Time Remaining: %d seconds, Buzzer: %b", countdown_time, buzzer_signal);
    end
    $display("Test Case 1: Countdown complete.\n");

    // Test Case 2 - Countdown from 15 seconds
    #10;
    W = 8'b00000110;   // Example: Weight = 6 kg
    Cal = 8'b00000011; // Example: Calories = 3
    MET = 4'b0010;     // Example: MET = 2
    G = 1'b1;          // Example: Gender = Female (1)

    // Set countdown to 15 seconds
    countdown_time = 15;
    $display("Test Case 2: W = %b, Cal = %b, MET = %b, G = %b => Starting countdown from %d seconds", W, Cal, MET, G, countdown_time);

    // Countdown loop (every clock cycle decreases the time)
    while (countdown_time > 0) begin
        #10;  // Wait for next clock cycle (simulate 10ns)
        countdown_time = countdown_time - 1;
        $display("Time Remaining: %d seconds, Buzzer: %b", countdown_time, buzzer_signal);
    end
    $display("Test Case 2: Countdown complete.\n");

    // Test Case 3 - Countdown from 45 seconds
    #10;
    W = 3'b001;   // Example: Weight = 8 kg
    Cal = 2'b01; // Example: Calories = 1
    MET = 2'b10;     // Example: MET = 4
    G = 1'b1;          // Example: Gender = Male (0)

    // Set countdown to 45 seconds
    countdown_time = 45;
    $display("Test Case 3: W = %b, Cal = %b, MET = %b, G = %b => Starting countdown from %d seconds", W, Cal, MET, G, countdown_time);

    // Countdown loop (every clock cycle decreases the time)
    while (countdown_time > 0) begin
        #10;  // Wait for next clock cycle (simulate 10ns)
        countdown_time = countdown_time - 1;
        $display("Time Remaining: %d seconds, Buzzer: %b", countdown_time, buzzer_signal);
    end
    $display("Test Case 3: Countdown complete.\n");

    // Test Case 4 - Countdown from 15 seconds
    #10;
    W = 8'b00001000;   // Example: Weight = 8 kg
    Cal = 8'b00000111; // Example: Calories = 7
    MET = 4'b1000;     // Example: MET = 8
    G = 1'b1;          // Example: Gender = Female (1)

    // Set countdown to 15 seconds
    countdown_time = 15;
    $display("Test Case 4: W = %b, Cal = %b, MET = %b, G = %b => Starting countdown from %d seconds", W, Cal, MET, G, countdown_time);

    // Countdown loop (every clock cycle decreases the time)
    while (countdown_time > 0) begin
        #10;  // Wait for next clock cycle (simulate 10ns)
        countdown_time = countdown_time - 1;
        $display("Time Remaining: %d seconds, Buzzer: %b", countdown_time, buzzer_signal);
    end
    $display("Test Case 4: Countdown complete.\n");

    // End simulation
    $finish;
end

endmodule
