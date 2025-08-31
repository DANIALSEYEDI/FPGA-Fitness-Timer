module lcd_driver (
    input clk,           // 40MHz clock
    input rst,           // reset
    input [7:0] data_in, // ASCII character from ROM
    input write_en,      // enable writing new character
    output reg RS, RW, E,
    output reg [7:4] data // 4-bit data bus (D4-D7)
);

    // ================== STATE ENCODING ==================
    parameter INIT  = 3'b000;
    parameter IDLE  = 3'b001;
    parameter WRITE = 3'b010;
    parameter HOLD  = 3'b011;

    reg [2:0] state, next_state;

    // ================== CLOCK DIVIDER ==================
    reg [15:0] clk_div;   
    wire slow_clk = clk_div[15]; // ~610 Hz from 40MHz

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // ================== FSM STATE REGISTER ==================
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
            RS    <= 0;
            RW    <= 0;
            E     <= 0;
            data  <= 4'b0000;
        end else begin
            state <= next_state;
        end
    end

    // ================== FSM NEXT-STATE + OUTPUT LOGIC ==================
    always @(*) begin
        // default values
        RS = 0; 
        RW = 0; 
        E  = 0; 
        data = 4'b0000;
        next_state = IDLE;

        case (state)
            INIT: begin
                // Send clear display command
                RS = 0; RW = 0; E = 1;
                data = 4'b0001;  
                next_state = IDLE;
            end

            IDLE: begin
                E = 0;
                if (write_en)
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end

            WRITE: begin
                RS = 1; RW = 0; E = 1;
                data = data_in[7:4]; // upper nibble
                next_state = HOLD;
            end

            HOLD: begin
                RS = 1; RW = 0; E = 0;
                data = data_in[3:0]; // lower nibble
                next_state = IDLE;
            end
        endcase
    end

endmodule

