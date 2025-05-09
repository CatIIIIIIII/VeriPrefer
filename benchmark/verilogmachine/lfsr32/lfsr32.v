
module top_module(
    input clk,
    input reset,
    output reg [31:0] q
);

reg [31:0] q_next;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 32'h1;
    end else begin
        q <= q_next;
    end
end

always @(*) begin
    q_next = {q[30:0], q[31]}; // Shift left by 1 bit
    q_next[0] = q_next[0] ^ q[21] ^ q[1] ^ q[0]; // XOR operation
end

endmodule
