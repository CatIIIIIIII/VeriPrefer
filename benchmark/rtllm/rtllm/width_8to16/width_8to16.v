
module width_8to16(
	input 				   clk 		,   
	input 				   rst_n		,
	input				      valid_in	,
	input	   [7:0]		   data_in	,
 
 	output	reg			valid_out,
	output   reg [15:0]	data_out
);

reg 	[7:0]		data_lock;  
reg 				flag	   ;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		flag <= 0;
	end
	else if(valid_in)begin
		flag <= !flag;
	end
	else begin
		flag <= flag;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		data_lock <= 8'd0;
	end
	else if(valid_in && flag)begin
		data_lock <= data_in;
	end
	else begin
		data_lock <= data_lock;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		valid_out <= 0;
	end
	else if(valid_in && !flag)begin
		valid_out <= 1;
	end
	else begin
		valid_out <= 0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		data_out <= 16'd0;
	end
	else if(valid_in && !flag)begin
		data_out <= {data_lock,data_in};
	end
	else begin
		data_out <= data_out;
	end
end

endmodule