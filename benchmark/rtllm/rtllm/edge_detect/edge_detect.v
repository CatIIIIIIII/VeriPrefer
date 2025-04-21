
module edge_detect(
	input clk,
	input rst_n,
	input a,
	
	output reg rise,
	output reg down
);
reg a_d1;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        a_d1 <= 1'b0;
    else
        a_d1 <= a;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rise <= 1'b0;
    else if(a == 1'b1 && a_d1 == 1'b0)
        rise <= 1'b1;
    else
        rise <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        down <= 1'b0;
    else if(a == 1'b0 && a_d1 == 1'b1)
        down <= 1'b1;
    else
        down <= 1'b0;
end

endmodule