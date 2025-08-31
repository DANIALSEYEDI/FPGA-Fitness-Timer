// top_module_with_lcd.v
// Top-level integrated with 5-digit 7-seg + LCD controller
`timescale 1ns/1ps

module top_module (
    input        clk,        // 40 MHz
    input        rst,        // async reset (active-high)
    input  [7:0] switches,
    input        btn_start,
    input        btn_skip,
    input        btn_reset,
    output       buzzer,
    output [7:0] seg_data,
    output [4:0] digit_enable,
    // LCD signals
    output RS,
    output RW,
    output E,
    output [7:4] lcd_data
);

    // ---------- clock divider ----------
    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;
    clock_divider u_clkdiv (
        .clk_in(clk), .reset(rst),
        .clk_1Hz(clk_1Hz), .clk_500Hz(clk_500Hz),
        .clk_1kHz(clk_1kHz), .clk_2kHz(clk_2kHz)
    );

    // ---------- debouncers ----------
    wire start_clean, skip_clean, reset_clean;
    debouncer u_db_start (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_start), .clean_btn(start_clean));
    debouncer u_db_skip  (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_skip),  .clean_btn(skip_clean));
    debouncer u_db_reset (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_reset), .clean_btn(reset_clean));

    // ---------- combinational circuit ----------
    wire [7:0] T_minutes;
    combinational_circuit u_comb (.input_bits(switches), .T3(T_minutes));

    // ---------- FSM ----------
    wire fsm_start_timer, fsm_show_time, fsm_done;
    wire fsm_beep_cycle, fsm_beep_finish;
    wire [1:0] fsm_state;

    workout_fsm u_fsm (
        .clk(clk_1Hz),
        .start(start_clean),
        .skip(skip_clean),
        .reset(reset_clean),
        .time_done(timer_timeout),
        .T(T_minutes),
        .beep_cycle_end(fsm_beep_cycle),
        .beep_finish(fsm_beep_finish),
        .state_out(fsm_state),
        .start_timer(fsm_start_timer),
        .show_time(fsm_show_time),
        .done(fsm_done)
    );

    // ---------- Timer ----------
    wire timer_timeout;
    wire [15:0] timer_duration = (fsm_state==2'b01) ? 16'd44 :
                                 (fsm_state==2'b10) ? 16'd14 : 16'd0;

    timer u_timer (
        .clk(clk_1Hz),
        .rst(reset_clean),
        .enable(fsm_start_timer),
        .duration(timer_duration),
        .timeout(timer_timeout)
    );

    // ---------- Time display register ----------
    reg [15:0] time_display_reg;
    reg [1:0]  fsm_state_prev;
    always @(posedge clk_1Hz or posedge reset_clean) begin
        if (reset_clean) begin
            time_display_reg <= 0;
            fsm_state_prev   <= 0;
        end else begin
            fsm_state_prev <= fsm_state;
            if (fsm_state != fsm_state_prev) begin
                case (fsm_state)
                    2'b01: time_display_reg <= 16'd45; // workout
                    2'b10: time_display_reg <= 16'd15; // rest
                    default: time_display_reg <= 0;
                endcase
            end else if (fsm_start_timer && time_display_reg>0) begin
                time_display_reg <= time_display_reg - 1;
            end
        end
    end

    // ---------- Exercise ID counter ----------
    reg [3:0] exercise_id;
    always @(posedge clk_1Hz or posedge reset_clean) begin
        if (reset_clean)
            exercise_id <= 0;
        else if (fsm_state_prev!=fsm_state && fsm_state==2'b01)
            exercise_id <= (exercise_id==4'd9) ? 0 : exercise_id+1;
    end

    // ---------- Buzzer ----------
    localparam CLK_FREQ=40000000;
    localparam FREQ_SEL_NORMAL = CLK_FREQ/(2*1000);
    localparam FREQ_SEL_FINISH = CLK_FREQ/(2*500);
    wire beep_enable = fsm_beep_cycle | fsm_beep_finish;
    wire [15:0] beep_freq_select = fsm_beep_finish ? FREQ_SEL_FINISH[15:0] : FREQ_SEL_NORMAL[15:0];
    frequency_generator u_freq (
        .clk(clk), .enable(beep_enable),
        .frequency_select(beep_freq_select),
        .buzzer_signal(buzzer)
    );

    // ---------- bin to BCD ----------
    wire [3:0] B_th, B_hu, B_te, B_on;
    bin_to_bcd_16 u_b2b (
        .bin(time_display_reg),
        .thousands(B_th), .hundreds(B_hu), .tens(B_te), .ones(B_on)
    );

    // exercise number as two digits
    wire [3:0] ex_tens = 4'd0;
    wire [3:0] ex_ones = exercise_id;

    // ---------- 5-digit multiplex ----------
    reg [2:0] digit_sel;
    always @(posedge clk_500Hz or posedge rst)
        if (rst) digit_sel <= 0;
        else digit_sel <= (digit_sel==3'd4) ? 0 : digit_sel+1;

    reg [3:0] cur_bcd;
    reg [7:0] cur_pattern;
    localparam [7:0] BLANK_PATTERN = 8'b00000000;
    localparam [7:0] COLON_PATTERN = 8'b00000001; // depends on board

    always @(*) begin
        cur_bcd=0; cur_pattern=BLANK_PATTERN;
        case(digit_sel)
            3'd4: cur_bcd=ex_tens;
            3'd3: cur_bcd=ex_ones;
            3'd2: cur_pattern=COLON_PATTERN;
            3'd1: cur_bcd=B_te;
            3'd0: cur_bcd=B_on;
        endcase
    end

    wire [7:0] seg_from_bcd;
    bcd2seven_seg u_bcd2seg(.a(cur_bcd), .SEG_DATA(seg_from_bcd));
    wire [7:0] out_pattern = (digit_sel==3'd2) ? cur_pattern : seg_from_bcd;

    reg [4:0] an_r;
    always @(*) begin
        an_r=5'b11111;
        case(digit_sel)
            3'd4: an_r=5'b01111;
            3'd3: an_r=5'b10111;
            3'd2: an_r=5'b11011;
            3'd1: an_r=5'b11101;
            3'd0: an_r=5'b11110;
        endcase
    end
    assign digit_enable = an_r;
    assign seg_data = out_pattern;

    // ---------- LCD controller ----------
    lcd_controller u_lcd (
        .clk(clk),
        .rst(rst),
        .exercise_id(exercise_id),
        .RS(RS), .RW(RW), .E(E),
        .data(lcd_data)
    );

endmodule
