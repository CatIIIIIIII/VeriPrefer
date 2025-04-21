module asyn_fifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					wclk	, 
	input 					rclk	,   
	input 					wrstn	,
	input					rrstn	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output wire				wfull	,
	output wire				rempty	,
	output wire [WIDTH-1:0]	rdata
);

parameter ADDR_WIDTH = $clog2(DEPTH);

reg [ADDR_WIDTH-1:0] waddr_bin, raddr_bin;
reg [ADDR_WIDTH:0] wptr, rptr;
reg [ADDR_WIDTH:0] wptr_buff, rptr_buff;
wire [ADDR_WIDTH:0] rptr_syn;

wire wen, ren;

always @(posedge wclk or negedge wrstn) begin
	if (!wrstn) begin
		waddr_bin <= 0;
		wptr <= 0;
	end else if (winc) begin
		waddr_bin <= waddr_bin + 1;
		wptr <= wptr + 1;
	end
end

always @(posedge rclk or negedge rrstn) begin
	if (!rrstn) begin
		raddr_bin <= 0;
		rptr <= 0;
	end else if (rinc) begin
		raddr_bin <= raddr_bin + 1;
		rptr <= rptr + 1;
	end
end

always @(posedge wclk or negedge wrstn) begin
	if (!wrstn)
		wptr_buff <= 0;
	else
		wptr_buff <= wptr;
end

always @(posedge rclk or negedge rrstn) begin
	if (!rrstn)
		rptr_buff <= 0;
	else
		rptr_buff <= rptr;
end

assign rptr_syn = rptr_buff;

assign wen = winc & (~wfull);
assign ren = rinc & (~rempty);

dual_port_RAM #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
) ram_inst (
	.wclk(wclk),
	.rclk(rclk),
	.wenc(wen),
	.waddr(waddr_bin[ADDR_WIDTH-2:0]),
	.wdata(wdata),
	.renc(ren),
	.raddr(raddr_bin[ADDR_WIDTH-2:0]),
	.rdata(rdata)
);

assign wfull = (wptr[ADDR_WIDTH] != rptr_syn[ADDR_WIDTH]) && 
			   (wptr[ADDR_WIDTH-1:0] == rptr_syn[ADDR_WIDTH-1:0]);

assign rempty = (rptr == wptr_buff);

endmodule

module dual_port_RAM #(
	parameter WIDTH = 8,
	parameter DEPTH = 16
)(
	input wclk,
	input rclk,
	input wenc,
	input [$clog2(DEPTH)-1:0] waddr,
	input [WIDTH-1:0] wdata,
	input renc,
	input [$clog2(DEPTH)-1:0] raddr,
	output reg [WIDTH-1:0] rdata
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if (wenc)
		RAM_MEM[waddr] <= wdata;
end

always @(posedge rclk) begin
	if (renc)
		rdata <= RAM_MEM[raddr];
end

endmodule