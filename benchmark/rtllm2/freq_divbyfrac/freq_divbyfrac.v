module freq_divbyfrac(
    input               rst_n ,
    input               clk,
    output              clk_div
    );

   parameter            MUL2_DIV_CLK = 7 ;
reg [2:0] cnt;
reg       clk_div_int;
reg       clk_div_int2;
reg       clk_div_int3;
reg       clk_div_int4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 3'd0;
        clk_div_int <= 1'b0;
        clk_div_int2 <= 1'b0;
        clk_div_int3 <= 1'b0;
        clk_div_int4 <= 1'b0;
    end else begin
        if (cnt == MUL2_DIV_CLK - 1) begin
            cnt <= 3'd0;
        end else begin
            cnt <= cnt + 1'b1;
        end

        if (cnt < 3'd4) begin
            clk_div_int <= 1'b1;
        end else begin
            clk_div_int <= 1'b0;
        end

        if (cnt == 3'd4) begin
            clk_div_int2 <= 1'b1;
        end else if (cnt == 3'd5) begin
            clk_div_int2 <= 1'b0;
        end

        if (cnt == 3'd5) begin
            clk_div_int3 <= 1'b1;
        end else if (cnt == 3'd6) begin
            clk_div_int3 <= 1'b0;
        end

        if (cnt == 3'd6) begin
            clk_div_int4 <= 1'b1;
        end else if (cnt == 3'd0) begin
            clk_div_int4 <= 1'b0;
        end
    end
end

assign clk_div = clk_div_int | clk_div_int2 | clk_div_int3 | clk_div_int4;

endmodule