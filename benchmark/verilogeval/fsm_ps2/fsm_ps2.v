module TopModule (
  input clk,
  input [7:0] in,
  input reset,
  output done
);

  parameter s0 = 2'b00;
  parameter s1 = 2'b01;
  parameter s2 = 2'b10;
  parameter s3 = 2'b11;

  reg [1:0] state, next_state;
  reg [1:0] cnt;

  always @(*) begin
    case (state)
      s0: begin
        if (in[3]) begin
          next_state = s1;
          cnt = 2'd1;
        end
        else begin
          next_state = s0;
          cnt = 2'd0;
        end
      end
      s1: begin
        if (cnt == 2'd2) begin
          if (in[3]) begin
            next_state = s3;
            cnt = 2'd3;
          end
          else begin
            next_state = s2;
            cnt = 2'd2;
          end
        end
        else begin
          next_state = s1;
          cnt = cnt + 2'd1;
        end
      end
      s2: begin
        if (in[3]) begin
          next_state = s1;
          cnt = 2'd1;
        end
        else begin
          next_state = s2;
          cnt = cnt + 2'd1;
        end
      end
      s3: begin
        if (cnt == 2'd3) begin
          if (in[3]) begin
            next_state = s1;
            cnt = 2'd1;
          end
          else begin
            next_state = s2;
            cnt = 2'd2;
          end
        end
        else begin
          next_state = s3;
          cnt = cnt + 2'd1;
        end
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= s0;
    end
    else begin
      state <= next_state;
    end
  end

  assign done = (state == s3) && (cnt == 2'd3);

endmodule

