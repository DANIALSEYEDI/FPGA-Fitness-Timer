module lcd_controller (
    input clk,
    input rst,
    input [3:0] exercise_id,
    output RS, RW, E,
    output [7:4] data
);

    reg [4:0] char_index;
    wire [7:0] ascii_char;
    reg write_en;

    // Instantiate ROM
    exercise_rom rom_inst (
        .exercise_id(exercise_id),
        .char_index(char_index),
        .ascii_char(ascii_char)
    );

    // Instantiate LCD Driver
    lcd_driver lcd_inst (
        .clk(clk),
        .rst(rst),
        .data_in(ascii_char),
        .write_en(write_en),
        .RS(RS), .RW(RW), .E(E), .data(data)
    );

    // Simple state machine to cycle through chars
    reg [23:0] counter; // slow down updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            char_index <= 0;
            write_en <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 24'd8_000_000) begin // ~0.2 sec at 40MHz
                write_en <= 1;
                char_index <= char_index + 1;
                counter <= 0;
            end else begin
                write_en <= 0;
            end
        end
    end

endmodule
