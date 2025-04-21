
module radix2_div(
    input wire clk,
    input wire rst,
    input wire [7:0] dividend,    
    input wire [7:0] divisor,    
    input wire sign,       

    input wire opn_valid,   
    output reg res_valid,   
    input wire res_ready,   
    output wire [15:0] result
);
    reg [7:0] SR;        
    reg [7:0] NEG_DIVISOR; 
    reg [3:0] cnt;        
    reg start_cnt;        
    reg [7:0] result_reg;  

    wire [8:0] sub_result; 
    wire cout;             

    wire [7:0] mux_result; 

    assign sub_result = {1'b0, SR} - {1'b0, NEG_DIVISOR};
    assign mux_result = sub_result[8] ? SR[7:0] : sub_result[7:0];
    assign result = {result_reg, SR};

    always @(posedge clk or posedge rst) begin
        if (rst) begin

            SR <= 8'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result_reg <= 8'b0;
        end else if (opn_valid && !res_valid) begin

            SR <= (dividend[7] && sign) ? {1'b1, dividend[6:0]} : {1'b0, dividend};
            NEG_DIVISOR <= (divisor[7] && sign) ? {1'b1, divisor} : {1'b0, divisor};
            cnt <= 4'b1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
            result_reg <= 8'b0;
        end else if (start_cnt) begin

            if (cnt[3]) begin

                cnt <= 4'b0;
                start_cnt <= 1'b0;
                res_valid <= 1'b1;
                result_reg <= mux_result;
            end else begin

                cnt <= cnt + 1;
                SR <= {mux_result[6:0], 1'b0};
                result_reg <= {result_reg[6:0], ~sub_result[8]};
            end
        end else if (res_valid && res_ready) begin

            res_valid <= 1'b0;
        end
    end

endmodule