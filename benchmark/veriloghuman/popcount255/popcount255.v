
module top_module (
    input [254:0] in,
    output reg [7:0] out
);

    // Internal signals to hold intermediate results
    reg [7:0] count1 [0:127];
    reg [7:0] count2 [0:63];
    reg [7:0] count3 [0:31];
    reg [7:0] count4 [0:15];
    reg [7:0] count5 [0:7];
    reg [7:0] count6 [0:3];
    reg [7:0] count7 [0:1];

    // First level: count '1's in each 2-bit group
    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : count_2bit
            assign count1[i] = in[2*i+1] + in[2*i];
        end
    endgenerate

    // Second level: count '1's in each 4-bit group
    generate
        for (i = 0; i < 64; i = i + 1) begin : count_4bit
            assign count2[i] = count1[2*i] + count1[2*i+1];
        end
    endgenerate

    // Third level: count '1's in each 8-bit group
    generate
        for (i = 0; i < 32; i = i + 1) begin : count_8bit
            assign count3[i] = count2[2*i] + count2[2*i+1];
        end
    endgenerate

    // Fourth level: count '1's in each 16-bit group
    generate
        for (i = 0; i < 16; i = i + 1) begin : count_16bit
            assign count4[i] = count3[2*i] + count3[2*i+1];
        end
    endgenerate

    // Fifth level: count '1's in each 32-bit group
    generate
        for (i = 0; i < 8; i = i + 1) begin : count_32bit
            assign count5[i] = count4[2*i] + count4[2*i+1];
        end
    endgenerate

    // Sixth level: count '1's in each 64-bit group
    generate
        for (i = 0; i < 4; i = i + 1) begin : count_64bit
            assign count6[i] = count5[2*i] + count5[2*i+1];
        end
    endgenerate

    // Seventh level: count '1's in each 128-bit group
    generate
        for (i = 0; i < 2; i = i + 1) begin : count_128bit
            assign count7[i] = count6[2*i] + count6[2*i+1];
        end
    endgenerate

    // Final level: count '1's in the remaining 256-bit group
    assign out = count7[0] + count7[1];

endmodule
