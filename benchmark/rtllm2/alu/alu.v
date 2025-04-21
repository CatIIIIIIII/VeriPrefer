module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output flag
    );
parameter ADD = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND = 6'b100100;
    parameter OR = 6'b100101;
    parameter XOR = 6'b100110;
    parameter NOR = 6'b100111;
    parameter SLT = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL = 6'b000000;
    parameter SRL = 6'b000010;
    parameter SRA = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI = 6'b001111;

    wire [31:0] a_, b_;
    reg [32:0] res;

    assign a_ = $signed(a);
    assign b_ = $signed(b);
    assign r = res[31:0];
    assign flag = (aluc == SLT || aluc == SLTU) ? 1'b1 : 1'bz;
    assign zero = (res[31:0] == 32'b0);
    assign carry = res[32];
    assign negative = res[31];
    assign overflow = (aluc == ADD || aluc == SUB) ? ((a[31] == b[31]) && (a[31] != res[31])) : 1'bz;

    always @(*) begin
        case (aluc)
            ADD: res = a_ + b_;
            ADDU: res = a + b;
            SUB: res = a_ - b_;
            SUBU: res = a - b;
            AND: res = a & b;
            OR: res = a | b;
            XOR: res = a ^ b;
            NOR: res = ~(a | b);
            SLT: res = (a_ < b_) ? 32'b1 : 32'b0;
            SLTU: res = (a < b) ? 32'b1 : 32'b0;
            SLL: res = b << a[4:0];
            SRL: res = b >> a[4:0];
            SRA: res = $signed(b) >>> a[4:0];
            SLLV: res = b << a;
            SRLV: res = b >> a;
            SRAV: res = $signed(b) >>> a;
            LUI: res = {a[15:0], 16'b0};
            default: res = 33'bz;
        endcase
    end

endmodule