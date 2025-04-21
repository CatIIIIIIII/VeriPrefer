
module top_module(
    input clk,
    input reset,
    output [3:1] ena,
    output reg [15:0] q
);

// Internal signals for carry propagation
reg [3:1] carry;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 16'b0000_0000_0000_0000; // Initialize all digits to 0
        ena <= 3'b000; // No enable signals active
        carry <= 3'b000; // No carry signals active
    end else begin
        // Increment the ones digit
        if (q[3:0] == 4'b1001) begin
            q[3:0] <= 4'b0000;
            carry[1] <= 1'b1;
        end else begin
            q[3:0] <= q[3:0] + 1;
            carry[1] <= 1'b0;
        end

        // Increment the tens digit
        if (carry[1] || q[7:4] == 4'b1001) begin
            q[7:4] <= 4'b0000;
            carry[2] <= 1'b1;
        end else begin
            q[7:4] <= q[7:4] + 1;
            carry[2] <= 1'b0;
        end

        // Increment the hundreds digit
        if (carry[2] || q[11:8] == 4'b1001) begin
            q[11:8] <= 4'b0000;
            carry[3] <= 1'b1;
        end else begin
            q[11:8] <= q[11:8] + 1;
            carry[3] <= 1'b0;
        end

        // Increment the thousands digit
        if (carry[3] || q[15:12] == 4'b1001) begin
            q[15:12] <= 4'b0000;
        end else begin
            q[15:12] <= q[15:12] + 1;
        end

        // Set enable signals for upper three digits
        ena[1] <= carry[1];
        ena[2] <= carry[2];
        ena[3] <= carry[3];
    end
end

endmodule
