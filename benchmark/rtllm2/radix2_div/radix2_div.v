module radix2_div 
#(
parameter DATAWIDTH=8
)
(
  input                       clk,
  input                       rstn,
  input                       en,
  output  wire                ready,
  input  [DATAWIDTH-1:0]      dividend,
  input  [DATAWIDTH-1:0]      divisor,
  output wire [DATAWIDTH-1:0] quotient,
  output wire [DATAWIDTH-1:0] remainder,
  output wire                 vld_out
);
reg [DATAWIDTH-1:0] dividend_r, divisor_r;
  reg [DATAWIDTH*2-1:0] SR;
  reg [DATAWIDTH-1:0] NEG_DIVISOR;
  reg [3:0] cnt;
  reg start_cnt;
  reg res_valid;
  wire carry_out;
  wire [DATAWIDTH*2-1:0] sub_result;

  assign ready = ~start_cnt;
  assign quotient = SR[DATAWIDTH-1:0];
  assign remainder = SR[DATAWIDTH*2-1:DATAWIDTH];
  assign vld_out = res_valid;
  assign carry_out = sub_result[DATAWIDTH*2-1];
  assign sub_result = SR + {1'b0, NEG_DIVISOR};

  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      dividend_r <= 0;
      divisor_r <= 0;
      SR <= 0;
      NEG_DIVISOR <= 0;
      cnt <= 0;
      start_cnt <= 0;
      res_valid <= 0;
    end else if (en) begin
      if (ready && ~vld_out) begin
        dividend_r <= dividend;
        divisor_r <= divisor;
        SR <= {1'b0, dividend, {DATAWIDTH-1{1'b0}}};
        NEG_DIVISOR <= -divisor;
        cnt <= 1;
        start_cnt <= 1;
      end else if (start_cnt) begin
        if (cnt[3]) begin
          cnt <= 0;
          start_cnt <= 0;
          res_valid <= 1;
        end else begin
          cnt <= cnt + 1;
          SR <= {sub_result[DATAWIDTH*2-2:0], ~carry_out};
        end
      end else begin
        res_valid <= 0;
      end
    end
  end

endmodule