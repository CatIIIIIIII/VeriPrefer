
module top_module(
    input [3:1] y,
    input w,
    output reg Y2
);

always @(*) begin
    case ({y[3:1], w})
        4'b000_0: Y2 = 0; // A (0) --0--> B
        4'b000_1: Y2 = 0; // A (0) --1--> A
        4'b001_0: Y2 = 0; // B (0) --0--> C
        4'b001_1: Y2 = 1; // B (0) --1--> D
        4'b010_0: Y2 = 0; // C (0) --0--> E
        4'b010_1: Y2 = 1; // C (0) --1--> D
        4'b011_0: Y2 = 1; // D (0) --0--> F
        4'b011_1: Y2 = 0; // D (0) --1--> A
        4'b100_0: Y2 = 1; // E (1) --0--> E
        4'b100_1: Y2 = 1; // E (1) --1--> D
        4'b101_0: Y2 = 0; // F (1) --0--> C
        4'b101_1: Y2 = 1; // F (1) --1--> D
        default: Y2 = 0;  // Default case
    endcase
end

endmodule
