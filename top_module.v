
// ============================================================
// TOP-LEVEL: Integrated system for Logic Lab Final Project
// - Uses 40MHz clock
// - Generates divided clocks (1Hz, 500Hz, 1kHz, 2kHz)
// - Debounces push buttons
// - Computes T (minutes) from 8-bit switches via combinational_circuit
// - FSM controls flow; timer counts seconds at 1Hz
// - Buzzer beeps when FSM asserts 'beep'
// - 4-digit 7-seg shows remaining seconds (up to 9999)
// ============================================================

module top_module (
    input        clk,              // 40 MHz clock (P184)
    input        rst,              // Reset (active-high)
    input  [8:0] switches,         // 9 switches (we use [7:0] for combinational_circuit), switches[0]=LSB
    input        btn_start,        // Push button: Start
    input        btn_skip,         // Push button: Skip
    input        btn_reset,        // Push button: Reset
    output       buzzer,           // Buzzer output (P13)
    output [7:0] seg_data,         // 7-seg segments (a..g,dp) to 74AC245SC
    output [3:0] digit_enable      // 7-seg common-cathode enables to ULN2003L (active-low)
);

    // ====================== CLOCK DIVIDER ======================
    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;
    clock_divider u_clkdiv (
        .clk_in   (clk),
        .reset    (rst),
        .clk_1Hz  (clk_1Hz),
        .clk_500Hz(clk_500Hz),
        .clk_1kHz (clk_1kHz),
        .clk_2kHz (clk_2kHz)
    );

    // ====================== DEBOUNCERS =========================
    wire start_clean, skip_clean, reset_clean;
    debouncer u_db_start (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_start), .clean_btn(start_clean));
    debouncer u_db_skip  (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_skip),  .clean_btn(skip_clean));
    debouncer u_db_reset (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_reset), .clean_btn(reset_clean));

    // ================== COMBINATIONAL CIRCUIT ==================
    // Computes T (minutes) based on switches[7:0]
    wire [7:0] T_minutes;
    combinational_circuit u_comb (
        .input_bits(switches[7:0]),
        .T3        (T_minutes)
    );

    // Convert minutes to seconds using shift/sub (60*T = (T<<6) - (T<<2))
    wire [15:0] duration_seconds; // up to 60*255 = 15300 fits in 16 bits
    assign duration_seconds = ({T_minutes,6'b0}) - ({T_minutes,2'b0});

    // ======================== FSM ==============================
    // Expected ports (based on your earlier file):
    // workout_fsm(.clk, .start, .skip, .reset, .time_done, .T, .beep, .state_out, .start_timer, .show_time, .done)
    wire        fsm_beep;
    wire        fsm_start_timer;
    wire        fsm_show_time;
    wire        fsm_done;
    wire  [1:0] fsm_state; // optional, if your FSM exposes state_out[1:0]

    workout_fsm u_fsm (
        .clk       (clk_1Hz),
        .start     (start_clean),
        .skip      (skip_clean),
        .reset     (reset_clean),
        .time_done (timer_timeout),
        .T         (T_minutes),
        .beep      (fsm_beep),
        .state_out (fsm_state),
        .start_timer(fsm_start_timer),
        .show_time (fsm_show_time),
        .done      (fsm_done)
    );

    // ======================= TIMER =============================
    // Counts seconds at 1Hz up to 'duration_seconds' when enabled by FSM
    wire timer_timeout;
    timer u_timer (
        .clk     (clk_1Hz),            // 1-second tick
        .rst     (reset_clean),        // reset by button
        .enable  (fsm_start_timer),    // start/pause controlled by FSM
        .duration(duration_seconds),   // total seconds (<= 9999 recommended for 4-digit display)
        .timeout (timer_timeout)
    );

    // For display: keep track of elapsed seconds while timer running.
    // NOTE: this counter is only for display; timer is the authoritative time_done.
    reg [15:0] elapsed_sec;
    always @(posedge clk_1Hz or posedge reset_clean) begin
        if (reset_clean) begin
            elapsed_sec <= 0;
        end else begin
            if (!timer_timeout && fsm_start_timer)
                elapsed_sec <= elapsed_sec + 1;
            else if (!fsm_start_timer)
                elapsed_sec <= 0;
        end
    end

    wire [15:0] remain_sec = (duration_seconds > elapsed_sec) ? (duration_seconds - elapsed_sec) : 16'd0;

    // ======================= BUZZER ============================
    // Use raw 40MHz clock for fine tone frequency; select ~1kHz tone
    localparam integer CLK_FREQ   = 40000000;
    localparam integer BEEP_FREQ  = 1000;
    localparam integer FREQ_SEL   = CLK_FREQ / (2*BEEP_FREQ); // toggle every FREQ_SEL ticks

    frequency_generator u_freq (
        .clk             (clk),
        .enable          (fsm_beep),
        .frequency_select(FREQ_SEL[15:0]), // match your module width
        .buzzer_signal   (buzzer)
    );

    // =================== 7-SEGMENT DISPLAY =====================
    // Convert 'remain_sec' (0..9999) to 4 BCD digits. If exceed, it will saturate to 9999.
    wire [3:0] d3, d2, d1, d0; // thousands, hundreds, tens, ones
    bin_to_bcd_16 u_b2b (
        .bin(remain_sec),
        .thousands(d3),
        .hundreds (d2),
        .tens     (d1),
        .ones     (d0)
    );

    // Multiplexing at ~500Hz for flicker-free display
    reg [1:0] digit_sel;
    always @(posedge clk_500Hz or posedge rst) begin
        if (rst) digit_sel <= 2'd0;
        else     digit_sel <= digit_sel + 2'd1;
    end

    reg [3:0] cur_bcd;
    always @(*) begin
        case (digit_sel)
            2'd0: cur_bcd = d0;
            2'd1: cur_bcd = d1;
            2'd2: cur_bcd = d2;
            2'd3: cur_bcd = d3;
            default: cur_bcd = 4'd0;
        endcase
    end

    wire [7:0] segs;
    bcd2seven_seg u_bcd2seg (.a(cur_bcd), .SEG_DATA(segs));

    // Common-cathode enables are active-low: only one digit enabled at a time
    reg [3:0] an_r;
    always @(*) begin
        case (digit_sel)
            2'd0: an_r = 4'b1110;
            2'd1: an_r = 4'b1101;
            2'd2: an_r = 4'b1011;
            2'd3: an_r = 4'b0111;
            default: an_r = 4'b1111;
        endcase
    end

    assign digit_enable = an_r;
    assign seg_data     = segs;

