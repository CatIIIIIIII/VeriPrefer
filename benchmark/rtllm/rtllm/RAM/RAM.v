
module RAM (
	input clk,
	input rst_n,
	
	input write_en,
	input [7:0]write_addr,
	input [5:0]write_data,
	
	input read_en,
	input [7:0]read_addr,
	output reg [5:0]read_data
);
parameter WIDTH = 6;
parameter DEPTH = 8;

reg [DEPTH-1:0]RAM[2**WIDTH-1:0];

integer i;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<2**WIDTH; i=i+1)
			RAM[i] <= 0;
	end
	else if(write_en)
		RAM[write_addr] <= write_data;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		read_data <= 0;
	else if(read_en)
		read_data <= RAM[read_addr];
	else
		read_data <= 0;
end

endmodule