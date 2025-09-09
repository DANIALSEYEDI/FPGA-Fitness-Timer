`define SYS_CLK 50_000_000
//figure out the stuff about the buzzer , debouncer, review T-calculations
module top_module (
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

    wire [1:0] fsm_state;
    wire [5:0] timer;
    wire [7:0] curent_workout_number_t;
    wire buzzer_buzzing_t;
    wire buzzer_sound_mode_t;
    wire [8:0] total_workouts;
    wire [7:0] total_workouts_8bit;
    
    combinational_circuit calc1(
        .input_bits({weight, calories, MET, gender}),
        .T3(total_workouts_8bit)
    );
    assign total_workouts = {1'b0, total_workouts_8bit};

    fsm fsm1(
        //inputs
        .start_btn(start),
        .skip_btn(skip),
        .reset_btn(reset),
        .clk(clk),
        .total_workouts(total_workouts),
        //outputs
        .current_state(fsm_state),
        .timer(timer),
        .curent_workout_number(curent_workout_number_t),
        .buzzer_buzzing(buzzer_buzzing_t),
        .buzzer_sound_mode(buzzer_sound_mode_t)
    );

    wire cycleEndBeep, ExcerciseEndBeep;
    assign cycleEndBeep = buzzer_buzzing_t & ~buzzer_sound_mode_t;
    assign ExcerciseEndBeep = buzzer_buzzing_t & buzzer_sound_mode_t;
    
    buzzer_module buzzer(
        .clk(clk),
        .rst(~reset),
        .cycleEndBeepCall(cycleEndBeep),
        .excerciseEndBeepCall(ExcerciseEndBeep),
        .buzzer(buzzer_out)
    );

    wire [8:0] remainingWorkouts;
    assign remainingWorkouts = (fsm_state == 2'b00) ? total_workouts : {1'b0, curent_workout_number_t};

    wire [3:0] timer_tens, timer_ones;
    wire [3:0] workout_tens, workout_ones;
    wire [3:0] selected_digit;
    wire [2:0] refresh_counter_wire;
    wire refresh_clk;

    //---------- Clock Divider for Display Refresh (~760 Hz) ----------
    reg [15:0] refresh_clk_counter = 0;
    assign refresh_clk = refresh_clk_counter[15];
    always @(posedge clk) begin
        refresh_clk_counter <= refresh_clk_counter + 1;
    end

    //seven-segment display modules instantiation
    refreshCounter rc_inst (
        .refresh_clock(refresh_clk),
        .refreshCounter(refresh_counter_wire)
    );

    digit_multiplexer dm_inst (
        .refreshCounter(refresh_counter_wire),
        .SEG_SEL(seg_sel)
    );
    
    bin2bcd timer_converter (
        .binary(timer), // timer is 6-bit, fits in 8-bit input
        .tens(timer_tens),
        .ones(timer_ones)
    );

    bin2bcd workout_converter (
        .binary(remainingWorkouts[7:0]),
        .tens(workout_tens),
        .ones(workout_ones)
    );

    BCDcontrol bcd_ctrl_inst (
        .digit1(workout_ones),
        .digit2(workout_tens),
        .digit3(timer_ones),
        .digit4(timer_tens),
        .refreshCounter(refresh_counter_wire),
        .one_digit(selected_digit)
    );
    
    bcd2seven_seg seg_decoder_inst (
        .digit(selected_digit),
        .SEG_DATA(seg_data)
    );

endmodule

//combinational circuit to calculate total workouts modules were here but are now tranfered to a different file


module clk_en_gen #(parameter DIVIDER = `SYS_CLK)(
    input clk,
    input rst,
    output reg clk_en
    );
    reg [31:0] counter;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            counter <= 0;
            clk_en <= 0;
        end else begin
            if (counter == DIVIDER - 1) begin
                counter <= 0;
                clk_en <= 1;
            end else begin
                counter <= counter + 1;
                clk_en <= 0;
            end
        end
    end
endmodule


