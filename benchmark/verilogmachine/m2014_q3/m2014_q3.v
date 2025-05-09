
module top_module (
    input [3:0] x,  // 4-bit input
    output logic f   // 1-bit output
);

always_comb begin
    case (x)
        4'h0: f = 1'bx;
        4'h1: f = 1'bx;
        4'h2: f = 0;
        4'h3: f = 1'bx;
        4'h4: f = 1;
        4'h5: f = 1'bx;
        4'h6: f = 1;
        4'h7: f = 0;
        4'h8: f = 0;
        4'h9: f = 0;
        4'ha: f = 1'bx;
        4'hb: f = 1;
        4'hc: f = 1;
        4'hd: f = 1'bx;
        4'he: f = 1;
        4'hf: f = 1'bx;
        default: f = 1'bx;  // Default case to handle any unexpected input
    endcase
end

endmodule
