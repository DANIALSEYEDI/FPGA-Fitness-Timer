// fsm.v (Corrected)

module workout_fsm(
    input clk,          // 1Hz clock
    input start,
    input skip,
    input reset,
    input time_done,
    input [7:0] T,

    // MODIFIED: Replaced single 'beep' with two distinct signals
    output reg beep_cycle_end, // Beep for end of rest period
    output reg beep_finish,    // Beep for final workout completion
    output reg [1:0] state_out,
    output reg start_timer,
    output reg show_time,
    output reg done
);

    typedef enum reg [1:0] {
        IDLE    = 2'b00,
        WORKOUT = 2'b01,
        REST    = 2'b10,
        FINISH  = 2'b11
    } state_t;

    state_t current_state, next_state;
    reg [7:0] count;

    // Combinational logic for next state (No changes here)
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
                else if (skip || time_done)
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

    // Sequential logic for state and counter updates (No changes here)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            count <= T;
        end else begin
            current_state <= next_state;
            // Decrement workout count after completing a WORKOUT state
            if (current_state == WORKOUT && (skip || time_done) && count > 0)
                count <= count - 1;
        end
    end

    // Combinational logic for outputs (MODIFIED)
    always @(*) begin
        // Default assignments
        start_timer = 0;
        show_time = 0;
        done = 0;
        beep_cycle_end = 0; // Initialize new output
        beep_finish = 0;    // Initialize new output
        state_out = current_state;

        case (current_state)
            WORKOUT: begin
                start_timer = 1;
                show_time = 1;
            end
            REST: begin
                start_timer = 1;
                show_time = 1;
                // FIXED: Assert beep when rest time is done
                if (time_done)
                    beep_cycle_end = 1;
            end
            FINISH: begin
                done = 1;
                // FIXED: Use the dedicated finish beep signal
                beep_finish = 1;
            end
        endcase
    end

endmodule