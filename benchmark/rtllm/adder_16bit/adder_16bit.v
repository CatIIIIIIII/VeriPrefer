// 8-bit full adder module
module adder_8bit (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire Cin,
    output wire [7:0] y,
    output wire Co
);
    wire [7:0] c;  // Internal carry signals
    
    // First bit full adder
    assign {c[0], y[0]} = a[0] + b[0] + Cin;
    
    // Generate subsequent bits using carry propagation
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin : full_adder_loop
            assign {c[i], y[i]} = a[i] + b[i] + c[i-1];
        end
    endgenerate
    
    // Carry-out is the final carry generated
    assign Co = c[7];
endmodule

// 16-bit full adder module
module adder_16bit (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire Cin,
    output wire [15:0] y,
    output wire Co
);
    wire carry_intermediate;  // Carry between lower and upper 8-bit adders
    
    // Instantiate lower 8-bit adder
    adder_8bit lower_adder (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(y[7:0]),
        .Co(carry_intermediate)
    );
    
    // Instantiate upper 8-bit adder
    adder_8bit upper_adder (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(carry_intermediate),
        .y(y[15:8]),
        .Co(Co)
    );
endmodule