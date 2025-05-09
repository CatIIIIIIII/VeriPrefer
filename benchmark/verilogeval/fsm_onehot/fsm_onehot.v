module TopModule (
  input in,
  input [9:0] state,
  output [9:0] next_state,
  output out1,
  output out2
);

  assign next_state[0] = (state[0] & ~in) | (state[1] & ~in) | (state[2] & ~in) | (state[3] & ~in) | (state[4] & ~in) | (state[6] & ~in) | (state[7] & ~in) | (state[8] & ~in) | (state[9] & ~in);
  assign next_state[1] = (state[0] & in) | (state[1] & in) | (state[2] & in) | (state[3] & in) | (state[4] & in) | (state[6] & in) | (state[7] & in) | (state[8] & in) | (state[9] & in);
  assign next_state[2] = (state[1] & ~in) | (state[3] & ~in) | (state[5] & ~in) | (state[6] & ~in) | (state[8] & ~in) | (state[9] & ~in);
  assign next_state[3] = (state[1] & in) | (state[3] & in) | (state[5] & in) | (state[6] & in) | (state[8] & in) | (state[9] & in);
  assign next_state[4] = (state[2] & ~in) | (state[4] & ~in) | (state[5] & ~in) | (state[7] & ~in) | (state[8] & ~in) | (state[9] & ~in);
  assign next_state[5] = (state[2] & in) | (state[4] & in) | (state[5] & in) | (state[7] & in) | (state[8] & in) | (state[9] & in);
  assign next_state[6] = (state[5] & ~in) | (state[6] & ~in) | (state[9] & ~in);
  assign next_state[7] = (state[5] & in) | (state[6] & in) | (state[9] & in);
  assign next_state[8] = (state[7] & ~in) | (state[8] & ~in) | (state[9] & ~in);
  assign next_state[9] = (state[7] & in) | (state[8] & in) | (state[9] & in);

  assign out1 = (state[3] & in) | (state[4] & in) | (state[5] & in) | (state[6] & in) | (state[7] & in) | (state[8] & in) | (state[9] & in);
  assign out2 = (state[2] & in) | (state[3] & in) | (state[5] & in) | (state[6] & in) | (state[7] & in) | (state[8] & in) | (state[9] & in);

endmodule

