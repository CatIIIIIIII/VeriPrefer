module sub_64bit(
  input [63:0] A,
  input [63:0] B,
  output reg [63:0] result,
  output reg overflow
);
wire [63:0] B_complement;
  wire [64:0] sum;

  // Generate two's complement of B
  assign B_complement = ~B + 1'b1;

  // Perform subtraction using addition
  assign sum = {A[63], A} + {B_complement[63], B_complement};

  always @(*) begin
    // Assign result
    result = sum[63:0];

    // Overflow detection
    if ((A[63] == 1'b0 && B[63] == 1'b1 && result[63] == 1'b1) ||
        (A[63] == 1'b1 && B[63] == 1'b0 && result[63] == 1'b0)) begin
      overflow = 1'b1;
    end else begin
      overflow = 1'b0;
    end
  end

endmodule