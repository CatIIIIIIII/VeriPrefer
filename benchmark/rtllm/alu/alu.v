module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output flag
);

    // Define ALU operation parameters
    parameter ADD  = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB  = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND  = 6'b100100;
    parameter OR   = 6'b100101;
    parameter XOR  = 6'b100110;
    parameter NOR  = 6'b100111;
    parameter SLT  = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL  = 6'b000000;
    parameter SRL  = 6'b000010;
    parameter SRA  = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI  = 6'b001111;

    // Internal signals
    wire signed [31:0] signed_a;
    wire signed [31:0] signed_b;
    reg signed [32:0] res;
    
    // Assign signed inputs
    assign signed_a = a;
    assign signed_b = b;

    // Zero flag: Set when result is all zeros
    assign zero = (r == 32'h0);
    
    // Negative flag: Set when result's MSB is 1
    assign negative = r[31];
    
    // Carry flag: Set when result's 33rd bit is 1
    assign carry = res[32];
    
    // Overflow flag: Set during signed addition/subtraction when sign changes
    assign overflow = (aluc == ADD || aluc == SUB) && 
                      (signed_a[31] == signed_b[31]) && 
                      (signed_a[31] != r[31]);
    
    // Flag for SLT and SLTU
    assign flag = ((aluc == SLT) && (signed_a < signed_b)) || 
                  ((aluc == SLTU) && (a < b));

    // ALU operation logic
    always @(*) begin
        case (aluc)
            // Arithmetic operations
            ADD:  res = signed_a + signed_b;
            ADDU: res = a + b;
            SUB:  res = signed_a - signed_b;
            SUBU: res = a - b;

            // Logical operations
            AND:  res = {1'b0, a & b};
            OR:   res = {1'b0, a | b};
            XOR:  res = {1'b0, a ^ b};
            NOR:  res = {1'b0, ~(a | b)};

            // Shift operations
            SLL:  res = {1'b0, b << a[4:0]};
            SRL:  res = {1'b0, b >> a[4:0]};
            SRA:  res = {1'b0, signed_b >>> a[4:0]};
            SLLV: res = {1'b0, b << a[4:0]};
            SRLV: res = {1'b0, b >> a[4:0]};
            SRAV: res = {1'b0, signed_b >>> a[4:0]};

            // Special operations
            LUI:  res = {1'b0, b[15:0], 16'h0000};
            SLT:  res = {1'b0, (signed_a < signed_b) ? 32'd1 : 32'd0};
            SLTU: res = {1'b0, (a < b) ? 32'd1 : 32'd0};

            // Default case
            default: res = 33'bx;
        endcase
        
        // Assign result
        r = res[31:0];
    end

endmodule