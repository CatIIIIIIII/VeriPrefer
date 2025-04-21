
module top_module(
    input clk,
    input load,
    input ena,
    input [1:0] amount,
    input [63:0] data,
    output reg [63:0] q
);

always @(posedge clk) begin
    if (load) begin
        // Load the shift register with data
        q <= data;
    end else if (ena) begin
        // Perform the shift based on the amount
        case (amount)
            2'b00: q <= q << 1;          // Shift left by 1 bit
            2'b01: q <= q << 8;          // Shift left by 8 bits
            2'b10: q <= $signed(q) >>> 1; // Arithmetic right shift by 1 bit
            2'b11: q <= $signed(q) >>> 8; // Arithmetic right shift by 8 bits
            default: q <= q;              // No shift
        endcase
    end
end

endmodule
