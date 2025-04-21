
module top_module (
    input in,
    input [9:0] state,
    output [9:0] next_state,
    output out1,
    output out2
);

// Initialize outputs to 0
assign out1 = 0;
assign out2 = 0;

// State transition logic
always @(*) begin
    next_state = 10'b0; // Initialize next_state to all zeros

    case (state)
        10'b0000000001: // S0
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000000010; // S1

        10'b0000000010: // S1
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000000100; // S2

        10'b0000000100: // S2
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000001000; // S3

        10'b0000001000: // S3
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000010000; // S4

        10'b0000010000: // S4
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000100000; // S5

        10'b0000100000: // S5
            if (in == 0)
                next_state = 10'b0001000000; // S8
            else
                next_state = 10'b0001000000; // S6

        10'b0001000000: // S6
            if (in == 0)
                next_state = 10'b0010000000; // S9
            else
                next_state = 10'b0100000000; // S7

        10'b0100000000: // S7
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0100000000; // S7

        10'b0001000000: // S8
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000000010; // S1

        10'b0010000000: // S9
            if (in == 0)
                next_state = 10'b0000000001; // S0
            else
                next_state = 10'b0000000010; // S1

        default:
            next_state = 10'b0000000001; // Default to S0 if state is invalid
    endcase
end

// Output logic
always @(*) begin
    case (state)
        10'b0100000000: // S7
            out1 = 0;
            out2 = 1;

        10'b0001000000: // S8
            out1 = 1;
            out2 = 0;

        10'b0010000000: // S9
            out1 = 1;
            out2 = 1;

        default:
            out1 = 0;
            out2 = 0;
    endcase
end

endmodule
