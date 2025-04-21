
module top_module(
    input clk,
    input resetn,
    input [1:0] byteena,
    input [15:0] d,
    output reg [15:0] q
);

// Upper byte flip-flops
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        q[15:8] <= 8'b0;
    end else if (byteena[1]) begin
        q[15:8] <= d[15:8];
    end
end

// Lower byte flip-flops
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        q[7:0] <= 8'b0;
    end else if (byteena[0]) begin
        q[7:0] <= d[7:0];
    end
end

endmodule
