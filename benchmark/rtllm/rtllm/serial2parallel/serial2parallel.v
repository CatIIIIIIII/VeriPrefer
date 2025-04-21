
module serial2parallel(
	input clk,
	input rst_n,
	input din_serial,
	input din_valid,
	output reg [7:0]dout_parallel,
	output reg dout_valid
);



reg [3:0]cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else if(din_valid) begin
        if(cnt == 7) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
    else begin
        cnt <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout_parallel <= 0;
    end
    else if(din_valid) begin
        if(cnt == 0) begin
            dout_parallel[7] <= din_serial;
        end
        else if(cnt == 1) begin
            dout_parallel[6] <= din_serial;
        end
        else if(cnt == 2) begin
            dout_parallel[5] <= din_serial;
        end
        else if(cnt == 3) begin
            dout_parallel[4] <= din_serial;
        end
        else if(cnt == 4) begin
            dout_parallel[3] <= din_serial;
        end
        else if(cnt == 5) begin
            dout_parallel[2] <= din_serial;
        end
        else if(cnt == 6) begin
            dout_parallel[1] <= din_serial;
        end
        else if(cnt == 7) begin
            dout_parallel[0] <= din_serial;
        end
    end
    else begin
        dout_parallel <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout_valid <= 0;
    end
    else if(din_valid && cnt == 7) begin
        dout_valid <= 1;
    end
    else begin
        dout_valid <= 0;
    end
end

endmodule