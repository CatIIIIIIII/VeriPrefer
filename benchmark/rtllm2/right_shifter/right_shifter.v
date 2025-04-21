module right_shifter(clk, q,d);  

    input  clk;  
    input d;  
    output  [7:0] q;  
reg [7:0] q;  

    initial begin  
        q = 8'b0;  
    end  

    always @(posedge clk) begin  
        q <= {d, q[7:1]};  
    end  

endmodule