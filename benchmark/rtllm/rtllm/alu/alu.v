
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

    wire signed [31:0] x,y;
    reg [32:0] res;

    assign x = a;
    assign y = b;
    assign r = res[31:0];

    assign flag = (aluc == SLT || aluc == SLTU) ? 1'b1 : 1'bz;
    assign zero = (r == 0) ? 1'b1 : 1'b0;
    assign carry = res[32];
    assign negative = res[31];
    assign overflow = res[32];

    always @(*) begin
        case (aluc)
            ADD: res = x + y;
            ADDU: res = x + y;
            SUB: res = x - y;
            SUBU: res = x - y;
            AND: res = x & y;
            OR: res = x | y;
            XOR: res = x ^ y;
            NOR: res = ~(x | y);
            SLT: res = (x < y) ? 1 : 0;
            SLTU: res = ({1'b0, x} < {1'b0, y}) ? 1 : 0;
            SLL: res = y << a;
            SRL: res = y >> a;
            SRA: res = y >>> a;
            SLLV: res = y << a[4:0];
            SRLV: res = y >> a[4:0];
            SRAV: res = y >>> a[4:0];
            LUI: res = {a[15:0], 16'b0};
            default: res = 33'bz;
        endcase
    end

endmodule