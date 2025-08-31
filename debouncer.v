module debouncer (
    input  clk,        
    input  rst,        
    input  noisy_btn, 
    //this module will be instantiated 3 times for 3 different buttons
    output clean_btn   
);

    reg d1, d2, d3;

   //according to what Mahan said , shouldn't this be negedge clk ?
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 0;
            d2 <= 0;
            d3 <= 0;
            //again according to Mahan , shouldn't these be set to 1 initially ?
        end else begin
            d1 <= noisy_btn;
            d2 <= d1;
            d3 <= d2;
        end
    end

    assign clean_btn = d1 & d2 & d3;

endmodule