endmodule

// ============================================================
// Helper: 16-bit binary -> 4-digit BCD (0..9999) using Double-Dabble
// ============================================================
module bin_to_bcd_16(
    input  [15:0] bin,
    output [3:0] thousands,
    output [3:0] hundreds,
    output [3:0] tens,
    output [3:0] ones
);
    integer i;
    reg [31:0] shift_reg; // [31:16]=unused, [15:0]=bin, [19:16]=thousands, [23:20]=hundreds, [27:24]=tens, [31:28]=ones (we'll map at end)
    reg [3:0] th, hu, te, on;

    always @(*) begin
        // Initialize BCD nibbles and load binary
        shift_reg = {16'd0, bin};
        th = 4'd0; hu = 4'd0; te = 4'd0; on = 4'd0;

        // Process 16 bits
        for (i = 0; i < 16; i = i + 1) begin
            // Add-3 step on each BCD digit if >= 5
            if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 3;
            if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 3;
            if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 3;
            // Shift left by 1
            shift_reg = shift_reg << 1;
        end

        // Extract final BCD digits
        on = shift_reg[31:28];
        te = shift_reg[27:24];
        hu = shift_reg[23:20];
        th = shift_reg[19:16];
    end

    assign thousands = th;
    assign hundreds  = hu;
    assign tens      = te;
    assign ones      = on;
endmodule
