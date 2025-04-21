module TopModule (
  input clk,
  input in,
  input reset,
  output [7:0] out_byte,
  output done
);

  parameter IDLE = 0,
            START = 1,
            BIT = 2,
            STOP = 3;
  reg [1:0] state = IDLE;
  reg [3:0] count = 0;
  reg [7:0] data = 0;
  assign out_byte = data;
  assign done = (state == STOP && in == 1) ? 1 : 0;
  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      count <= 0;
      data <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          if (in == 0) begin
            state <= START;
          end
        end
        START: begin
          if (count == 7) begin
            state <= BIT;
            count <= 0;
          end
          else begin
            count <= count + 1;
          end
        end
        BIT: begin
          if (count == 7) begin
            state <= BIT;
            count <= 0;
            data <= {in, data[7:1]};
          end
          else begin
            count <= count + 1;
          end
        end
        STOP: begin
          if (count == 7) begin
            state <= STOP;
            count <= 0;
          end
          else begin
            count <= count + 1;
          end
        end
      endcase
    end
  end
endmodule

