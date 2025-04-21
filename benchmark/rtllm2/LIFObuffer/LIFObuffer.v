module LIFObuffer (
    input [3:0] dataIn,
    input RW,
    input EN,
    input Rst,
    input Clk,
    output reg EMPTY,
    output reg FULL,
    output reg [3:0] dataOut
);
reg [3:0] stack_mem [0:3];
    reg [1:0] SP;
    integer i;

    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            SP <= 2'b11;
            EMPTY <= 1'b1;
            FULL <= 1'b0;
            dataOut <= 4'b0000;
            for (i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0000;
            end
        end
        else if (EN) begin
            if (!FULL) begin
                if (!RW) begin
                    stack_mem[SP] <= dataIn;
                    SP <= SP - 1;
                    EMPTY <= 1'b0;
                    if (SP == 2'b00) FULL <= 1'b1;
                end
            end
            if (!EMPTY) begin
                if (RW) begin
                    SP <= SP + 1;
                    FULL <= 1'b0;
                    if (SP == 2'b11) EMPTY <= 1'b1;
                    dataOut <= stack_mem[SP];
                    stack_mem[SP + 1] <= 4'b0000;
                end
            end
        end
    end

endmodule