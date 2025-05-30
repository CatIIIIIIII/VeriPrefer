
module top_module (
    input clk,
    input resetn,
    input in,
    output out
);

    reg [3:0] sr;  // 4-bit register to store the data

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset the register to all zeros when resetn is low
            sr <= 4'b0000;
        end else begin
            // Shift the register left by one bit and load the input into the least significant bit
            sr <= {sr[2:0], in};
        end
    end

    // Output is taken from the most significant bit of the register
    assign out = sr[3];

endmodule
