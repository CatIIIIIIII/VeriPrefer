
module fsm(IN,MATCH,CLK,RST);
input IN,CLK,RST;
output reg MATCH;



always @(IN or posedge CLK or posedge RST)
begin
    if(RST)
        MATCH <= 0;
    else
        begin
            casez({IN})
                1'b1: MATCH <= 1'b1;
                1'b0: MATCH <= 1'b0;
                default: MATCH <= 1'b0;
            endcase
        end
end

endmodule