
module top_module (
    input [15:0] in,
    output [7:0] out_hi,
    output [7:0] out_lo
);

    // Assign the upper byte (bits 15:8) to out_hi
    assign out_hi = in[15:8];
    
    // Assign the lower byte (bits 7:0) to out_lo
    assign out_lo = in[7:0];

endmodule
