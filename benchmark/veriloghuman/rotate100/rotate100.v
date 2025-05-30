
module top_module(
    input clk,
    input load,
    input [1:0] ena,
    input [99:0] data,
    output reg [99:0] q
);

always @(posedge clk) begin
    if (load) begin
        // Load the shift register with data[99:0]
        q <= data;
    end else begin
        case (ena)
            2'b01: begin
                // Rotate right by one bit
                q <= {q[0], q[99:1]};
            end
            2'b10: begin
                // Rotate left by one bit
                q <= {q[98:0], q[99]};
            end
            default: begin
                // Do not rotate
                q <= q;
            end
        endcase
    end
end

endmodule