module debouncer(
    input clk,
    input rst, 
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


module ButtonCond #(parameter ACTIVE_LOW=1)(
    input  clk,
    input rst,
    input btn_in,
    output reg press
    );
    wire lvl_raw;

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


module fsm(
    input start_btn,
    input skip_btn,
    input reset_btn,
    input clk,
    input [8:0] total_workouts,
    output [1:0] current_state,
    output [5:0] timer,
    output [7:0] curent_workout_number,
    output buzzer_buzzing,
    output buzzer_sound_mode
    );
    wire clean_start, clean_skip, clean_reset;
    wire clock_rising_edge;

    //debouncing the push buttons
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_start (.clk(clk), .rst(~reset_btn), .btn_in(start_btn), .press(clean_start));
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_skip  (.clk(clk), .rst(~reset_btn), .btn_in(skip_btn),  .press(clean_skip));
    ButtonCond #(.ACTIVE_LOW(1'b1))
      bc_reset (.clk(clk), .rst(~reset_btn), .btn_in(reset_btn), .press(clean_reset));
    
    //generating the 1Hz clock enable signal
    clk_en_gen #(.DIVIDER(`SYS_CLK)) clkgen (
        .clk(clk),
        .rst(reset_btn),
        .clk_en(clock_rising_edge)
    );
    


    localparam IDLE = 2'b00;
    localparam  EXERCISE = 2'b01;
    localparam REST = 2'b10;


    always @(posedge clk or negedge reset_btn) begin
        if (~reset_btn) begin
            current_state <= IDLE;
            timer <= 6'd45;
            curent_workout_number <= total_workouts; 
            buzzer_buzzing <= 1'b1;
            buzzer_sound_mode <= 1'b0;
        end else begin
            buzzer_buzzing <= 1'b0;
            if (clean_reset) begin
                current_state <= IDLE;
                curent_workout_number <= total_workouts; 
            end else begin
                case (current_state)
                    IDLE: begin
                        timer <= 6'd45;
                        if (clean_start && total_workouts > 0) begin
                            curent_workout_number <= total_workouts; 
                            current_state <= EXERCISE;
                        end
                    end
                    EXERCISE: begin
                        if (clean_skip) begin
                            if (curent_workout_number > 1)
                                curent_workout_number <= curent_workout_number - 1;
                            else
                                current_state <= IDLE;
                            timer <= 6'd45;
                            buzzer_buzzing <= 1'b1;
                        end else if (clock_rising_edge) begin
                            if (timer == 1) begin
                                current_state <= REST;
                                timer <= 6'd15;
                                buzzer_buzzing <= 1'b1;
                            end else if (timer != 0) begin
                                timer <= timer - 1;
                            end
                        end
                    end
                    REST: begin
                        if (clean_skip) begin
                            if (curent_workout_number > 1)
                                curent_workout_number <= curent_workout_number - 1;
                                current_state <= EXERCISE; //this was added
                            else
                                current_state <= IDLE;
                            //current_state <= EXERCISE;
                            timer <= 6'd45;
                            buzzer_buzzing <= 1'b1;
                        end else if (clock_rising_edge) begin
                            if (timer == 1) begin
                                if (curent_workout_number <= 1) begin // This was the last workout
                                    current_state <= IDLE;
                                    curent_workout_number <= 0;
                                    buzzer_buzzing <= 1'b1;
                                    buzzer_sound_mode <= 1'b1;
                                end else begin
                                    curent_workout_number  <= curent_workout_number - 1; 
                                    current_state <= EXERCISE;
                                    timer <= 6'd45;
                                    buzzer_buzzing <= 1'b1;
                                end
                            end else if (timer != 0) begin
                                timer <= timer - 1;
                            end
                        end
                    end
                endcase
            end
        end
    end

endmodule


