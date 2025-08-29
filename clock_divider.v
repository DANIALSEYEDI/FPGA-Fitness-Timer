module clock_divider (
    input  wire clk_in,     // 40MHz input clock
    input  wire reset,      // async reset
    output reg clk_1Hz,     // 1Hz clock for timer
    output reg clk_500Hz,   // 500Hz for 7-seg
    output reg clk_1kHz,    // 1kHz optional
    output reg clk_2kHz     // 2kHz for buzzer
);

    // Counters
    reg [24:0] count_1Hz;     // needs up to 20M
    reg [15:0] count_500Hz;   // needs up to 40k
    reg [15:0] count_1kHz;    // needs up to 20k
    reg [15:0] count_2kHz;    // needs up to 10k

    always @(posedge clk_in or posedge reset) begin //shouldn't reset always be negedge?
        if (reset) begin
            clk_1Hz   <= 0;
            clk_500Hz <= 0;
            clk_1kHz  <= 0;
            clk_2kHz  <= 0;
            count_1Hz   <= 0;
            count_500Hz <= 0;
            count_1kHz  <= 0;
            count_2kHz  <= 0;
        end else begin
            // 1Hz clock
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
