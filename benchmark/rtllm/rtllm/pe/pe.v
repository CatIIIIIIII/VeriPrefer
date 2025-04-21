
module pe(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,

    output [31:0] c
);
    reg [31:0] c_reg;

    assign c = c_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_reg <= 0;
        end else begin
            c_reg <= c_reg + (a * b);
        end
    end

endmodule