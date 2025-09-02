//`timescale 1ns/1ps

module top_module (

    input clk,           // 40 MHz

    input rst,           // async reset (active-high)

    input [7:0] switches, // input switches (for initial workout count)

    input btn_skip,

    input btn_start,

    output [4:0] SEG_SEL, 

    output [7:0] SEG_DATA,

    output [2:0] fsm_state  // for debugging

);



    // ---------- Clock Divider ----------

    wire clk_1Hz, clk_500Hz, clk_1kHz, clk_2kHz;

    clock_divider u_clkdiv (

        .clk_in(clk), 

        .reset(rst),

        .clk_1Hz(clk_1Hz), 

        .clk_500Hz(clk_500Hz),

        .clk_1kHz(clk_1kHz), 

        .clk_2kHz(clk_2kHz)

    );

    

    // ---------- Combinational Circuit (for initial workout count) ----------

    wire [7:0] T_minutes;

    combinational_circuit u_comb (.input_bits(switches), .T3(T_minutes));

    

    // ---------- Button Debouncers ----------

    wire clean_skip, clean_start;

    debouncer deb_skip(.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_skip), .clean_btn(clean_skip));

    debouncer deb_start(.clk(clk_1kHz), .rst(rst), .noisy_btn(btn_start), .clean_btn(clean_start));



    // ---------- FSM and Timer Integration ----------

    // The FSM runs on the fast clock for responsiveness.

    // It outputs timer control signals to a separate timer module (which runs on clk_1Hz).

    wire fsm_done;

    wire [7:0] fsm_count;

    wire [7:0] fsm_timer;   // current timer value from timer module

    wire timer_load;

    wire [7:0] timer_preset;

    wire timer_done_signal;



    workout_fsm u_fsm (

        .clk(clk),

        .reset(rst),

        .start(clean_start),

        .skip(clean_skip),

        .timer_done(timer_done_signal),

        .T(T_minutes),         // initial number of workouts (from switches)

        .state_out(fsm_state),

        .done(fsm_done),

        .count(fsm_count),

        .timer_load(timer_load),

        .timer_preset(timer_preset)

    );

    

    // Timer module (operates at 1Hz)

    // It loads a preset when timer_load is asserted and then counts down.

    timer u_timer (

        .clk_1Hz(clk_1Hz),

        .reset(rst),

        .load(timer_load),

        .preset(timer_preset),

        .timer_val(fsm_timer),

        .timer_done(timer_done_signal)

    );

    

    // ---------- Display: Convert numbers to BCD for 7-Segment Displays ----------

    // We want the two left-most digits to show the remaining workouts (fsm_count)

    // and the two right-most digits to show the timer (fsm_timer).

    wire [3:0] workout_tens, workout_ones;

    wire [3:0] timer_tens, timer_ones;

    

    bin2bcd converter_workout (

        .binary(fsm_count),

        .tens(workout_tens),

        .ones(workout_ones)

    );

    

    bin2bcd converter_timer (

        .binary(fsm_timer),

        .tens(timer_tens),

        .ones(timer_ones)

    );

    

    // The BCDcontrol module selects which digit to display.

    // Map:

    //   digit1 (rightmost) = timer ones

    //   digit2 = timer tens

    //   digit3 = workout ones

    //   digit4 (leftmost) = workout tens

    wire [2:0] refresh_counter;

    wire [4:0] bcd_digit;

    

    refreshCounter refresh_counter_inst (

        .refresh_clock(clk_500Hz),

        .refreshCounter(refresh_counter)

    );

    

    BCDcontrol bcd_control (

        .digit1(timer_ones),

        .digit2(timer_tens),

        .digit3(workout_ones),

        .digit4(workout_tens),

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



// ---------------------------

// Below are the supporting modules

// ---------------------------



module combinational_circuit (

    input  [7:0] input_bits,

    output [7:0] T3

	);

    // (Your existing implementation for T3 remains unchanged)

    // For brevity, only a sample wiring is provided.

    assign T3 = input_bits; // Replace with your actual logic.

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

    // 4-to-1 multiplexer using gate-level code.

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

    input  wire clk_in,  // 40MHz input clock

    input  wire reset,   // async reset (active-high)

    output reg clk_1Hz,  // 1Hz clock (for timer)

    output reg clk_500Hz,// 500Hz for 7-seg refresh

    output reg clk_1kHz, // 1kHz (for debouncers)

    output reg clk_2kHz  // 2kHz for buzzer (if needed)

);

    reg [24:0] count_1Hz;  

    reg [15:0] count_500Hz; 

    reg [15:0] count_1kHz;  

    reg [15:0] count_2kHz; 



    always @(posedge clk_in or negedge reset) begin

        if(~reset) begin

            clk_1Hz   <= 0;

            clk_500Hz <= 0;

            clk_1kHz  <= 0;

            clk_2kHz  <= 0;

            count_1Hz   <= 0;

            count_500Hz <= 0;

            count_1kHz  <= 0;

            count_2kHz  <= 0;

        end else begin

            // 1Hz clock: period=0.5sec high/low = 20,000,000 cycles for 40MHz

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

            default: SEG_DATA = 8'b00111111; // turn off all segments

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

        // The refreshCounter cycles; map each value to one display digit.

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



