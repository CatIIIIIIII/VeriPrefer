module adder_bcd (
    input  [3:0] A,   // First BCD number (0-9)
    input  [3:0] B,   // Second BCD number (0-9)
    input  Cin,       // Input carry
    output [3:0] Sum, // BCD sum (0-9)
    output Cout       // Output carry
);
reg [4:0] result;  // Temporary register to store addition result

    always @(*) begin
        // Perform binary addition
        result = A + B + Cin;

        // Apply BCD correction if sum is greater than 9
        if (result > 9) begin
            result = result + 6;  // Add 6 (0110) to correct the result
        end
    end

    // Assign outputs
    assign Sum = result[3:0];  // Assign the 4 least significant bits as the sum
    assign Cout = result[4];   // Assign the most significant bit as the carry-out

endmodule