module buzzer_module(
    input clk,
    input rst,
    input cycleEndBeepCall,
    input excerciseEndBeepCall,
    output buzzer
    );
    localparam [25:0] cycleEndBeepDuration=26'd10000000;  // ~0.20 s
    localparam [25:0] excerciseEndBeepDuration =26'd30000000; // ~0.60 s
    localparam [15:0] cycleEndBeepFrequency=16'd24999;   // ~1 kHz
    localparam [15:0] excerciseEndBeepFrequency =16'd12499;    // ~2 kHz
    //how are excerciseEndBeepFrequency and cycleEndBeepFrequency calculated from the desired frequency?
    //how are the durations calculated from the desired duration?
    reg buzzReq; reg [25:0] cntDur;
    reg [15:0] divCnt, divSel;
    reg sq;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buzzReq <= 0;
            cntDur <= 0;
            divCnt <= 0;
            divSel<=cycleEndBeepFrequency;
            sq<=0;
        end else begin
            if (excerciseEndBeepCall) begin
                buzzReq<=1;
                cntDur<=excerciseEndBeepDuration;
                divSel<=excerciseEndBeepFrequency;
            end else if (cycleEndBeepCall) begin
                buzzReq<=1;
                cntDur<=cycleEndBeepDuration;
                divSel<=cycleEndBeepFrequency;
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

//The 7-segment Display Modules

module bcd2seven_seg ( 
    input [3:0] digit, 
    output reg [7:0] SEG_DATA = 0
    ); 
    always @(digit)
    begin 
        case(digit) 
            4'd0: SEG_DATA = 8'b00111111; 
            4'd1: SEG_DATA = 8'b00000110; 
            4'd2: SEG_DATA = 8'b01011011;
            4'd3: SEG_DATA = 8'b01001111; 
            4'd4: SEG_DATA = 8'b01100110; 
            4'd5: SEG_DATA = 8'b01101101; 
            4'd6: SEG_DATA = 8'b01111101; 
            4'd7: SEG_DATA = 8'b00000111; 
            4'd8: SEG_DATA = 8'b01111111;
            4'd9: SEG_DATA = 8'b01101111; 
            default: SEG_DATA = 8'b00000000; // turn off all segments
        endcase 
    end 
endmodule 

module BCDcontrol (
    input [3:0] digit1,  // rightmost digit
    input [3:0] digit2,
    input [3:0] digit3,
    input [3:0] digit4,  // leftmost digit
    input [2:0] refreshCounter,
    output reg [3:0] one_digit = 0  // digit to be displayed
    );
    always @(refreshCounter) begin
        case (refreshCounter)
            2'd0: one_digit = digit1;
            2'd1: one_digit = digit2;
            2'd2: one_digit = digit3;
            2'd3: one_digit = digit4;
            default: one_digit = digit1;
        endcase
    end
endmodule

module refreshCounter (
    input refresh_clock,
    output reg [2:0] refreshCounter = 0
    );
    always @(posedge refresh_clock) begin
        if(refreshCounter == 3'b101)
            refreshCounter <= 3'b000;
        else
            refreshCounter <= refreshCounter + 1;
    end
endmodule

module digit_multiplexer (
    input [2:0] refreshCounter,
    output reg [4:0] SEG_SEL = 0
    );
    always @(refreshCounter) begin
        case (refreshCounter)
            2'd0: SEG_SEL = 5'b00010; // activate rightmost digit
            2'd1: SEG_SEL = 5'b00100;
            2'd2: SEG_SEL = 5'b01000;
            2'd3: SEG_SEL = 5'b00001; // activate leftmost digit
            default: SEG_SEL = 5'b00000;
        endcase
    end
endmodule

module bin2bcd ( // how does this bubble double algorithm work?
    input [7:0] binary,
    output reg [3:0] tens,
    output reg [3:0] ones
    );
    integer i;
    reg [7:0] bcd;   
    always @(*) begin 
        bcd = 0;
        for (i = 0; i < 8; i = i + 1) begin
            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;
            bcd = {bcd[6:0], binary[7-i]};
        end
        tens = bcd[7:4];
        ones = bcd[3:0];
    end
endmodule