
module top_module(
    input clk,
    input load,
    input [511:0] data,
    output reg [511:0] q
);

    // Internal register to store the next state
    reg [511:0] next_q;

    // Load the initial state from data if load is high
    always @(posedge clk) begin
        if (load) begin
            q <= data;
        end else begin
            // Update the state of each cell based on Rule 110
            for (integer i = 0; i < 512; i = i + 1) begin
                case ({q[i-1], q[i], q[(i+1) % 512]})
                    3'b111: next_q[i] = 1'b0;
                    3'b110: next_q[i] = 1'b1;
                    3'b101: next_q[i] = 1'b1;
                    3'b100: next_q[i] = 1'b0;
                    3'b011: next_q[i] = 1'b1;
                    3'b010: next_q[i] = 1'b1;
                    3'b001: next_q[i] = 1'b1;
                    3'b000: next_q[i] = 1'b0;
                endcase
            end
            q <= next_q;
        end
    end

endmodule
