module fixed_point_subtractor #(
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
            // Same sign, subtract directly
            res = a - b;
        end else if (a[N-1] == 1'b0) begin
            // a is positive, b is negative
            if (a > -b) begin
                res = a + b;
                res[N-1] = 1'b0; // Set result to positive
            end else begin
                res = -((a - b) >>> Q);
            end
        end else begin
            // a is negative, b is positive
            if (-a > b) begin
                res = -a - b;
                res[N-1] = 1'b1; // Set result to negative
            end else begin
                res = (b - a) >>> Q;
                res[N-1] = 1'b0; // Set result to positive
            end
        end

        // Set sign bit to 0 if result is zero
        if (res == 0) begin
            res[N-1] = 1'b0;
        end
    end

    assign c = res;

endmodule