
module div_16bit(
    input wire [15:0] A,
    input wire [7:0] B,
    output wire [15:0] result,
    output wire [15:0] odd
    );



    reg [15:0] a_reg;
    reg [7:0] b_reg;

    reg [15:0] quotient;
    reg [15:0] remainder;

    reg [15:0] dividend;
    reg [7:0] divisor;

    integer i;

    always @* begin
        a_reg = A;
        b_reg = B;
    end

    always @* begin

        dividend = a_reg;
        divisor = b_reg;
        quotient = 16'b0;
        remainder = 16'b0;

        for (i = 15; i >= 8; i = i - 1) begin
            if (dividend[i] >= divisor) begin
                quotient[i] = 1'b1;
                remainder = remainder | (dividend[i] - divisor);
            end
            else begin
                quotient[i] = 1'b0;
                remainder = remainder | dividend[i];
            end
        end

        if (dividend[7] >= divisor) begin
            quotient[7] = 1'b1;
            remainder = remainder | (dividend[7] - divisor);
        end
        else begin
            quotient[7] = 1'b0;
            remainder = remainder | dividend[7];
        end
    end

    assign result = quotient;
    assign odd = remainder;

endmodule