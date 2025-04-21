module accu(
    input               clk         ,   
    input               rst_n       ,
    input       [7:0]   data_in     ,
    input               valid_in     ,
 
    output  reg         valid_out     ,
    output  reg [9:0]   data_out
);
reg [9:0] sum;
reg [1:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 10'd0;
        count <= 2'd0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
    end
    else begin
        if (valid_in) begin
            sum <= sum + data_in;
            count <= count + 1'b1;
            
            if (count == 2'd3) begin
                data_out <= sum + data_in;
                valid_out <= 1'b1;
                sum <= 10'd0;
                count <= 2'd0;
            end
            else begin
                valid_out <= 1'b0;
            end
        end
        else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule