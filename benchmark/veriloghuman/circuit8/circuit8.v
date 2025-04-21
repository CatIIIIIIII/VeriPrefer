
module top_module (
	input clock,
	input a, 
	output reg p,
	output reg q
);

always @(posedge clock or negedge a) begin
    if (!a) begin
        p <= 0;
        q <= 1;
    end else begin
        p <= a;
        q <= ~a;
    end
end

endmodule
