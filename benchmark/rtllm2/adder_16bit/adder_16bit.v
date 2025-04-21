module adder_16bit (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire Cin,
    output wire [15:0] y,
    output wire Co
);
wire [3:0] carry;

    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(y[7:0]),
        .Co(carry[0])
    );

    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(carry[0]),
        .y(y[15:8]),
        .Co(carry[1])
    );

    assign Co = carry[1];

endmodule

module adder_8bit (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire Cin,
    output wire [7:0] y,
    output wire Co
);

    wire [3:0] carry;

    adder_4bit adder_low (
        .a(a[3:0]),
        .b(b[3:0]),
        .Cin(Cin),
        .y(y[3:0]),
        .Co(carry[0])
    );

    adder_4bit adder_high (
        .a(a[7:4]),
        .b(b[7:4]),
        .Cin(carry[0]),
        .y(y[7:4]),
        .Co(carry[1])
    );

    assign Co = carry[1];

endmodule

module adder_4bit (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire Cin,
    output wire [3:0] y,
    output wire Co
);

    wire [1:0] carry;

    adder_2bit adder_low (
        .a(a[1:0]),
        .b(b[1:0]),
        .Cin(Cin),
        .y(y[1:0]),
        .Co(carry[0])
    );

    adder_2bit adder_high (
        .a(a[3:2]),
        .b(b[3:2]),
        .Cin(carry[0]),
        .y(y[3:2]),
        .Co(carry[1])
    );

    assign Co = carry[1];

endmodule

module adder_2bit (
    input wire [1:0] a,
    input wire [1:0] b,
    input wire Cin,
    output wire [1:0] y,
    output wire Co
);

    assign y[0] = a[0] ^ b[0] ^ Cin;
    assign y[1] = (a[1] ^ b[1]) ^ ((a[0] & b[0]) | (Cin & (a[1] ^ b[1])));
    assign Co = (a[1] & b[1]) | ((a[1] ^ b[1]) & ((a[0] & b[0]) | (Cin & (a[1] ^ b[1]))));

endmodule