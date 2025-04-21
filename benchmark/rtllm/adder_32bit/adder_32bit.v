module adder_32bit(
    input [32:1] A,
    input [32:1] B, 
    output [32:1] S,
    output C32
);

    wire C16; // Carry between 16-bit blocks
    wire G0, P0, G1, P1; // Group generate and propagate signals

    // First 16-bit CLA block (Lower half)
    cla_16bit lower_cla(
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S[16:1]),
        .Gout(G0),
        .Pout(P0),
        .Cout(C16)
    );

    // Second 16-bit CLA block (Upper half)
    cla_16bit upper_cla(
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S[32:17]),
        .Gout(G1),
        .Pout(P1),
        .Cout(C32)
    );

endmodule

// 16-bit Carry Lookahead Adder Module
module cla_16bit(
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Gout,
    output Pout,
    output Cout
);

    wire [16:1] G, P; // Generate and Propagate signals for each bit
    wire [17:0] C; // Carry signals

    // Initial carry
    assign C[0] = Cin;

    // Generate and Propagate generation
    genvar i;
    generate
        for(i = 1; i <= 16; i = i + 1) begin : gen_prop_block
            assign G[i] = A[i] & B[i]; // Generate
            assign P[i] = A[i] ^ B[i]; // Propagate
        end
    endgenerate

    // Carry Lookahead Logic
    assign C[1] = G[1] | (P[1] & C[0]);
    assign C[2] = G[2] | (P[2] & C[1]);
    assign C[3] = G[3] | (P[3] & C[2]);
    assign C[4] = G[4] | (P[4] & C[3]);
    assign C[5] = G[5] | (P[5] & C[4]);
    assign C[6] = G[6] | (P[6] & C[5]);
    assign C[7] = G[7] | (P[7] & C[6]);
    assign C[8] = G[8] | (P[8] & C[7]);
    assign C[9] = G[9] | (P[9] & C[8]);
    assign C[10] = G[10] | (P[10] & C[9]);
    assign C[11] = G[11] | (P[11] & C[10]);
    assign C[12] = G[12] | (P[12] & C[11]);
    assign C[13] = G[13] | (P[13] & C[12]);
    assign C[14] = G[14] | (P[14] & C[13]);
    assign C[15] = G[15] | (P[15] & C[14]);
    assign C[16] = G[16] | (P[16] & C[15]);
    assign Cout = C[16];

    // Sum generation
    generate
        for(i = 1; i <= 16; i = i + 1) begin : sum_block
            assign S[i] = P[i] ^ C[i-1];
        end
    endgenerate

    // Group Generate and Propagate
    assign Gout = G[16] | (P[16] & G[15]) | (P[16] & P[15] & G[14]) | 
                  (P[16] & P[15] & P[14] & G[13]) | (P[16] & P[15] & P[14] & P[13] & G[12]) |
                  (P[16] & P[15] & P[14] & P[13] & P[12] & G[11]) | 
                  (P[16] & P[15] & P[14] & P[13] & P[12] & P[11] & G[10]);

    assign Pout = P[16] & P[15] & P[14] & P[13] & P[12] & P[11] & P[10];

endmodule