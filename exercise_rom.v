module exercise_rom (
    input  [3:0] exercise_id,   // Exercise number (0–9)
    input  [4:0] char_index,    // Character index within the exercise name (0–15)
    output reg [7:0] ascii_char // ASCII output
);

    always @(*) begin
        case (exercise_id)
            4'd0: begin // "Lunges R Leg"
                case (char_index)
                    5'd0: ascii_char = "L";
                    5'd1: ascii_char = "u";
                    5'd2: ascii_char = "n";
                    5'd3: ascii_char = "g";
                    5'd4: ascii_char = "e";
                    5'd5: ascii_char = "s";
                    5'd6: ascii_char = " ";
                    5'd7: ascii_char = "R";
                    5'd8: ascii_char = " ";
                    5'd9: ascii_char = "L";
                    5'd10: ascii_char = "e";
                    5'd11: ascii_char = "g";
                    default: ascii_char = " ";
                endcase
            end
            4'd1: begin // "Lunges L Leg"
                case (char_index)
                    5'd0: ascii_char = "L";
                    5'd1: ascii_char = "u";
                    5'd2: ascii_char = "n";
                    5'd3: ascii_char = "g";
                    5'd4: ascii_char = "e";
                    5'd5: ascii_char = "s";
                    5'd6: ascii_char = " ";
                    5'd7: ascii_char = "L";
                    5'd8: ascii_char = " ";
                    5'd9: ascii_char = "L";
                    5'd10: ascii_char = "e";
                    5'd11: ascii_char = "g";
                    default: ascii_char = " ";
                endcase
            end
            4'd2: begin // "Push-Ups"
                case (char_index)
                    5'd0: ascii_char = "P";
                    5'd1: ascii_char = "u";
                    5'd2: ascii_char = "s";
                    5'd3: ascii_char = "h";
                    5'd4: ascii_char = "-";
                    5'd5: ascii_char = "U";
                    5'd6: ascii_char = "p";
                    5'd7: ascii_char = "s";
                    default: ascii_char = " ";
                endcase
            end
            4'd3: begin // "Squat Jumps"
                case (char_index)
                    5'd0: ascii_char = "S";
                    5'd1: ascii_char = "q";
                    5'd2: ascii_char = "u";
                    5'd3: ascii_char = "a";
                    5'd4: ascii_char = "t";
                    5'd5: ascii_char = " ";
                    5'd6: ascii_char = "J";
                    5'd7: ascii_char = "u";
                    5'd8: ascii_char = "m";
                    5'd9: ascii_char = "p";
                    5'd10: ascii_char = "s";
                    default: ascii_char = " ";
                endcase
            end
            4'd4: begin // "Tricep Dips"
                case (char_index)
                    5'd0: ascii_char = "T";
                    5'd1: ascii_char = "r";
                    5'd2: ascii_char = "i";
                    5'd3: ascii_char = "c";
                    5'd4: ascii_char = "e";
                    5'd5: ascii_char = "p";
                    5'd6: ascii_char = " ";
                    5'd7: ascii_char = "D";
                    5'd8: ascii_char = "i";
                    5'd9: ascii_char = "p";
                    5'd10: ascii_char = "s";
                    default: ascii_char = " ";
                endcase
            end
            4'd5: begin // "Mountain Climb"
                case (char_index)
                    5'd0: ascii_char = "M";
                    5'd1: ascii_char = "o";
                    5'd2: ascii_char = "u";
                    5'd3: ascii_char = "n";
                    5'd4: ascii_char = "t";
                    5'd5: ascii_char = "a";
                    5'd6: ascii_char = "i";
                    5'd7: ascii_char = "n";
                    5'd8: ascii_char = " ";
                    5'd9: ascii_char = "C";
                    5'd10: ascii_char = "l";
                    5'd11: ascii_char = "i";
                    5'd12: ascii_char = "m";
                    5'd13: ascii_char = "b";
                    default: ascii_char = " ";
                endcase
            end
            4'd6: begin // "Plank Ladder"
                case (char_index)
                    5'd0: ascii_char = "P";
                    5'd1: ascii_char = "l";
                    5'd2: ascii_char = "a";
                    5'd3: ascii_char = "n";
                    5'd4: ascii_char = "k";
                    5'd5: ascii_char = " ";
                    5'd6: ascii_char = "L";
                    5'd7: ascii_char = "a";
                    5'd8: ascii_char = "d";
                    5'd9: ascii_char = "d";
                    5'd10: ascii_char = "e";
                    5'd11: ascii_char = "r";
                    default: ascii_char = " ";
                endcase
            end
            4'd7: begin // "Wall Sit Hold"
                case (char_index)
                    5'd0: ascii_char = "W";
                    5'd1: ascii_char = "a";
                    5'd2: ascii_char = "l";
                    5'd3: ascii_char = "l";
                    5'd4: ascii_char = " ";
                    5'd5: ascii_char = "S";
                    5'd6: ascii_char = "i";
                    5'd7: ascii_char = "t";
                    5'd8: ascii_char = " ";
                    5'd9: ascii_char = "H";
                    5'd10: ascii_char = "o";
                    5'd11: ascii_char = "l";
                    5'd12: ascii_char = "d";
                    default: ascii_char = " ";
                endcase
            end
            4'd8: begin // "Plank Hold"
                case (char_index)
                    5'd0: ascii_char = "P";
                    5'd1: ascii_char = "l";
                    5'd2: ascii_char = "a";
                    5'd3: ascii_char = "n";
                    5'd4: ascii_char = "k";
                    5'd5: ascii_char = " ";
                    5'd6: ascii_char = "H";
                    5'd7: ascii_char = "o";
                    5'd8: ascii_char = "l";
                    5'd9: ascii_char = "d";
                    default: ascii_char = " ";
                endcase
            end
            4'd9: begin // "Burpees"
                case (char_index)
                    5'd0: ascii_char = "B";
                    5'd1: ascii_char = "u";
                    5'd2: ascii_char = "r";
                    5'd3: ascii_char = "p";
                    5'd4: ascii_char = "e";
                    5'd5: ascii_char = "e";
                    5'd6: ascii_char = "s";
                    default: ascii_char = " ";
                endcase
            end
            default: ascii_char = " ";
        endcase
    end

endmodule
