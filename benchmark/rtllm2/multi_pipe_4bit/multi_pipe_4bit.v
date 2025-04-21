module multi_pipe_4bit#(
	parameter size = 4
)(
	input 						clk 		,   
	input 						rst_n		,
	input	[size-1:0]			mul_a		,
	input	[size-1:0]			mul_b		,
 
 	output	reg	[size*2-1:0]	mul_out		
);

parameter N = 2 * size;
wire [N-1:0] mul_a_ext, mul_b_ext;
	assign mul_a_ext = {{size{1'b0}}, mul_a};
	assign mul_b_ext = {{size{1'b0}}, mul_b};

	wire [N-1:0] partial_products [size-1:0];
	genvar i;
	generate
		for (i = 0; i < size; i = i + 1) begin : gen_partial_products
			assign partial_products[i] = mul_b_ext[i] ? (mul_a_ext << i) : 'd0;
		end
	endgenerate

	reg [N-1:0] add_reg [1:0];
	integer j;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (j = 0; j < 2; j = j + 1) begin
				add_reg[j] <= 'd0;
			end
		end else begin
			add_reg[0] <= partial_products[0] + partial_products[1];
			add_reg[1] <= partial_products[2] + partial_products[3];
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			mul_out <= 'd0;
		end else begin
			mul_out <= add_reg[0] + add_reg[1];
		end
	end

endmodule