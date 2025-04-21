module TopModule (
  input wire clk,
  input wire reset,
  input wire data,
  output wire [3:0] count,
  output reg counting,
  output reg done,
  input wire ack
);

  localparam [3:0] seq = 4'b1101;
  reg [3:0] delay;
  reg [3:0] cnt;
  reg [3:0] cnter;
  reg [3:0] state;
  reg [3:0] dly_cnt;
  assign count = (counting) ? dly_cnt : (state == 0) ? 4'd0 : delay;
  always @(posedge clk) begin
    if (reset) begin
      state <= 0;
      counting <= 0;
      done <= 0;
      delay <= 0;
      cnt <= 0;
      cnter <= 0;
      dly_cnt <= 0;
    end else begin
      case (state)
        0: begin
          if (data == seq[3]) begin
            state <= 1;
            cnt <= 1;
          end
        end
        1: begin
          if (cnt == 4) begin
            state <= 2;
            cnt <= 0;
            delay <= 0;
          end else begin
            if (data == seq[cnt]) begin
              cnt <= cnt + 1;
            end else begin
              state <= 0;
              cnt <= 0;
            end
          end
        end
        2: begin
          if (data == 1'b0) begin
            state <= 3;
            cnter <= 0;
            dly_cnt <= delay;
          end else begin
            state <= 0;
          end
        end
        3: begin
          if (cnter == delay) begin
            state <= 4;
            counting <= 0;
            cnter <= 0;
            dly_cnt <= 0;
          end else begin
            cnter <= cnter + 1;
            counting <= 1;
            dly_cnt <= delay - cnter - 1;
          end
        end
        4: begin
          if (ack) begin
            state <= 0;
            counting <= 0;
            done <= 0;
          end else begin
            done <= 1;
          end
        end
      endcase
    end
  end
endmodule

