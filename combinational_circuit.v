module combinational_circuit (
    input  [7:0] input_bits,
    output [7:0] T3
);

    wire w2 = input_bits[7];
    wire w1 = input_bits[6];
    wire w0 = input_bits[5];
    wire c1 = input_bits[4];
    wire c0 = input_bits[3];
    wire M1 = input_bits[2];
    wire M0 = input_bits[1];
    wire G  = input_bits[0];

    wire [7:0] T1;

    assign T1[0] = (~w2 & ~c1 & c0 & w1 & w0) | (c1 & c0 & w1 & ~w0) | (~w2 & ~c0 & w1 & ~w0) | (w2 & c0 & ~w0) | (w2 & ~c1 & ~w0) | (w2 & ~c0 & w1 & w0);
    assign T1[1] = (~w2 & c0 & w1) | (~w2 & ~c1 & w1) | (~c1 & c0 & w1) | (~c0 & ~w1 & w0) | (w2 & ~c1 & c0 & ~w0) | (w2 & c1 & ~c0 & w1) | (w2 & ~c0 & w1 & ~w0);
    assign T1[2] = (~c1 & c0 & ~w1 & w0) | (c1 & c0 & w1 & w0) | (~c1 & c0 & w1 & ~w0) | (~w2 & c1 & ~c0 & ~w1 ) | (~w2 & ~c0 & ~w1 & ~w0) | (~w2 & ~c1 & ~c0 & w1 & w0) | (w2 & c1 & ~w1 & ~w0) | (w2 & c0 & w1 & ~w0) | (w2 & ~c1 & ~w1 & w0);
    assign T1[3] = (w2 & ~w1 & w0 ) | (w2 & ~c0 & w1 & w0 ) | (c1 & c0 & ~w1 & w0) | (c1 & c0 & w1 & ~w0) | (~c1 & ~c0 & w1 & ~w0) | (~w2 & ~c1 & c0 & w1 & w0) | (~w2 & ~c1 & ~w1 & ~w0);
    assign T1[4] = (~c0 & ~w2 & ~w1) | (~w2 & ~w1 & ~w0) | (~c1 & c0 & w1 & ~w0) | (~c0 & w2 & w1 & ~w0 ) | (c1 & ~w2 & w1 & w0 ) | (~c1 & w2 & w0) | (w2 & ~w1 & w0);
    assign T1[5] = (~c1 & ~c0 & ~w2) | (~w2 & ~w1 & ~w0) | (~c1 & ~w2 & ~w1 ) | (c1 & c0 & ~w2 & ~w0 ) | (c0 & w2 & w1) | (~c0 & w2 & ~w1 & ~w0) | (~c0 & ~w2 & w1 & w0) | (c0 & w2 & w0);
    assign T1[6] = (~c1 & c0 & ~w2) | (~c1 & c0 & ~w1 & ~w0) | (c0 & ~w2 & ~w1) | (c1 & w2 & w1) | (c1 & w2 & w0) | (c1 & ~c0 & w2) | (c1 & ~c0 & w1 & w0);
    assign T1[7] = (c1 & c0 & ~w2) | (c1 & ~w2 & ~w0)  | (c1 & ~w2 & ~w1) | (c1 & c0 & ~w1 & ~w0);

    wire [7:0] T1_shifted = {3'b000, T1[7:3]};
    wire [7:0] T1_woman;
    wire [8:0] carry;
    assign carry[0] = 0;

    full_adder fa0 (.a(T1[0]), .b(T1_shifted[0]), .cin(carry[0]), .sum(T1_woman[0]), .cout(carry[1]));
    full_adder fa1 (.a(T1[1]), .b(T1_shifted[1]), .cin(carry[1]), .sum(T1_woman[1]), .cout(carry[2]));
    full_adder fa2 (.a(T1[2]), .b(T1_shifted[2]), .cin(carry[2]), .sum(T1_woman[2]), .cout(carry[3]));
    full_adder fa3 (.a(T1[3]), .b(T1_shifted[3]), .cin(carry[3]), .sum(T1_woman[3]), .cout(carry[4]));
    full_adder fa4 (.a(T1[4]), .b(T1_shifted[4]), .cin(carry[4]), .sum(T1_woman[4]), .cout(carry[5]));
    full_adder fa5 (.a(T1[5]), .b(T1_shifted[5]), .cin(carry[5]), .sum(T1_woman[5]), .cout(carry[6]));
    full_adder fa6 (.a(T1[6]), .b(T1_shifted[6]), .cin(carry[6]), .sum(T1_woman[6]), .cout(carry[7]));
    full_adder fa7 (.a(T1[7]), .b(T1_shifted[7]), .cin(carry[7]), .sum(T1_woman[7]), .cout(carry[8]));

    wire [7:0] T2;
    assign T2[0] = (~G & T1[0]) | (G & T1_woman[0]);
    assign T2[1] = (~G & T1[1]) | (G & T1_woman[1]);
    assign T2[2] = (~G & T1[2]) | (G & T1_woman[2]);
    assign T2[3] = (~G & T1[3]) | (G & T1_woman[3]);
    assign T2[4] = (~G & T1[4]) | (G & T1_woman[4]);
    assign T2[5] = (~G & T1[5]) | (G & T1_woman[5]);
    assign T2[6] = (~G & T1[6]) | (G & T1_woman[6]);
    assign T2[7] = (~G & T1[7]) | (G & T1_woman[7]);

    wire [7:0] shift0 = T2;
    wire [7:0] shift1 = {1'b0, T2[7:1]};
    wire [7:0] shift2 = {2'b00, T2[7:2]};
    wire [7:0] shift3 = {3'b000, T2[7:3]};

    mux4x1 mux0 (.in0(shift0[0]), .in1(shift1[0]), .in2(shift2[0]), .in3(shift3[0]), .sel({M1, M0}), .out(T3[0]));
    mux4x1 mux1 (.in0(shift0[1]), .in1(shift1[1]), .in2(shift2[1]), .in3(shift3[1]), .sel({M1, M0}), .out(T3[1]));
    mux4x1 mux2 (.in0(shift0[2]), .in1(shift1[2]), .in2(shift2[2]), .in3(shift3[2]), .sel({M1, M0}), .out(T3[2]));
    mux4x1 mux3 (.in0(shift0[3]), .in1(shift1[3]), .in2(shift2[3]), .in3(shift3[3]), .sel({M1, M0}), .out(T3[3]));
    mux4x1 mux4 (.in0(shift0[4]), .in1(shift1[4]), .in2(shift2[4]), .in3(shift3[4]), .sel({M1, M0}), .out(T3[4]));
    mux4x1 mux5 (.in0(shift0[5]), .in1(shift1[5]), .in2(shift2[5]), .in3(shift3[5]), .sel({M1, M0}), .out(T3[5]));
    mux4x1 mux6 (.in0(shift0[6]), .in1(shift1[6]), .in2(shift2[6]), .in3(shift3[6]), .sel({M1, M0}), .out(T3[6]));
    mux4x1 mux7 (.in0(shift0[7]), .in1(shift1[7]), .in2(shift2[7]), .in3(shift3[7]), .sel({M1, M0}), .out(T3[7]));

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
    wire n0, n1, s0, s1, s2, s3;
    not (n0, sel[0]);
    not (n1, sel[1]);
    and (s0, n1, n0, in0);
    and (s1, n1, sel[0], in1);
    and (s2, sel[1], n0, in2);
    and (s3, sel[1], sel[0], in3);
    or  (out, s0, s1, s2, s3);
endmodule