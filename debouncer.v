module debouncer (
    input  clk,        
    input  rst,        
    input  noisy_btn, 
    output clean_btn   
);

    reg d1, d2, d3;

   //according to what Mahan said , shouldn't this be negedge clk ?
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 0;
            d2 <= 0;
            d3 <= 0;
        end else begin
            d1 <= noisy_btn;
            d2 <= d1;
            d3 <= d2;
        end
    end

    assign clean_btn = d1 & d2 & d3;

endmodule
