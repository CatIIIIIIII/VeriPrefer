
// Define the submodule "top_module"
module top_module(
    input clk,
    input L,
    input q_in,
    input r_in,
    output reg Q
);

// Flip-flop
always @(posedge clk) begin
    if (L) begin
        Q <= r_in;
    end else begin
        Q <= q_in;
    end
end

endmodule

// Define the main module "full_module"
module full_module (
    input [2:0] r,
    input L,
    input clk,
    output reg [2:0] q
);

// Instantiate the top_module three times
top_module u0 (
    .clk(clk),
    .L(L),
    .q_in(q[0]),
    .r_in(r[0]),
    .Q(q[0])
);

top_module u1 (
    .clk(clk),
    .L(L),
    .q_in(q[1]),
    .r_in(r[1]),
    .Q(q[1])
);

top_module u2 (
    .clk(clk),
    .L(L),
    .q_in(q[2]),
    .r_in(r[2]),
    .Q(q[2])
);

endmodule
