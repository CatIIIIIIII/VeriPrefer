
module top_module (
    input a, 
    input b,
    input c,
    input d,
    output reg out
);

    // Combine inputs into a single 4-bit vector
    wire [3:0] input_vector;
    assign input_vector = {a, b, c, d};

    // Decode logic
    always @(*) begin
        case (input_vector)
            4'b0000: out = 0;
            4'b0001: out = 0;
            4'b0010: out = 1;
            4'b0011: out = 1;
            4'b0100: out = 1'bx;
            4'b0101: out = 0;
            4'b0110: out = 0;
            4'b0111: out = 0;
            4'b1000: out = 1;
            4'b1001: out = 1'bx;
            4'b1010: out = 1;
            4'b1011: out = 1;
            4'b1100: out = 1;
            4'b1101: out = 1'bx;
            4'b1110: out = 1;
            4'b1111: out = 1;
            default: out = 1'bx; // Just in case
        endcase
    end

endmodule