module bin2bcd (

    input [7:0] binary,

    output reg [3:0] tens,

    output reg [3:0] ones

);

    integer i;

    reg [7:0] bcd;    

    always @(*) begin 

        bcd = 0;

        for (i = 0; i < 8; i = i + 1) begin

            // Double-dabble: if any BCD nibble ≥5, add 3

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



// ---------------------------

// Timer Module: operates on clk_1Hz

// ---------------------------

module timer (

    input clk_1Hz,         // 1Hz clock for countdown

    input reset,           // active-high reset

    input load,            // when asserted, preload preset value

    input [7:0] preset,    // preset value (e.g., 45 for workout, 15 for rest)

    output reg [7:0] timer_val, // current timer value

    output timer_done      // asserted when timer_val reaches 0

);

    always @(posedge clk_1Hz or posedge reset) begin

        if (reset)

            timer_val <= 0;

        else if (load)

            timer_val <= preset;

        else if(timer_val > 0)

            timer_val <= timer_val - 1;

    end

    assign timer_done = (timer_val == 0);

endmodule



// ---------------------------

// FSM Module with Timer Control

// ---------------------------

module workout_fsm (

    input clk,                // fast clock (e.g., 40MHz)

    input reset,              // active-high reset

    input start,              // debounced start (active-high)

    input skip,               // debounced skip (active-high)

    input timer_done,         // from timer module (1Hz)

    input [7:0] T,            // initial number of workouts

    output reg [2:0] state_out,

    output reg done,

    output reg [7:0] count,

    output reg timer_load,          // asserted when a new period starts

    output reg [7:0] timer_preset   // preset value to load into timer (45 or 15)

    );
	 /*

    localparam IDLE    = 2'b00;

    localparam WORKOUT = 2'b01;

    localparam REST    = 2'b10;

    localparam FINISH  = 2'b11;
	 */
	 localparam IDLE = 3'b000;
	 localparam WORKOUT = 3'b001;
	 localparam WORKOUT_WAIT = 3'b010;
	 localparam REST = 3'b011;
	 localparam REST_WAIT = 3'b100;
	 localparam FINISH = 3'b101;


    

    reg [2:0] current_state, next_state;
	 
	 reg start_prev, skip_prev;
	 wire start_falling, skip_falling;
	 
	 assign start_falling = (start_prev && ~start);
	 assign skip_falling = (skip_prev && ~skip);

    

    // Next state and timer control combinational logic.

    always @(*) begin

        // Default: hold state and do not load new timer value.

        next_state = current_state;

        timer_load = 1'b0;

        timer_preset = 8'd0;

        

        case (current_state)

            IDLE: begin

                if (start_falling) begin

                    next_state = WORKOUT;

                end

            end

            WORKOUT: begin
					timer_load = 1'b1;
					timer_preset = 8'd45;
					next_state = WORKOUT_WAIT;

            end
				WORKOUT_WAIT : begin
					if(skip_falling) begin
						next_state = REST;
					end
				end
				REST : begin
					timer_load = 1'b1;
					timer_preset = 8'd15;
					next_state = REST_WAIT;
				end
				

            REST_WAIT : begin

                if (skip_falling || timer_done) begin

                    // Decrement workout count and decide next state.

                    if (count > 1)

                        next_state = WORKOUT;

						  else

                        next_state = FINISH;

                end

            end

            FINISH: begin

                next_state = FINISH;
					 if(start_falling) begin
						next_state = IDLE;
					end

            end
            
            default: next_state = IDLE;

        endcase

    end

    

    // FSM sequential update.

    always @(posedge clk or negedge reset) begin

        if (~reset) begin

            current_state <= IDLE;

            count <= T;  // initialize workouts

            done  <= 1'b0;
				start_prev <= 1'b1;
				skip_prev <= 1'b1;

        end else begin

            current_state <= next_state;
				start_prev <= start;
				skip_prev <= skip;
				
				if(current_state == IDLE) begin
					count <= T;
					done <= 1'b0;
				end
				else if((current_state == REST_WAIT) && (next_state == WORKOUT || next_state == FINISH)) begin
					if(count > 0)
						count <= count -1;
				end
				else if(next_state == FINISH) begin
					done <= 1'b1;
					count <= 0;
				end
				else if(current_state == FINISH && next_state == IDLE) begin
					done <= 1'b0;
				end

        end

    end

    

    // Output current state for debugging.

    always @(*) begin

        state_out = current_state;

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
	
	always@(posedge clk or negedge rst) begin
		if(~rst) begin
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



