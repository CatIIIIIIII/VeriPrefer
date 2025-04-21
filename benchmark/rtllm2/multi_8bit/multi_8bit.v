module multi_8bit (
  input [7:0] A,
  input [7:0] B,
  output reg [15:0] product
);
reg [7:0] multiplicand;
  reg [7:0] multiplier;
  reg [15:0] temp_product;
  integer i;

  always @(*) begin
    multiplicand = A;
    multiplier = B;
    temp_product = 16'b0;

    for (i = 0; i < 8; i = i + 1) begin
      if (multiplier[0])
        temp_product = temp_product + (multiplicand << i);
      multiplier = multiplier >> 1;
    end

    product = temp_product;
  end

endmodule