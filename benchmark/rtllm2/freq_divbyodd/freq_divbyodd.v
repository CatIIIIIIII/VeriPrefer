module freq_divbyodd(
    clk,
    rst_n,
    clk_div
);
    input clk;
    input rst_n;
    output clk_div;
    reg clk_div;

parameter NUM_DIV = 5;

reg [2:0] cnt1, cnt2;
reg clk_div1, clk_div2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt1 <= 3'b000;
        clk_div1 <= 1'b0;
    end else begin
        if (cnt1 == NUM_DIV - 1)
            cnt1 <= 3'b000;
        else
            cnt1 <= cnt1 + 1'b1;
        
        if (cnt1 == (NUM_DIV / 2) - 1)
            clk_div1 <= ~clk_div1;
    end
end

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt2 <= 3'b000;
        clk_div2 <= 1'b0;
    end else begin
        if (cnt2 == NUM_DIV - 1)
            cnt2 <= 3'b000;
        else
            cnt2 <= cnt2 + 1'b1;
        
        if (cnt2 == (NUM_DIV / 2) - 1)
            clk_div2 <= ~clk_div2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        clk_div <= 1'b0;
    else
        clk_div <= clk_div1 | clk_div2;
end

endmodule