
module workout_fsm(
    //TODO : it has been clearly said in the project description that the FSM should have 2 input clock signals
    input clk,          // 1Hz clock
    input start, 
    input skip,
    input reset,
    //these three push buttons should be connected to the relevant pins on the FPGA 
    input time_done, //this input comes from the timer and becomes one when the 1 minute time of a workout and rest is finished
    input [7:0] T,//the input from the combinational circuit

    output reg beep_cycle_end, // Beep for end of rest period
    output reg beep_finish,    // Beep for final workout completion
    output reg [1:0] state_out,
    output reg start_timer,
    output reg show_time,
    //these two should mpst probably go to the 7-segments
    output reg done
);

    typedef enum reg [1:0] {
        IDLE    = 2'b00,
        WORKOUT = 2'b01,
        REST    = 2'b10,
        FINISH  = 2'b11
    } state_t;

    state_t current_state, next_state;
    reg [7:0] count; // this holds the count of the excersices remaining

    // Combinational logic for next state
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

    // Sequential logic for state and counter updates
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

    // Combinational logic for outputs
    always @(*) begin
        // Default assignments
        start_timer = 0;
        show_time = 0;
        done = 0;
        beep_cycle_end = 0; 
        beep_finish = 0;    
        state_out = current_state;

        case (current_state)
            WORKOUT: begin
                start_timer = 1;
                show_time = 1;
            end
            REST: begin
                start_timer = 1;
                show_time = 1;
                if (time_done)
                    beep_cycle_end = 1;
            end
            FINISH: begin
                done = 1;
                beep_finish = 1;
            end
        endcase
    end

endmodule