module freq_div (CLK_in,CLK_50,CLK_10,CLK_1,RST);
input CLK_in,RST;
output reg CLK_50,CLK_10,CLK_1;

reg [2:0] cnt_10;
reg [6:0] cnt_100;

always @(posedge CLK_in or posedge RST) begin
    if (RST) begin
        CLK_50 <= 1'b0;
        CLK_10 <= 1'b0;
        CLK_1 <= 1'b0;
        cnt_10 <= 3'b0;
        cnt_100 <= 7'b0;
    end else begin
        CLK_50 <= ~CLK_50;
        
        if (cnt_10 == 3'd4) begin
            CLK_10 <= ~CLK_10;
            cnt_10 <= 3'b0;
        end else begin
            cnt_10 <= cnt_10 + 1'b1;
        end
        
        if (cnt_100 == 7'd49) begin
            CLK_1 <= ~CLK_1;
            cnt_100 <= 7'b0;
        end else begin
            cnt_100 <= cnt_100 + 1'b1;
        end
    end
end

endmodule