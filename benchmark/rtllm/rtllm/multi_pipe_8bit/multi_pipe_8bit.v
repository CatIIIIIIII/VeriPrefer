
module multi_pipe_8bit#(
    parameter size = 8
)(
    input clk;           
    input rst_n; 
    input mul_en_in;      
    input [size-1:0] mul_a;       
    input [size-1:0] mul_b;       

    output reg mul_en_out;  
    output reg [size*2-1:0] mul_out;    
);
reg mul_en_out_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mul_en_out_reg <= 0;
    end
    else begin
        mul_en_out_reg <= mul_en_in;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mul_en_out <= 0;
    end
    else begin
        mul_en_out <= mul_en_out_reg[size-1];
    end
end

reg [size-1:0] mul_a_reg;
reg [size-1:0] mul_b_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mul_a_reg <= 0;
        mul_b_reg <= 0;
    end
    else begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
    end
end

wire [size-1:0] temp [0:size-1];
genvar i;
generate
    for(i=0; i<size; i=i+1) begin:multi
        assign temp[i] = mul_b_reg[i] ? mul_a_reg : 0;
    end
endgenerate

reg [size-1+1:0] sum [0:size-1];
generate
    for(i=0; i<size; i=i+1) begin:add
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                sum[i] <= 0;
            end
            else begin
                if(i == 0) begin
                    sum[i] <= temp[i];
                end
                else begin
                    sum[i] <= sum[i-1] + temp[i] << i;
                end
            end
        end
    end
endgenerate

reg [size*2-1:0] mul_out_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mul_out_reg <= 0;
    end
    else begin
        mul_out_reg <= sum[size-1];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mul_out <= 0;
    end
    else begin
        mul_out <= mul_out_reg;
    end
end

endmodule