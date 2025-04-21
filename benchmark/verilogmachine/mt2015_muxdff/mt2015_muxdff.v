
module top_module(
    input clk,
    input L,
    input q_in,
    input r_in,
    output reg Q
);

    // Initialize the output register Q to 0
    initial begin
        Q = 0;
    end

    // Combinational logic to update Q on the rising edge of the clock
    always @(posedge clk) begin
        if (L) begin
            Q <= r_in;  // Set Q to r_in if L is high
        end else begin
            Q <= q_in;  // Set Q to q_in if L is low
        end
    end

endmodule
