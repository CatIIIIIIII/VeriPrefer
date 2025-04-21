
module top_module (
    input clk,
    input w,
    input R,
    input E,
    input L,
    output reg Q
);

    reg next_Q;

    // Multiplexer to select the input to the flip-flop
    always @(*) begin
        if (L) begin
            // Load mode: select the value to load (R)
            next_Q = R;
        end else if (E) begin
            // Shift mode: select the input from the previous stage (w)
            next_Q = w;
        end else begin
            // Hold the current value
            next_Q = Q;
        end
    end

    // Flip-flop to store the value
    always @(posedge clk) begin
        Q <= next_Q;
    end

endmodule
