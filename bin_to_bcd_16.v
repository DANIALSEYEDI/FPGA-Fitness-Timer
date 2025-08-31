module bin_to_bcd_16 (
    input  [15:0] bin,
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    integer i;
    reg [31:0] shift_reg;

    always @(*) begin
        // initialize
        shift_reg = {16'b0, bin};
        thousands = 0; hundreds = 0; tens = 0; ones = 0;

        // shift 16 times
        for (i=0; i<16; i=i+1) begin
            if (thousands >= 5) thousands = thousands + 3;
            if (hundreds  >= 5) hundreds  = hundreds + 3;
            if (tens      >= 5) tens      = tens + 3;
            if (ones      >= 5) ones      = ones + 3;

            {thousands, hundreds, tens, ones, shift_reg} =
                {thousands, hundreds, tens, ones, shift_reg} << 1;
        end
    end
endmodule
