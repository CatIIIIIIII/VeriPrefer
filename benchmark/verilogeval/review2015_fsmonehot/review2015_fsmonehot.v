module TopModule (
  input d,
  input done_counting,
  input ack,
  input [9:0] state, // 10-bit one-hot current state
  output B3_next,
  output S_next,
  output S1_next,
  output Count_next,
  output Wait_next,
  output done,
  output counting,
  output shift_ena
);

  wire [9:0] next_state; 

  assign next_state =  (state[0] & ~d)  ? 10'b0000000001 : 
                       (state[0] & d)   ? 10'b0000000010 : 
                       (state[1] & ~d)  ? 10'b0000000001 : 
                       (state[1] & d)   ? 10'b0000000100 : 
                       (state[2] & ~d)  ? 10'b0000000100 : 
                       (state[2] & d)   ? 10'b0000001000 : 
                       (state[3] & ~d)  ? 10'b0000000001 : 
                       (state[3] & d)   ? 10'b0000010000 : 
                       (state[4] & ~d)  ? 10'b0000000010 : 
                       (state[4] & d)   ? 10'b0000100000 : 
                       (state[5] & ~d)  ? 10'b0000000010 : 
                       (state[5] & d)   ? 10'b0001000000 : 
                       (state[6] & ~d)  ? 10'b0000000010 : 
                       (state[6] & d)   ? 10'b0010000000 : 
                       (state[7] & ~d)  ? 10'b0000000010 : 
                       (state[7] & d)   ? 10'b0100000000 : 
                       (state[8] & ~d)  ? 10'b0000000000 : 
                       (state[8] & d)   ? 10'b0000000000 : 
                       (state[9] & ~d)  ? 10'b1000000000 : 
                       (state[9] & d)   ? 10'b0000000000 : 
                       10'b0000000000 ; 

  assign S_next = next_state[0];
  assign S1_next = next_state[1];
  assign B0 = next_state[4];
  assign B1 = next_state[5];
  assign B2 = next_state[6];
  assign B3 = next_state[7];
  assign Count_next = next_state[8];
  assign Wait_next = next_state[9];

  assign B3_next = next_state[7];

  assign done = state[9];
  assign counting = state[8];
  assign shift_ena = state[4] | state[5] | state[6] | state[7];

endmodule

