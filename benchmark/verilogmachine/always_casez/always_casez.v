
module top_module (
    input [7:0] in,
    output reg [2:0] pos
);

always @(*) begin
    casez (in)
        8'bzzzzzzz1: pos = 3'h0;
        8'bz1zzzzzz: pos = 3'h1;
        8'bz01zzzzz: pos = 3'h2;
        8'bz001zzzz: pos = 3'h3;
        8'bz0001zzz: pos = 3'h4;
        8'bz00001zz: pos = 3'h5;
        8'bz000001z: pos = 3'h6;
        8'bz0000001: pos = 3'h7;
        default: pos = 3'h0;
    endcase
end

endmodule
