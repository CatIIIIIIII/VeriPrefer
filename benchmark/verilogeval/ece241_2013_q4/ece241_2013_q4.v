module TopModule (
  input clk,
  input reset,
  input [2:0] s,
  output reg fr2,
  output reg fr1,
  output reg fr0,
  output reg dfr
);

  reg [1:0] state, next_state;
  parameter [1:0] state0 = 2'b00, state1 = 2'b01, state2 = 2'b10, state3 = 2'b11;

  always @(posedge clk) begin
    if(reset) begin
      state <= state0;
    end
    else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case(state)
      state0: begin
        if(s[0]) begin
          next_state = state1;
        end
        else begin
          next_state = state0;
        end
      end
      state1: begin
        if(s[1]) begin
          next_state = state2;
        end
        else begin
          next_state = state0;
        end
      end
      state2: begin
        if(s[2]) begin
          next_state = state3;
        end
        else begin
          next_state = state1;
        end
      end
      state3: begin
        if(s[2]) begin
          next_state = state2;
        end
        else begin
          next_state = state0;
        end
      end
    endcase
  end

  always @(posedge clk) begin
    if(reset) begin
      fr2 <= 1'b1;
      fr1 <= 1'b1;
      fr0 <= 1'b1;
      dfr <= 1'b1;
    end
    else begin
      case(state)
        state0: begin
          fr2 <= 1'b1;
          fr1 <= 1'b1;
          fr0 <= 1'b1;
          dfr <= 1'b1;
        end
        state1: begin
          fr2 <= 1'b0;
          fr1 <= 1'b0;
          fr0 <= 1'b1;
          dfr <= 1'b0;
        end
        state2: begin
          fr2 <= 1'b0;
          fr1 <= 1'b1;
          fr0 <= 1'b1;
          dfr <= 1'b0;
        end
        state3: begin
          fr2 <= 1'b0;
          fr1 <= 1'b0;
          fr0 <= 1'b0;
          dfr <= 1'b1;
        end
      endcase
    end
  end

endmodule

