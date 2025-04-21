module comparator_4bit(
    input [3:0] A,   // First 4-bit input operand
    input [3:0] B,   // Second 4-bit input operand
    output A_greater, 
    output A_equal,   
    output A_less     
);
wire [4:0] diff;  // 5-bit difference to capture borrow

    // Perform subtraction
    assign diff = {1'b0, A} - {1'b0, B};

    // Generate outputs
    assign A_greater = ~diff[4] & |diff[3:0];
    assign A_equal   = ~|diff[3:0];
    assign A_less    = diff[4];

endmodule