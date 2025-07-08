`timescale 1ns/1ps
module tb_logic_circuit;

    reg  [7:0] input_bits;
    wire [7:0] T3;

    combinational_circuit uut (
        .input_bits(input_bits),
        .T3(T3)
    );

    integer infile, outfile;
    reg [7:0] in_val;
    integer status;

    initial begin
        infile  = $fopen("input.txt", "r");
        outfile = $fopen("output.txt", "w");

        if (infile == 0 || outfile == 0) begin
            $display("Error opening input or output file.");
            $finish;
        end

        while (!$feof(infile)) begin
            status = $fscanf(infile, "%b\\n", in_val);
            if (status == 1) begin
                input_bits = in_val;
                #10;
                $fwrite(outfile, "%0d\n", T3);
            end else begin
                $display("Invalid input format.");
            end
        end

        $fclose(infile);
        $fclose(outfile);
        $display("Simulation finished.");
        $finish;
    end

endmodule

