module lcd_driver (
    input clk,           // 40MHz clock
    input rst,           // reset
    input [7:0] data_in, // ASCII character from ROM
    input write_en,      // enable writing new character (1 pulse)
    output reg RS, RW, E,
    output reg [7:4] data // 4-bit data bus (D4-D7)
);

    // FSM states
    parameter INIT  = 2'b00;
    parameter IDLE  = 2'b01;
    parameter WRITE = 2'b10;
    parameter HOLD  = 2'b11;

    reg [1:0] state, next_state;

    // Clock divider (~610Hz for LCD timing)
    reg [15:0] clk_div;
    wire slow_clk = clk_div[15];

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // FSM state register
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
        end else begin
            state <= next_state;
        end
    end

    // FSM next state + outputs
    always @(*) begin
        // defaults (to prevent latches)
        RS   = 0;
        RW   = 0;
        E    = 0;
        data = 4'b0000;
        next_state = state;

        case (state)
            INIT: begin
                // Initialization: clear display (command 0x01, upper nibble 0000, lower nibble 0001)
                RS   = 0; 
                RW   = 0; 
                E    = 1;
                data = 4'b0000; // send upper nibble first
                next_state = IDLE;
            end

            IDLE: begin
                if (write_en)
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end

            WRITE: begin
                // send upper nibble of data_in
                RS   = 1;
                RW   = 0;
                E    = 1;
                data = data_in[7:4];
                next_state = HOLD;
            end

            HOLD: begin
                // send lower nibble of data_in
                RS   = 1;
                RW   = 0;
                E    = 1;
                data = data_in[3:0];
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
