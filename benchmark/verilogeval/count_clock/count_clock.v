module TopModule (
  input clk,
  input reset,
  input ena,
  output reg pm,
  output reg [7:0] hh,
  output reg [7:0] mm,
  output reg [7:0] ss
);

  reg pm_next;
  reg [7:0] hh_next;
  reg [7:0] mm_next;
  reg [7:0] ss_next;

  always @(posedge clk) begin
    if (reset) begin
      pm <= 0;
      hh <= 8'b01_00;
      mm <= 8'b00;
      ss <= 8'b00;
    end else if (ena) begin
      pm <= pm_next;
      hh <= hh_next;
      mm <= mm_next;
      ss <= ss_next;
    end
  end

  always @(*) begin
    pm_next = pm;
    hh_next = hh;
    mm_next = mm;
    ss_next = ss;

    if (ss[3:0] == 4'b1001) begin
      ss_next[3:0] = 4'b0000;
      if (ss[7:4] == 4'b01_01) begin
        ss_next[7:4] = 4'b00;
        if (mm[3:0] == 4'b1001) begin
          mm_next[3:0] = 4'b0000;
          if (mm[7:4] == 4'b01_01) begin
            mm_next[7:4] = 4'b00;
            if (hh[3:0] == 4'b1001) begin
              hh_next[3:0] = 4'b0000;
              if (hh[7:4] == 4'b01_01) begin
                hh_next[7:4] = 4'b01;
                pm_next = ~pm;
              end
            end
          end
        end
      end
    end
  end

endmodule

