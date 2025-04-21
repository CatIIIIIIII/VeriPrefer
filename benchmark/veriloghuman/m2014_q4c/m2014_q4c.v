
module top_module (
    input clk,
    input d,
    input r,
    output logic q
);

always_ff @(posedge clk or posedge r) begin
    if (r) begin
        q <= 0;  // Reset output to 0 on active-high reset
    end else begin
        q <= d;  // Update output with data input on clock edge
    end
end

endmodule
