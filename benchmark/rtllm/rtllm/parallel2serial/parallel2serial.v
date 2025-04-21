
module parallel2serial(
	input wire clk  ,
	input wire rst_n  ,
	input wire [3:0]d ,
	output wire valid_out ,
	output wire dout
	);
	reg [1:0]cnt;
	reg [3:0]data;
	reg valid;

	assign valid_out = valid;
	assign dout = data[3];

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			cnt <= 2'd0;
			data <= 4'd0;
			valid <= 1'b0;
		end
		else if(cnt == 2'd3)begin
			cnt <= 2'd0;
			data <= d;
			valid <= 1'b1;
		end
		else begin
			cnt <= cnt + 2'd1;
			valid <= 1'b0;
			data <= {data[2:0],data[3]};
		end
	end

endmodule