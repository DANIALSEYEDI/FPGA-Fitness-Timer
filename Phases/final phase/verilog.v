`timescale 1ns/1ps

`define SYS_CLK 50_000_000

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

module bin2bcd(
    input [8:0] binary,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
     );
    integer i;
    reg [11:0] bcd;
    always @(*) begin
        bcd = 0;
        for (i = 8; i >= 0; i = i - 1) begin
            if (bcd[3:0] >= 5) bcd = bcd + 12'd3;
            if (bcd[7:4] >= 5) bcd = bcd + 12'd48;
            if (bcd[11:8] >= 5) bcd = bcd + 12'd768;
            bcd = {bcd[10:0], binary[i]};
        end
        hundreds = bcd[11:8];
        tens = bcd[7:4];
        ones = bcd[3:0];
    end
endmodule

module clk_en_gen #(parameter DIVIDER = `SYS_CLK)(
    input clk,
    input reset_n,
    output reg clk_en
     );
    reg [31:0] ctr;
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            ctr <= 0;
            clk_en <= 0;
        end else begin
            if (ctr == DIVIDER - 1) begin
                ctr <= 0;
                clk_en <= 1;
            end else begin
                ctr <= ctr + 1;
                clk_en <= 0;
            end
        end
    end
endmodule

module DebounceLevel #(parameter integer STABLE_COUNT=250000)( // Adjusted for 50MHz
    input clk, rst, din, output reg dout
     );
    reg [31:0] cnt; reg stable;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt<=0;
            stable<=1'b1;
            dout<=1'b1;
        end else begin
            if (din==stable)
                cnt<=0;
            else if (cnt==STABLE_COUNT) begin
                stable<=din;
                dout<=din;
                cnt<=0;
            end
            else
                cnt<=cnt+1;
        end
    end
endmodule

// New debouncer module
module debouncer(
    input clk,
    input rst, // Assumes active-high reset
    input noisy_btn,
    output reg clean_btn
    );
    
    reg bit0;
    reg bit1;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            bit0 <= 1'b1;
            bit1 <= 1'b1;
            clean_btn <= 1'b1;
        end else begin
            bit0 <= noisy_btn;
            bit1 <= bit0;
            clean_btn <= bit1 & bit0;
        end
    end
endmodule

// Modified ButtonCond to use the new debouncer
module ButtonCond #(parameter ACTIVE_LOW=1)(
    input  clk,
    input rst,
    input btn_in,
    output reg press
     );
    wire lvl_raw;
    // Using the new debouncer module
    debouncer udb (
        .clk(clk), 
        .rst(rst), 
        .noisy_btn(btn_in), 
        .clean_btn(lvl_raw)
    );
    wire lvl_norm = ACTIVE_LOW ? ~lvl_raw : lvl_raw;
    reg  prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev<=1'b0;
            press<=1'b0;
        end else begin
            press <= (lvl_norm & ~prev);
            prev <= lvl_norm;
        end
    end
endmodule

