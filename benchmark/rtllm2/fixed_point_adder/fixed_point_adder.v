module fixed_point_adder #(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );
reg [N-1:0] res;

always @(*) begin
    if (a[N-1] == b[N-1]) begin
        // Same sign, add absolute values
        res = {a[N-1], (a[N-2:Q] + b[N-2:Q]), (a[Q-1:0] + b[Q-1:0])};
    end else begin
        // Different signs, perform subtraction
        if (a[N-2:Q] > b[N-2:Q]) begin
            res = {1'b0, (a[N-2:Q] - b[N-2:Q]), (a[Q-1:0] - b[Q-1:0])};
        end else if (a[N-2:Q] < b[N-2:Q]) begin
            res = {(b[N-2:Q] - a[N-2:Q] > a[Q-1:0]), (b[N-2:Q] - a[N-2:Q]), (b[Q-1:0] - a[Q-1:0])};
        end else begin
            res = {(a[Q-1:0] > b[Q-1:0]), (a[N-2:Q] - b[N-2:Q]), (a[Q-1:0] - b[Q-1:0])};
        end
    end
end

assign c = res;

endmodule