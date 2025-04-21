
module multi_pipe_4bit#(
	parameter size = 4
)(
	input 						clk 		,   
	input 						rst_n		,
	input	[size-1:0]			mul_a		,
	input	[size-1:0]			mul_b		,
 
 	output	reg	[size*2-1:0]	mul_out		
);
wire [size*2-1:0] mul_a_extend;
assign mul_a_extend = {{size{1'b0}},mul_a};

wire [size*2-1:0] mul_b_extend;
assign mul_b_extend = {{size{1'b0}},mul_b};

genvar i;
generate
	for(i=0;i<size;i=i+1)begin:multi
		wire [size*2-1:0] mul_tmp;
		assign mul_tmp = mul_b_extend[i] ? mul_a_extend << i : 'd0;
	end
endgenerate

reg [size*2-1:0] add_reg [size-1:0];
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		add_reg[0] <= 'd0;
	end
	else begin
		add_reg[0] <= multi[0].mul_tmp;
	end
end

generate
	for(i=1;i<size;i=i+1)begin:add
		always@(posedge clk or negedge rst_n)begin
			if(!rst_n)begin
				add_reg[i] <= 'd0;
			end
			else begin
				add_reg[i] <= add_reg[i-1] + multi[i].mul_tmp;
			end
		end
	end
endgenerate

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		mul_out <= 'd0;
	end
	else begin
		mul_out <= add_reg[size-1];
	end
end

endmodule