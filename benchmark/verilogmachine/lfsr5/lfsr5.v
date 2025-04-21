
module top_module(
    input clk,
    input reset,
    output reg [4:0] q
);

    reg [4:0] q_next;

    // First always block to define the state transition of q
    always @(q) begin
        q_next = q[4:1]; // Assign q_next with q except the LSB bit
        q_next[4] = q[0]; // Assign q_next[4] with q[0]
        q_next[2] = q_next[2] ^ q[0]; // XOR q_next[2] with q[0]
    end

    // Second always block triggered at positive edge of clk
    always @(posedge clk) begin
        if (reset) begin
            q <= 5'h1; // Assign q with reset value 5'h1
        end else begin
            q <= q_next; // Assign q with q_next
        end
    end

endmodule
