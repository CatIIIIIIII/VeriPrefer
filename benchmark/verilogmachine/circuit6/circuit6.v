
module top_module (
    input [2:0] a, 
    output reg [15:0] q
);
    always @(*) begin
        case (a)
            3'b000: q = 16'h1232; // 4658 in hexadecimal
            3'b001: q = 16'hAB08; // 44768 in hexadecimal
            3'b010: q = 16'h27E4; // 10196 in hexadecimal
            3'b011: q = 16'h59BE; // 23054 in hexadecimal
            3'b100: q = 16'h205E; // 8294 in hexadecimal
            3'b101: q = 16'h64E6; // 25806 in hexadecimal
            3'b110: q = 16'hC46A; // 50470 in hexadecimal
            3'b111: q = 16'h2F09; // 12057 in hexadecimal
            default: q = 16'h0000; // Default value if 'a' is not in the range 0-7
        endcase
    end
endmodule
