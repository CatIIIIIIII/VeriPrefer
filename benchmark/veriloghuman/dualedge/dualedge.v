
module top_module(
    input clk,
    input d,
    output reg q
);

    reg q1, q2;

    // Capture data on the rising edge of the clock
    always @(posedge clk) begin
        q1 <= d;
    end

    // Capture data on the falling edge of the clock
    always @(negedge clk) begin
        q2 <= d;
    end

    // Combine the results from both flip-flops
    always @(posedge clk or negedge clk) begin
        if (clk) begin
            q <= q1;  // On rising edge, use q1
        end else begin
            q <= q2;  // On falling edge, use q2
        end
    end

endmodule
