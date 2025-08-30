
// ============================================================
// TOP-LEVEL: Integrated system for Logic Lab Final Project
// - Uses 40MHz clock
// - Generates divided clocks (1Hz, 500Hz, 1kHz, 2kHz)
// - Debounces push buttons
// - Computes T (minutes) from 8-bit switches via combinational_circuit
// - FSM controls flow; timer counts seconds at 1Hz(counts one each second)
// - Buzzer beeps when FSM asserts 'beep'
// - 4-digit 7-seg shows remaining activities and remaining time of each activity (up to 9999)
// ============================================================

// top_module.v (Corrected)

module top_module (
    input        clk,              // 40 MHz clock
    input        rst,              // Reset (active-high)
    input  [8:0] switches,
    input        btn_start,        // Push button: Start
    input        btn_skip,         // Push button: Skip
    input        btn_reset,        // Push button: Reset
    output       buzzer,
    output [7:0] seg_data,         // 7-seg segments
    output [3:0] digit_enable      // 7-seg common-cathode enables (active-low)
);
    // ====================== CLOCK DIVIDER ======================
    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;
    clock_divider u_clkdiv (
        .clk_in(clk), .reset(rst), .clk_1Hz(clk_1Hz),
        .clk_500Hz(clk_500Hz), .clk_1kHz(clk_1kHz), .clk_2kHz(clk_2kHz)
    );
    // ====================== DEBOUNCERS =========================
    wire start_clean, skip_clean, reset_clean;
    debouncer u_db_start (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_start), .clean_btn(start_clean));
    debouncer u_db_skip  (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_skip),  .clean_btn(skip_clean));
    debouncer u_db_reset (.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_reset), .clean_btn(reset_clean));
    // ================== COMBINATIONAL CIRCUIT ==================
    wire [7:0] T_minutes;
    combinational_circuit u_comb ( .input_bits(switches[7:0]), .T3(T_minutes) );

    // ======================== FSM ==============================
    wire        fsm_start_timer, fsm_show_time, fsm_done;
    wire        fsm_beep_cycle, fsm_beep_finish; // Renamed to reflect new FSM outputs
    wire  [1:0] fsm_state;

    workout_fsm u_fsm (
        .clk           (clk_1Hz),
        .start         (start_clean),
        .skip          (skip_clean),
        .reset         (reset_clean),
        .time_done     (timer_timeout),
        .T             (T_minutes),
        .beep_cycle_end(fsm_beep_cycle), // Connect to new FSM output
        .beep_finish   (fsm_beep_finish),  // Connect to new FSM output
        .state_out     (fsm_state),
        .start_timer   (fsm_start_timer),
        .show_time     (fsm_show_time),
        .done          (fsm_done)
    );
    // ======================= TIMER =============================
    wire timer_timeout;
    // FIXED FLAW 1: Timer duration is now selected based on FSM state
    wire [15:0] timer_duration;
    // When in WORKOUT (01), duration is 45s. In REST (10), 15s.
    // Timer times out after (duration+1) ticks, so we use N-1.
    assign timer_duration = (fsm_state == 2'b01) ? 16'd44 :
                            (fsm_state == 2'b10) ? 16'd14 : 16'd0;

    timer u_timer (
        .clk     (clk_1Hz),
        .rst     (reset_clean),
        .enable  (fsm_start_timer),
        .duration(timer_duration), // Use the dynamically selected duration
        .timeout (timer_timeout)
    );

    // ======================= DISPLAY COUNTER ===================
    // FIXED FLAW 2: This counter now correctly counts down from 45 or 15
    reg [15:0] time_display_reg;
    reg [1:0]  fsm_state_prev; // Used to detect state changes

    always @(posedge clk_1Hz or posedge reset_clean) begin
        if (reset_clean) begin
            time_display_reg <= 0;
            fsm_state_prev   <= 2'b00; // IDLE state
        end else begin
            fsm_state_prev <= fsm_state; // Store current state for next cycle

            // On a state change, load the appropriate time
            if (fsm_state != fsm_state_prev) begin
                if (fsm_state == 2'b01)      // Entering WORKOUT
                    time_display_reg <= 45;
                else if (fsm_state == 2'b10) // Entering REST
                    time_display_reg <= 15;
                else                         // Entering IDLE or FINISH
                    time_display_reg <= 0;
            end
            // Otherwise, if the timer is running, countdown
            else if (fsm_start_timer && time_display_reg > 0) begin
                time_display_reg <= time_display_reg - 1;
            end
        end
    end

    // ======================= BUZZER ============================
    // FIXED FLAW 3: Implement different frequencies for beeps
    localparam integer CLK_FREQ          = 40000000;
    localparam integer BEEP_FREQ_NORMAL  = 1000; // 1kHz for cycle end
    localparam integer BEEP_FREQ_FINISH  = 500;  // 500Hz for workout finish
    localparam integer FREQ_SEL_NORMAL   = CLK_FREQ / (2 * BEEP_FREQ_NORMAL);
    localparam integer FREQ_SEL_FINISH   = CLK_FREQ / (2 * BEEP_FREQ_FINISH);

    wire beep_enable = fsm_beep_cycle || fsm_beep_finish;
    wire [15:0] beep_freq_select = fsm_beep_finish ? FREQ_SEL_FINISH : FREQ_SEL_NORMAL;

    frequency_generator u_freq (
        .clk             (clk),
        .enable          (beep_enable),
        .frequency_select(beep_freq_select),
        .buzzer_signal   (buzzer)
    );
    // =================== 7-SEGMENT DISPLAY =====================
    wire [3:0] d3, d2, d1, d0;
    bin_to_bcd_16 u_b2b (
        .bin      (time_display_reg), // Display the new corrected time
        .thousands(d3), .hundreds(d2), .tens(d1), .ones(d0)
    );

    // Multiplexing logic remains the same
    reg [1:0] digit_sel;
    always @(posedge clk_500Hz or posedge rst) begin
        if (rst) digit_sel <= 2'd0;
        else     digit_sel <= digit_sel + 1;
    end

    reg [3:0] cur_bcd;
    always @(*) begin
        case (digit_sel)
            2'd0: cur_bcd = d0; 2'd1: cur_bcd = d1;
            2'd2: cur_bcd = d2; 2'd3: cur_bcd = d3;
            default: cur_bcd = 4'd0;
        endcase
    end

    wire [7:0] segs;
    bcd2seven_seg u_bcd2seg (.a(cur_bcd), .SEG_DATA(segs));

    reg [3:0] an_r;
    always @(*) begin
        case (digit_sel)
            2'd0: an_r = 4'b1110; 2'd1: an_r = 4'b1101;
            2'd2: an_r = 4'b1011; 2'd3: an_r = 4'b0111;
            default: an_r = 4'b1111;
        endcase
    end

    assign digit_enable = an_r;
    assign seg_data     = segs;

endmodule