module fsm_core_logic(
    input clk,
    input reset_n,
    input start_edge,
    input skip_edge,
    input reset_edge,
    input clk_en_rising,
    input [8:0] total_count_in,
    output reg [1:0] state = 2'b00,
    output reg [5:0] timer = 6'b101101,
    output reg [7:0] curr_idx = 0,
    output reg buz_pulse = 1'b0,
    output reg buz_mode = 0
    );
    localparam IDLE = 2'b00, EXERCISE = 2'b01, REST = 2'b10;
    
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            state        <= IDLE;
            timer        <= 6'b101101;
            curr_idx     <= 0;
            buz_pulse    <= 1'b1;
            buz_mode     <= 1'b0;
        end else begin
            buz_pulse <= 1'b0;
            if (reset_edge) begin // Global reset condition
                state <= IDLE;
                curr_idx <= 0;
            end else begin
                case (state)
                    IDLE: begin
                        timer        <= 6'b101101;
                        // curr_idx is 0, so display shows total_workouts
                        if (start_edge && total_count_in > 0) begin
                            curr_idx     <= total_count_in; // Start counting down from the total
                            state        <= EXERCISE;
                        end
                    end
                    EXERCISE: begin
                        if (skip_edge) begin
                            // Skip to the next exercise, or end if it's the last one
                            if (curr_idx > 1)
                                curr_idx <= curr_idx - 1;
                            else
                                state <= IDLE;
                            timer     <= 6'b101101;
                            buz_pulse <= 1'b1;
                        end else if (clk_en_rising) begin
                            if (timer == 1) begin
                                state     <= REST;
                                timer     <= 6'b001111;
                                buz_pulse <= 1'b1;
                            end else if (timer != 0) begin
                                timer <= timer - 1;
                            end
                        end
                    end
                          
                    REST: begin
                        if (skip_edge) begin
                            // Skip rest and go to next exercise, or end if it's the last one
                            if (curr_idx > 1)
                                curr_idx <= curr_idx - 1;
                            else
                                state <= IDLE;
                            state     <= EXERCISE;
                            timer     <= 6'b101101;
                            buz_pulse <= 1'b1;
                        end else if (clk_en_rising) begin
                            if (timer == 1) begin
                                // A full cycle is complete, decrement workout count
                                if (curr_idx <= 1) begin // This was the last workout
                                    state     <= IDLE;
                                    curr_idx  <= 0;
                                    buz_pulse <= 1'b1;
                                    buz_mode  <= 1'b1;
                                end else begin
                                    curr_idx  <= curr_idx - 1; // Decrement workout count
                                    state     <= EXERCISE;
                                    timer     <= 6'b101101;
                                    buz_pulse <= 1'b1;
                                end
                            end else if (timer != 0) {
                                timer <= timer - 1;
                            }
                        end
                    end
                endcase
            end
        end
    end
endmodule

module workout_fsm(
    input start_btn,
    input skip_btn,
    input reset_btn,
    input clk,
    input [8:0] total_count_in,
    output [1:0] state,
    output [5:0] timer,
    output [7:0] curr_idx,
    output buz_pulse,
    output buz_mode
     );
    wire start_edge, skip_edge, reset_edge;
    wire clk_out;
    // Note: STABLE_COUNT parameter is no longer used by the new ButtonCond
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_start (.clk(clk), .rst(~reset_btn), .btn_in(start_btn), .press(start_edge));
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_skip  (.clk(clk), .rst(~reset_btn), .btn_in(skip_btn),  .press(skip_edge));
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_reset (.clk(clk), .rst(~reset_btn), .btn_in(reset_btn), .press(reset_edge));
        
    clk_en_gen #(.DIVIDER(`SYS_CLK)) clkgen (
        .clk(clk),
        .reset_n(reset_btn),
        .clk_en(clk_out)
    );
     
    fsm_core_logic fcl (
        .clk(clk),
        .reset_n(reset_btn),
        .start_edge(start_edge),
        .skip_edge(skip_edge),
        .reset_edge(reset_edge),
        .clk_en_rising(clk_out),
        .total_count_in(total_count_in),
        .state(state),
        .timer(timer),
        .curr_idx(curr_idx),
        .buz_pulse(buz_pulse),
        .buz_mode(buz_mode)
    );
endmodule

module seg_driver(
    input [3:0] digit,
    output reg [7:0] seg_out
    );
    
    always @(*) begin
        case (digit)
            4'd0: seg_out = 8'b00111111;
            4'd1: seg_out = 8'b00000110;
            4'd2: seg_out = 8'b01011011;
            4'd3: seg_out = 8'b01001111;
            4'd4: seg_out = 8'b01100110;
            4'd5: seg_out = 8'b01101101;
            4'd6: seg_out = 8'b01111101;
            4'd7: seg_out = 8'b00000111;
            4'd8: seg_out = 8'b01111111;
            4'd9: seg_out = 8'b01101111;
            default: seg_out = 8'b00000000;
        endcase
    end
endmodule

