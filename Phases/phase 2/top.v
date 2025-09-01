//`timescale 1ns/1ps

module top_module (
    input        clk,        // 40 MHz
    input        rst,        // async reset (active-high)
    input  [7:0] switches,   // input switches
    input        btn_skip,   //push button input for workout skip
    input        btn_reset, //push button input for reset
    output [4:0] SEG_SEL, 
    output reg [7:0]SEG_DATA; 
    
);

    // ---------- clock divider ----------
    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;
    clock_divider u_clkdiv (
        .clk_in(clk), .reset(rst),
        .clk_1Hz(clk_1Hz), .clk_500Hz(clk_500Hz),
        .clk_1kHz(clk_1kHz), .clk_2kHz(clk_2kHz)
    );

    // ---------- combinational circuit ----------
    wire [7:0] T_minutes;
    combinational_circuit u_comb (.input_bits(switches), .T3(T_minutes));

    // ---------- debouncers ----------
    wire start_clean,skip_clean, reset_clean;
    debouncer u_db_start  (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_start),  .clean_btn(start_clean));
    debouncer u_db_skip  (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_skip),  .clean_btn(skip_clean));
    debouncer u_db_reset (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_reset), .clean_btn(reset_clean));

    // ---------- FSM ----------
    wire fsm_done;
    wire [1:0] fsm_state;
    wire [7:0] fsm_count;

    workout_fsm u_fsm (
        .clk(clk_1Hz),
        .start(start_clean),
        .skip(skip_clean),
        .reset(reset_clean),
        .T(T_minutes),
        .state_out(fsm_state),
        .done(fsm_done),
        .count(fsm_count)
    );

    //should I put the code for the 7-segments in a 
    //always@(fsm_count) block ?

    // ---------- Binary to BCD conversion ----------
    wire [7:0] bcd_out;
    bin2bcd converter (
        .bin(fsm_count),
        .bcd(bcd_out)
    );

    // ---------- 7-segment display control ----------
    wire [1:0] refresh_counter;
    wire [3:0] bcd_digit;
    
    // Extract BCD digits
    wire [3:0] tens = bcd_out[7:4];
    wire [3:0] ones = bcd_out[3:0];

    refreshCounter refresh_counter_inst (
        .refresh_clock(clk_500Hz),
        .refreshCounter(refresh_counter)
    );

    BCDcontrol bcd_control (
        .digit1(4'd0),         // rightmost digit (always 0)
        .digit2(4'd0),         // second rightmost (always 0)
        .digit3(ones),         // second leftmost (ones digit)
        .digit4(tens),         // leftmost (tens digit)
        .refreshCounter(refresh_counter),
        .one_digit(bcd_digit)
    );

    digit_multiplexer digit_mux (
        .refreshCounter(refresh_counter),
        .SEG_SEL(SEG_SEL)
    );

    bcd2seven_seg bcd_to_7seg (
        .digit(bcd_digit),
        .SEG_DATA(SEG_DATA)
    );

endmodule

module combinational_circuit (
    input  [7:0] input_bits,
    output [7:0] T3
    );

    wire w2 = input_bits[7];
    wire w1 = input_bits[6];
    wire w0 = input_bits[5];
    wire c1 = input_bits[4];
    wire c0 = input_bits[3];
    wire M1 = input_bits[2];
    wire M0 = input_bits[1];
    wire G  = input_bits[0];

    wire [7:0] T1;

    assign T1[0] = (~w2 & ~c1 & c0 & w1 & w0) | (c1 & c0 & w1 & ~w0) | (~w2 & ~c0 & w1 & ~w0) | (w2 & c0 & ~w0) | (w2 & ~c1 & ~w0) | (w2 & ~c0 & w1 & w0);
    assign T1[1] = (~w2 & c0 & w1) | (~w2 & ~c1 & w1) | (~c1 & c0 & w1) | (~c0 & ~w1 & w0) | (w2 & ~c1 & c0 & ~w0) | (w2 & c1 & ~c0 & w1) | (w2 & ~c0 & w1 & ~w0);
    assign T1[2] = (~c1 & c0 & ~w1 & w0) | (c1 & c0 & w1 & w0) | (~c1 & c0 & w1 & ~w0) | (~w2 & c1 & ~c0 & ~w1 ) | (~w2 & ~c0 & ~w1 & ~w0) | (~w2 & ~c1 & ~c0 & w1 & w0) | (w2 & c1 & ~w1 & ~w0) | (w2 & c0 & w1 & ~w0) | (w2 & ~c1 & ~w1 & w0);
    assign T1[3] = (w2 & ~w1 & w0 ) | (w2 & ~c0 & w1 & w0 ) | (c1 & c0 & ~w1 & w0) | (c1 & c0 & w1 & ~w0) | (~c1 & ~c0 & w1 & ~w0) | (~w2 & ~c1 & c0 & w1 & w0) | (~w2 & ~c1 & ~w1 & ~w0);
    assign T1[4] = (~c0 & ~w2 & ~w1) | (~w2 & ~w1 & ~w0) | (~c1 & c0 & w1 & ~w0) | (~c0 & w2 & w1 & ~w0 ) | (c1 & ~w2 & w1 & w0 ) | (~c1 & w2 & w0) | (w2 & ~w1 & w0);
    assign T1[5] = (~c1 & ~c0 & ~w2) | (~w2 & ~w1 & ~w0) | (~c1 & ~w2 & ~w1 ) | (c1 & c0 & ~w2 & ~w0 ) | (c0 & w2 & w1) | (~c0 & w2 & ~w1 & ~w0) | (~c0 & ~w2 & w1 & w0) | (c0 & w2 & w0);
    assign T1[6] = (~c1 & c0 & ~w2) | (~c1 & c0 & ~w1 & ~w0) | (c0 & ~w2 & ~w1) | (c1 & w2 & w1) | (c1 & w2 & w0) | (c1 & ~c0 & w2) | (c1 & ~c0 & w1 & w0);
    assign T1[7] = (c1 & c0 & ~w2) | (c1 & ~w2 & ~w0)  | (c1 & ~w2 & ~w1) | (c1 & c0 & ~w1 & ~w0);

    wire [7:0] T1_shifted = {3'b000, T1[7:3]};
    wire [7:0] T1_woman;
    wire [8:0] carry;
    assign carry[0] = 0;

    full_adder fa0 (.a(T1[0]), .b(T1_shifted[0]), .cin(carry[0]), .sum(T1_woman[0]), .cout(carry[1]));
    full_adder fa1 (.a(T1[1]), .b(T1_shifted[1]), .cin(carry[1]), .sum(T1_woman[1]), .cout(carry[2]));
    full_adder fa2 (.a(T1[2]), .b(T1_shifted[2]), .cin(carry[2]), .sum(T1_woman[2]), .cout(carry[3]));
    full_adder fa3 (.a(T1[3]), .b(T1_shifted[3]), .cin(carry[3]), .sum(T1_woman[3]), .cout(carry[4]));
    full_adder fa4 (.a(T1[4]), .b(T1_shifted[4]), .cin(carry[4]), .sum(T1_woman[4]), .cout(carry[5]));
    full_adder fa5 (.a(T1[5]), .b(T1_shifted[5]), .cin(carry[5]), .sum(T1_woman[5]), .cout(carry[6]));
    full_adder fa6 (.a(T1[6]), .b(T1_shifted[6]), .cin(carry[6]), .sum(T1_woman[6]), .cout(carry[7]));
    full_adder fa7 (.a(T1[7]), .b(T1_shifted[7]), .cin(carry[7]), .sum(T1_woman[7]), .cout(carry[8]));

    wire [7:0] T2;
    assign T2[0] = (~G & T1[0]) | (G & T1_woman[0]);
    assign T2[1] = (~G & T1[1]) | (G & T1_woman[1]);
    assign T2[2] = (~G & T1[2]) | (G & T1_woman[2]);
    assign T2[3] = (~G & T1[3]) | (G & T1_woman[3]);
    assign T2[4] = (~G & T1[4]) | (G & T1_woman[4]);
    assign T2[5] = (~G & T1[5]) | (G & T1_woman[5]);
    assign T2[6] = (~G & T1[6]) | (G & T1_woman[6]);
    assign T2[7] = (~G & T1[7]) | (G & T1_woman[7]);

    wire [7:0] shift0 = T2;
    wire [7:0] shift1 = {1'b0, T2[7:1]};
    wire [7:0] shift2 = {2'b00, T2[7:2]};
    wire [7:0] shift3 = {3'b000, T2[7:3]};

    mux4x1 mux0 (.in0(shift0[0]), .in1(shift1[0]), .in2(shift2[0]), .in3(shift3[0]), .sel({M1, M0}), .out(T3[0]));
    mux4x1 mux1 (.in0(shift0[1]), .in1(shift1[1]), .in2(shift2[1]), .in3(shift3[1]), .sel({M1, M0}), .out(T3[1]));
    mux4x1 mux2 (.in0(shift0[2]), .in1(shift1[2]), .in2(shift2[2]), .in3(shift3[2]), .sel({M1, M0}), .out(T3[2]));
    mux4x1 mux3 (.in0(shift0[3]), .in1(shift1[3]), .in2(shift2[3]), .in3(shift3[3]), .sel({M1, M0}), .out(T3[3]));
    mux4x1 mux4 (.in0(shift0[4]), .in1(shift1[4]), .in2(shift2[4]), .in3(shift3[4]), .sel({M1, M0}), .out(T3[4]));
    mux4x1 mux5 (.in0(shift0[5]), .in1(shift1[5]), .in2(shift2[5]), .in3(shift3[5]), .sel({M1, M0}), .out(T3[5]));
    mux4x1 mux6 (.in0(shift0[6]), .in1(shift1[6]), .in2(shift2[6]), .in3(shift3[6]), .sel({M1, M0}), .out(T3[6]));
    mux4x1 mux7 (.in0(shift0[7]), .in1(shift1[7]), .in2(shift2[7]), .in3(shift3[7]), .sel({M1, M0}), .out(T3[7]));
endmodule

module full_adder (
    input a, b, cin,
    output sum, cout
    );
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module mux4x1 (
    input in0, in1, in2, in3,
    input [1:0] sel,
    output out
    );
    wire n0, n1, s0, s1, s2, s3;
    not (n0, sel[0]);
    not (n1, sel[1]);
    and (s0, n1, n0, in0);
    and (s1, n1, sel[0], in1);
    and (s2, sel[1], n0, in2);
    and (s3, sel[1], sel[0], in3);
    or  (out, s0, s1, s2, s3);
endmodule

module clock_divider (
    input  wire clk_in,     // 40MHz input clock from FPGA 
    input  wire reset,      // async reset
    output reg clk_1Hz,     // 1Hz clock for timer that counts seconds
    output reg clk_500Hz,   // 500Hz for 7-seg
    output reg clk_1kHz,    // 1kHz optional
    output reg clk_2kHz     // 2kHz for buzzer
    );

    reg [24:0] count_1Hz;  
    reg [15:0] count_500Hz; 
    reg [15:0] count_1kHz;  
    reg [15:0] count_2kHz; 
    
    always @(posedge clk_in or negedge reset) begin //shouldn't reset always be negedge?
        if (~reset) begin
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

module bcd2seven_seg ( 
    input [3:0]digit, 
    output reg [7:0]SEG_DATA = 0
    ); 
    
    always @(digit)
        begin 
            case(digit) 
            4'd0:SEG_DATA = 8'b11000000; 
            4'd1:SEG_DATA = 8'b11111001; 
            4'd2:SEG_DATA = 8'b10100100; 
            4'd3:SEG_DATA = 8'b10110000; 
            4'd4:SEG_DATA = 8'b10011001; 
            4'd5:SEG_DATA = 8'b10010010; 
            4'd6:SEG_DATA = 8'b10000010; 
            4'd7:SEG_DATA = 8'b11111000; 
            4'd8:SEG_DATA = 8'b10000000;
            4'd9:SEG_DATA = 8'b10010000; 
            default: SEG_DATA = 8'b11000000; //turn off all segments
            endcase 
        end 
endmodule 

module BCDcontrol (
    input [3:0] digit1,//mpst right digit
    input [3:0] digit2,
    input [3:0] digit3,
    input [3:0] digit4,//mpst left digit
    input refreshCounter,
    output reg [3:0] one_digit = 0// digit to be displayed
    );

    always @(refreshCounter) begin
        case (refreshCounter)
            2'd0: one_digit = digit1; //digit 1 value (rightmost)
            2'd1: one_digit = digit2;
            2'd2: one_digit = digit3;
            2'd3: one_digit = digit4; //digit 4 value (leftmost)
        endcase
    end
endmodule

module refreshCounter (
    input refresh_clock,
    output reg [1:0] refreshCounter = 0
    );

    always @(posedge refresh_clock) refreshCounter <= refreshCounter + 1;
endmodule

module digit_multiplexer (
    input [1:0] refreshCounter,
    output reg [4:0] SEG_SEL = 0
    );

    always @(refreshCounter) begin
        case (refreshCounter)
            2'd0: SEG_SEL = 5'b11110; //activate digit 1 (rightmost)
            2'd1: SEG_SEL = 5'b11101;
            2'd2: SEG_SEL = 5'b11011;
            2'd3: SEG_SEL = 5'b10111; //activate digit 4 (leftmost)
            default: SEG_SEL = 5'b01111; //turn off all digits
        endcase
    end
endmodule

module bin2bcd (
    input [7:0] bin,
    output reg [7:0] bcd
    );

    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;
    integer i;

    always @(bin) begin
        // Clear all values
        hundreds = 4'd0;
        tens = 4'd0;
        ones = 4'd0;

        // Double dabble algorithm
        for (i = 7; i >= 0; i = i - 1) begin
            // Add 3 to columns >= 5
            if (hundreds >= 5)
                hundreds = hundreds + 3;
            if (tens >= 5)
                tens = tens + 3;
            if (ones >= 5)
                ones = ones + 3;

            // Shift left one
            hundreds = hundreds << 1;
            hundreds[0] = tens[3];
            tens = tens << 1;
            tens[0] = ones[3];
            ones = ones << 1;
            ones[0] = bin[i];
        end

        // Combine the BCD digits
        bcd = {tens, ones};  // Since number is < 100, we only need tens and ones
    end
endmodule

module debouncer (
    input  clk,        
    input  rst,        
    input  noisy_btn, 
    //this module will be instantiated 3 times for 3 different buttons
    output clean_btn   
    );

    reg d1, d2, d3;

   //according to what Mahan said , shouldn't this be negedge clk ?
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 0;
            d2 <= 0;
            d3 <= 0;
            //again according to Mahan , shouldn't these be set to 1 initially ?
        end else begin
            d1 <= noisy_btn;
            d2 <= d1;
            d3 <= d2;
        end
    end

    assign clean_btn = d1 & d2 & d3;
endmodule

module workout_fsm(
    input clk,          // 1Hz clock
    input start,
    input skip,
    input reset,
    input [7:0] T,      // from combinational circuit
    output reg [1:0] state_out,
    output reg done,
    output reg [7:0] count
    );

    //FSM state declaration
    localparam IDLE    = 2'b00;
    localparam WORKOUT = 2'b01;
    localparam REST    = 2'b10;
    localparam FINISH  = 2'b11;

    reg [1:0] current_state, next_state;
    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = WORKOUT;
                else
                    next_state = IDLE;
            end
            WORKOUT: begin
                if (reset)
                    next_state = IDLE;
                else if (skip)
                    next_state = (count > 1) ? REST : FINISH;
                else
                    next_state = WORKOUT;
            end
            REST: begin
                if (reset)
                    next_state = IDLE;
                else if (time_done)
                    next_state = WORKOUT;
                else
                    next_state = REST;
            end
            FINISH: begin
                if (reset)
                    next_state = IDLE;
                else
                    next_state = FINISH;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sequential state + counter update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            count <= T;
        end else begin
            current_state <= next_state;
            if (current_state == WORKOUT && skip && count > 0)
                count <= count - 1;
        end
    end

    // Output logic
    always @(*) begin
        // defaults
        done = 0;
        state_out = current_state;

        case (current_state)
            FINISH: begin
                done = 1;
            end
        endcase
    end
endmodule