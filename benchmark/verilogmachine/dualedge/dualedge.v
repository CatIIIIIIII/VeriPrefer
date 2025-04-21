
module top_module(
    input clk,
    input d,
    output reg q
);

    reg qp, qn;

    // Update qp on the rising edge of clk
    always @(posedge clk) begin
        qp <= d;
    end

    // Update qn on the falling edge of clk
    always @(negedge clk) begin
        qn <= d;
    end

    // Assign q based on the current state of clk
    always @(posedge clk or negedge clk) begin
        if (clk) begin
            q <= qp;
        end else begin
            q <= qn;
        end
    end

endmodule