module seg_multiplexer(
    input clk,
    input reset_n,
    input [8:0] show_value,
    input [5:0] timer,
    output reg [4:0] sel = 5'b00001,
    output reg [3:0] digit
    );
    reg [18:0] counter = 0;
    wire clk_tick = (counter == 100000 - 1);
    wire [3:0] t_h, t_t, t_o;
    bin2bcd timer_bcd(.binary({3'b0, timer}), .hundreds(t_h), .tens(t_t), .ones(t_o));
    wire [3:0] v_h, v_t, v_o;
    bin2bcd value_bcd(.binary(show_value), .hundreds(v_h), .tens(v_t), .ones(v_o));
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            sel <= 5'b00001;
            digit <= 4'd0;
            counter <= 0;
        end else if (clk_tick) begin
            counter <= 0;
            case (sel)
                5'b00001: begin sel <= 5'b00010; digit <= t_t; end
                5'b00010: begin sel <= 5'b00100; digit <= v_o; end
                5'b00100: begin sel <= 5'b01000; digit <= v_t; end
                5'b01000: begin sel <= 5'b00001; digit <= t_o; end
                default:  begin sel <= 5'b00001; digit <= 4'd0; end
            endcase
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

module BuzzerControllerParamR(
    input clk,
    input rst,
    input shortBeepTrig,
    input longBeepTrig,
    output buzzer
    );
    localparam [25:0] SHORT_CYC=26'd10000000;  // ~0.20 s
    localparam [25:0] LONG_CYC =26'd30000000; // ~0.60 s
    localparam [15:0] SHORT_DIV=16'd24999;    // ~1 kHz
    localparam [15:0] LONG_DIV =16'd12499;     // ~2 kHz
    reg buzzReq; reg [25:0] cntDur; reg [15:0] divCnt, divSel; reg sq;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buzzReq<=0;
            cntDur<=0;
            divCnt<=0;
            divSel<=SHORT_DIV;
            sq<=0;
        end else begin
            if (longBeepTrig) begin
                buzzReq<=1;
                cntDur<=LONG_CYC;
                divSel<=LONG_DIV;
            end else if (shortBeepTrig) begin
                buzzReq<=1;
                cntDur<=SHORT_CYC;
                divSel<=SHORT_DIV;
            end else if (cntDur!=0) begin
                cntDur<=cntDur-1;
                buzzReq<=1;
            end else begin
                buzzReq<=0;
            end
            if (!buzzReq) begin
                divCnt<=0;
                sq<=0;
            end else if (divCnt==divSel) begin
                divCnt<=0;
                sq<=~sq;
            end else
                divCnt<=divCnt+1;
        end
    end
    assign buzzer = sq;
endmodule

module mainmodule (
    input start,
    input skip,
    input reset,
    input clk,
    input [2:0] weight,
    input [1:0] calories,
    input [1:0] MET,
    input gender,
    output [4:0] seg_sel,
    output [7:0] seg_data,
    output buzzer_out
    );
    wire [1:0] state_w;
    wire [5:0] timer_w;
    wire [7:0] curr_idx_w;
    wire act_buz_w;
    wire buz_mode_w;
    wire [8:0] total_workouts;
    wire [7:0] total_workouts_8bit;
    
    combinational_circuit calc1(
        .input_bits({weight, calories, MET, gender}),
        .T3(total_workouts_8bit)
    );
    assign total_workouts = {1'b0, total_workouts_8bit};

    workout_fsm f1(
        .start_btn(start),
        .skip_btn(skip),
        .reset_btn(reset),
        .clk(clk),
        .total_count_in(total_workouts),
        .state(state_w),
        .timer(timer_w),
        .curr_idx(curr_idx_w),
        .buz_pulse(act_buz_w),
        .buz_mode(buz_mode_w)
    );
    wire short_beep, long_beep;
    assign short_beep = act_buz_w & ~buz_mode_w;
    assign long_beep = act_buz_w & buz_mode_w;
    BuzzerControllerParamR b1(
        .clk(clk),
        .rst(~reset), // New buzzer uses active-high reset
        .shortBeepTrig(short_beep),
        .longBeepTrig(long_beep),
        .buzzer(buzzer_out)
    );
    wire [8:0] to_show;
    assign to_show = (state_w == 2'b00) ? total_workouts : {1'b0, curr_idx_w};
    wire [3:0] seg_digit;
     
    seg_multiplexer s1_real(
        .clk(clk),
        .reset_n(reset),
        .show_value(to_show),
        .timer(timer_w),
        .sel(seg_sel),
        .digit(seg_digit)
    );
    seg_driver s2(.digit(seg_digit), .seg_out(seg_data));
endmodule