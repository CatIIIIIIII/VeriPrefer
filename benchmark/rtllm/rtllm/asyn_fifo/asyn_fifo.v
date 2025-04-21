
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



	`define MSB_DEPTH ((DEPTH>16)?((DEPTH>64)?((DEPTH>128)?8:7):((DEPTH>32)?6:5)):((DEPTH>4)?((DEPTH>8)?4:3):((DEPTH>2)?2:1)))

	wire [DEPTH-1:0]			buffer_wfull		;
	wire [DEPTH-1:0]			buffer_rempty	;
	wire [DEPTH-1:0]			buffer_wptr		;
	wire [DEPTH-1:0]			buffer_rptr		;
	reg 	[DEPTH-1:0]			rptr			;
	reg 	[DEPTH-1:0]			wptr			;
	reg 	[DEPTH-1:0]			rptr_buff		;
	reg 	[DEPTH-1:0]			wptr_buff		;
	reg 	[WIDTH-1:0]			RAM_MEM [DEPTH-1:0];

	always@(posedge wclk or negedge wrstn)begin
		if(!wrstn)begin
			wptr <= 'd0;
		end else begin
			wptr <= wptr + winc;
		end
	end

	always@(posedge rclk or negedge rrstn)begin
		if(!rrstn)begin
			rptr <= 'd0;
		end else begin
			rptr <= rptr + rinc;
		end
	end

	assign buffer_wptr = (wptr >> 1) ^ wptr;
	assign buffer_rptr = (rptr >> 1) ^ rptr;

	always@(posedge wclk or negedge wrstn)begin
		if(!wrstn)begin
			wptr_buff <= 'd0;
		end else begin
			wptr_buff <= buffer_wptr;
		end
	end

	always@(posedge rclk or negedge rrstn)begin
		if(!rrstn)begin
			rptr_buff <= 'd0;
		end else begin
			rptr_buff <= buffer_rptr;
		end
	end

	assign buffer_wfull = {~wptr_buff[`MSB_DEPTH],wptr_buff[`MSB_DEPTH-1:0]};
	assign buffer_rempty = rptr_buff;

	assign wfull = (buffer_wfull == {~rptr[`MSB_DEPTH],rptr[`MSB_DEPTH-1:0]});
	assign rempty = (buffer_rempty == wptr);

	always@(posedge wclk)begin
		if(wenc)begin
			RAM_MEM[waddr] <= wdata;
		end
	end

	assign rdata = RAM_MEM[raddr];

endmodule