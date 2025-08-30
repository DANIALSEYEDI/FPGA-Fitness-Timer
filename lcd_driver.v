module lcd_driver (
    input clk,           // 40MHz clock
    input rst,           // reset
    input [7:0] data_in, // ASCII character from ROM
    input write_en,      // enable writing new character
    output reg RS, RW, E,
    output reg [7:4] data // 4-bit data bus (D4-D7)
);

    // FSM states
    typedef enum reg [2:0] {
        INIT, IDLE, WRITE, HOLD
    } state_t;

    state_t state, next_state;

    reg [15:0] clk_div;   // slow down 40MHz clock
    wire slow_clk = clk_div[15]; // ~610Hz

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // FSM
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
            RS <= 0;
            RW <= 0;
            E  <= 0;
            data <= 4'b0000;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            INIT: begin
                // simple init command: clear display
                RS = 0; RW = 0; E = 1;
                data = 4'b0001; // clear command
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
                data = data_in[7:4]; // send upper nibble
                next_state = HOLD;
            end
            HOLD: begin
                RS = 1; RW = 0; E = 0;
                data = data_in[3:0]; // send lower nibble
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule
