
module top_module(
    input d,
    input done_counting,
    input ack,
    input [9:0] state,    // 10-bit one-hot current state
    output B3_next,
    output S_next,
    output S1_next,
    output Count_next,
    output Wait_next,
    output done,
    output counting,
    output shift_ena
);

// State transition logic
assign B3_next = state[7];
assign S_next = (~state[0] & ~d) | (state[3] & ~d) | (state[8] & done_counting & ack);
assign S1_next = (state[0] & d) | (state[1] & ~d) | (state[8] & done_counting & ~ack);
assign S11_next = (state[1] & d) | (state[2] & ~d);
assign S110_next = (state[2] & d);
assign B0_next = state[3] & d;
assign B1_next = state[4];
assign B2_next = state[5];
assign B3_next = state[6];
assign Count_next = state[8] & ~done_counting;
assign Wait_next = state[9] & ~ack;

// Output logic
assign done = state[9];
assign counting = state[8];
assign shift_ena = state[4] | state[5] | state[6];

endmodule
