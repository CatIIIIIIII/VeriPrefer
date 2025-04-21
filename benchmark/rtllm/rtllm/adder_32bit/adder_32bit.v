
module adder_32bit(A,B,S,C32);
     input [32:1] A;
     input [32:1] B;
     output [32:1] S;
     output C32;
     wire [15:0] C_16bit;
     wire [15:0] S_16bit;

     assign C_16bit[0] = 1'b0;

     assign S[1] = A[1] ^ B[1] ^ C_16bit[0];
     assign C_16bit[1] = (A[1] & B[1]) | (B[1] & C_16bit[0]) | (A[1] & C_16bit[0]);

     assign S[2] = A[2] ^ B[2] ^ C_16bit[1];
     assign C_16bit[2] = (A[2] & B[2]) | (B[2] & C_16bit[1]) | (A[2] & C_16bit[1]);

     assign S[3] = A[3] ^ B[3] ^ C_16bit[2];
     assign C_16bit[3] = (A[3] & B[3]) | (B[3] & C_16bit[2]) | (A[3] & C_16bit[2]);

     assign S[4] = A[4] ^ B[4] ^ C_16bit[3];
     assign C_16bit[4] = (A[4] & B[4]) | (B[4] & C_16bit[3]) | (A[4] & C_16bit[3]);

     assign S[5] = A[5] ^ B[5] ^ C_16bit[4];
     assign C_16bit[5] = (A[5] & B[5]) | (B[5] & C_16bit[4]) | (A[5] & C_16bit[4]);

     assign S[6] = A[6] ^ B[6] ^ C_16bit[5];
     assign C_16bit[6] = (A[6] & B[6]) | (B[6] & C_16bit[5]) | (A[6] & C_16bit[5]);

     assign S[7] = A[7] ^ B[7] ^ C_16bit[6];
     assign C_16bit[7] = (A[7] & B[7]) | (B[7] & C_16bit[6]) | (A[7] & C_16bit[6]);

     assign S[8] = A[8] ^ B[8] ^ C_16bit[7];
     assign C_16bit[8] = (A[8] & B[8]) | (B[8] & C_16bit[7]) | (A[8] & C_16bit[7]);

     assign S[9] = A[9] ^ B[9] ^ C_16bit[8];
     assign C_16bit[9] = (A[9] & B[9]) | (B[9] & C_16bit[8]) | (A[9] & C_16bit[8]);

     assign S[10] = A[10] ^ B[10] ^ C_16bit[9];
     assign C_16bit[10] = (A[10] & B[10]) | (B[10] & C_16bit[9]) | (A[10] & C_16bit[9]);

     assign S[11] = A[11] ^ B[11] ^ C_16bit[10];
     assign C_16bit[11] = (A[11] & B[11]) | (B[11] & C_16bit[10]) | (A[11] & C_16bit[10]);

     assign S[12] = A[12] ^ B[12] ^ C_16bit[11];
     assign C_16bit[12] = (A[12] & B[12]) | (B[12] & C_16bit[11]) | (A[12] & C_16bit[11]);

     assign S[13] = A[13] ^ B[13] ^ C_16bit[12];
     assign C_16bit[13] = (A[13] & B[13]) | (B[13] & C_16bit[12]) | (A[13] & C_16bit[12]);

     assign S[14] = A[14] ^ B[14] ^ C_16bit[13];
     assign C_16bit[14] = (A[14] & B[14]) | (B[14] & C_16bit[13]) | (A[14] & C_16bit[13]);

     assign S[15] = A[15] ^ B[15] ^ C_16bit[14];
     assign C_16bit[15] = (A[15] & B[15]) | (B[15] & C_16bit[14]) | (A[15] & C_16bit[14]);

     assign S[16] = A[16] ^ B[16] ^ C_16bit[15];
     assign C_16bit[16] = (A[16] & B[16]) | (B[16] & C_16bit[15]) | (A[16] & C_16bit[15]);

     assign S[17] = A[17] ^ B[17] ^ C_16bit[16];
     assign C_16bit[17] = (A[17] & B[17]) | (B[17] & C_16bit[16]) | (A[17] & C_16bit[16]);

     assign S[18] = A[18] ^ B[18] ^ C_16bit[17];
     assign C_16bit[18] = (A[18] & B[18]) | (B[18] & C_16bit[17]) | (A[18] & C_16bit[17]);

     assign S[19] = A[19] ^ B[19] ^ C_16bit[18];
     assign C_16bit[19] = (A[19] & B[19]) | (B[19] & C_16bit[18]) | (A[19] & C_16bit[18]);

     assign S[20] = A[20] ^ B[20] ^ C_16bit[19];
     assign C_16bit[20] = (A[20] & B[20]) | (B[20] & C_16bit[19]) | (A[20] & C_16bit[19]);

     assign S[21] = A[21] ^ B[21] ^ C_16bit[20];
     assign C_16bit[21] = (A[21] & B[21]) | (B[21] & C_16bit[20]) | (A[21] & C_16bit[20]);

     assign S[22] = A[22] ^ B[22] ^ C_16bit[21];
     assign C_16bit[22] = (A[22] & B[22]) | (B[22] & C_16bit[21]) | (A[22] & C_16bit[21]);

     assign S[23] = A[23] ^ B[23] ^ C_16bit[22];
     assign C_16bit[23] = (A[23] & B[23]) | (B[23] & C_16bit[22]) | (A[23] & C_16bit[22]);

     assign S[24] = A[24] ^ B[24] ^ C_16bit[23];
     assign C_16bit[24] = (A[24] & B[24]) | (B[24] & C_16bit[23]) | (A[24] & C_16bit[23]);

     assign S[25] = A[25] ^ B[25] ^ C_16bit[24];
     assign C_16bit[25] = (A[25] & B[25]) | (B[25] & C_16bit[24]) | (A[25] & C_16bit[24]);

     assign S[26] = A[26] ^ B[26] ^ C_16bit[25];
     assign C_16bit[26] = (A[26] & B[26]) | (B[26] & C_16bit[25]) | (A[26] & C_16bit[25]);

     assign S[27] = A[27] ^ B[27] ^ C_16bit[26];
     assign C_16bit[27] = (A[27] & B[27]) | (B[27] & C_16bit[26]) | (A[27] & C_16bit[26]);

     assign S[28] = A[28] ^ B[28] ^ C_16bit[27];
     assign C_16bit[28] = (A[28] & B[28]) | (B[28] & C_16bit[27]) | (A[28] & C_16bit[27]);

     assign S[29] = A[29] ^ B[29] ^ C_16bit[28];
     assign C_16bit[29] = (A[29] & B[29]) | (B[29] & C_16bit[28]) | (A[29] & C_16bit[28]);

     assign S[30] = A[30] ^ B[30] ^ C_16bit[29];
     assign C_16bit[30] = (A[30] & B[30]) | (B[30] & C_16bit[29]) | (A[30] & C_16bit[29]);

     assign S[31] = A[31] ^ B[31] ^ C_16bit[30];
     assign C32 = (A[31] & B[31]) | (B[31] & C_16bit[30]) | (A[31] & C_16bit[30]);

endmodule