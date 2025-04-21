
module traffic_light
    (
		input rst_n, 
      input clk, 
      input pass_request,
		  output wire[7:0]clock,
      output reg red,
		  output reg yellow,
		  output reg green
    );
reg[7:0] cnt;
reg[1:0] state;
reg p_red,p_yellow,p_green;

localparam idle = 2'b00, s1_red = 2'b01, s2_yellow = 2'b10, s3_green = 2'b11;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state <= idle;
    end
    else
    begin
        case(state)
            idle:
            begin
                state <= s1_red;
            end
            s1_red:
            begin
                if(cnt == 3)
                    state <= s3_green;
                else
                    state <= s1_red;
            end
            s2_yellow:
            begin
                if(cnt == 3)
                    state <= s1_red;
                else
                    state <= s2_yellow;
            end
            s3_green:
            begin
                if(cnt == 3)
                    state <= s2_yellow;
                else
                    state <= s3_green;
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cnt <= 10;
    end
    else
    begin
        if(pass_request && green)
        begin
            cnt <= 10;
        end
        else if(!green && p_green)
        begin
            cnt <= 60;
        end
        else if(!yellow && p_yellow)
        begin
            cnt <= 5;
        end
        else if(!red && p_red)
        begin
            cnt <= 10;
        end
        else
        begin
            cnt <= cnt - 1;
        end
    end
end

assign clock = cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        p_red <= 0;
        p_yellow <= 0;
        p_green <= 0;
    end
    else
    begin
        p_red <= red;
        p_yellow <= yellow;
        p_green <= green;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        red <= 0;
        yellow <= 0;
        green <= 0;
    end
    else
    begin
        case(state)
            s1_red:
            begin
                red <= 1;
                yellow <= 0;
                green <= 0;
            end
            s2_yellow:
            begin
                red <= 0;
                yellow <= 1;
                green <= 0;
            end
            s3_green:
            begin
                red <= 0;
                yellow <= 0;
                green <= 1;
            end
            default:
            begin
                red <= 0;
                yellow <= 0;
                green <= 0;
            end
        endcase
    end
end

endmodule