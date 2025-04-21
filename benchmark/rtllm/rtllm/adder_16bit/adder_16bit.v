
module adder_16bit (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire Cin,
    output wire [15:0] y,
    output wire Co
);
    wire [8:0] carry;
    assign carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            if (i < 8) begin
                wire [1:0] tmp;
                assign tmp[0] = a[i] ^ b[i];
                assign tmp[1] = a[i] & b[i];
                assign y[i] = tmp[0] ^ carry[i];
                assign carry[i+1] = tmp[1] | (carry[i] & tmp[0]);
            end else begin
                assign y[i] = a[i] ^ b[i] ^ carry[i];
                assign carry[i+1] = (a[i] & b[i]) | (carry[i] & (a[i] ^ b[i]));
            end
        end
    endgenerate
    assign Co = carry[15];

endmodule