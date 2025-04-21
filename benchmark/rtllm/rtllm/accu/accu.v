
module accu(
    input               clk         ,   
    input               rst_n       ,
    input       [7:0]   data_in     ,
    input               valid_in     ,
 
    output  reg         valid_out     ,
    output  reg [9:0]   data_out
);



reg [1:0] cnt;
reg [9:0] data_out_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 2'd0;
    end
    else if(valid_in == 1) begin
        cnt <= cnt + 1'b1;
    end
    else begin
        cnt <= cnt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_out_reg <= 10'd0;
    end
    else if(cnt == 0 && valid_in == 1) begin
        data_out_reg <= data_in;
    end
    else if(cnt >= 1 && valid_in == 1) begin
        data_out_reg <= data_out_reg + data_in;
    end
    else begin
        data_out_reg <= data_out_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_out <= 10'd0;
    end
    else if(cnt == 2 && valid_in == 1) begin
        data_out <= data_out_reg;
    end
    else begin
        data_out <= data_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_out <= 1'b0;
    end
    else if(cnt == 2 && valid_in == 1) begin
        valid_out <= 1'b1;
    end
    else begin
        valid_out <= 1'b0;
    end
end

endmodule