module workout_fsm(
    input clk,          // 1Hz clock
    input start, 
    input skip,
    input reset,
    input time_done,    // from timer
    input [7:0] T,      // from combinational circuit

    output reg beep_cycle_end, // Beep for end of rest
    output reg beep_finish,    // Beep for workout end
    output reg [1:0] state_out,
    output reg start_timer,
    output reg show_time,
    output reg done
);

    // FSM states (no typedef in pure Verilog)
    localparam IDLE    = 2'b00;
    localparam WORKOUT = 2'b01;
    localparam REST    = 2'b10;
    localparam FINISH  = 2'b11;

    reg [1:0] current_state, next_state;
    reg [7:0] count; // remaining exercises

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

    // Sequential state + counter update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            count <= T;
        end else begin
            current_state <= next_state;
            if (current_state == WORKOUT && (skip || time_done) && count > 0)
                count <= count - 1;
        end
    end

    // Output logic
    always @(*) begin
        // defaults
        start_timer = 0;
        show_time   = 0;
        done        = 0;
        beep_cycle_end = 0;
        beep_finish    = 0;
        state_out      = current_state;

        case (current_state)
            WORKOUT: begin
                start_timer = 1;
                show_time   = 1;
            end
            REST: begin
                start_timer = 1;
                show_time   = 1;
                if (time_done)
                    beep_cycle_end = 1;
            end
            FINISH: begin
                done        = 1;
                beep_finish = 1;
            end
        endcase
    end

endmodule
