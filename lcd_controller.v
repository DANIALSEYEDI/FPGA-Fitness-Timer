module lcd_controller (
    input clk,
    input rst,
    input [3:0] exercise_id,   // انتخاب تمرین (0..9)
    output RS, RW, E,
    output [7:4] data
);

    reg [4:0] char_index;
    wire [7:0] ascii_char;
    reg write_en;

    // Instantiate ROM (باید تعریف exercise_rom رو داشته باشی)
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

    // Slow counter for pacing LCD writes
    reg [23:0] counter;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter    <= 0;
            char_index <= 0;
            write_en   <= 0;
        end else begin
            if (counter == 24'd8_000_000) begin  // ~0.2s delay @40MHz
                counter    <= 0;
                write_en   <= 1;                 // generate a 1-cycle pulse
                char_index <= char_index + 1;
            end else begin
                counter  <= counter + 1;
                write_en <= 0;
            end
        end
    end

    // جلوگیری از خارج شدن از محدوده
    // فرض می‌کنیم ROM برای هر تمرین نهایتاً 16 کاراکتر داره
    always @(posedge clk or posedge rst) begin
        if (rst)
            char_index <= 0;
        else if (char_index == 5'd15 && write_en) // آخر رشته رسیدیم
            char_index <= 0;
    end

endmodule
