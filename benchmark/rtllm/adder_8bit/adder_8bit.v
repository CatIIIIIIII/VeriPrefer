module adder_8bit(
    input [7:0] a, b, 
    input cin, 
    output [7:0] sum, 
    output cout
);

    // Internal carry signals to connect full adders
    wire [8:0] carry;

    // First full adder uses the input carry-in
    assign carry[0] = cin;

    // Generate 8 full adders using generate block
    genvar i;
    generate 
        for (i = 0; i < 8; i = i + 1) begin : full_adder_loop
            // Full adder logic 
            assign sum[i] = a[i] ^ b[i] ^ carry[i];
            assign carry[i+1] = (a[i] & b[i]) | 
                                (a[i] & carry[i]) | 
                                (b[i] & carry[i]);
        end
    endgenerate

    // Carry-out is the final carry
    assign cout = carry[8];

endmodule