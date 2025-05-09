`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input clk,
	input [7:0] in,
	input reset,
	output [23:0] out_bytes,
	output done
);
	parameter BYTE1=0, BYTE2=1, BYTE3=2, DONE=3;
	reg [1:0] state;
	reg [1:0] next;
    
    wire in3 = in[3];
    
    always_comb begin
		case (state)
			BYTE1: next = in3 ? BYTE2 : BYTE1;
			BYTE2: next = BYTE3;
			BYTE3: next = DONE;
			DONE: next = in3 ? BYTE2 : BYTE1;
		endcase
    end
    
    always @(posedge clk) begin
		if (reset) state <= BYTE1;
        else state <= next;
	end
		
	assign done = (state==DONE);
	
	reg [23:0] out_bytes_r;
	always @(posedge clk)
		out_bytes_r <= {out_bytes_r[15:0], in};
	
	// Implementations may vary: Allow user to do anything while the output doesn't have to be valid.	
	assign out_bytes = done ? out_bytes_r : 'x;		
	
endmodule


module stimulus_gen (
	input clk,
	output logic [7:0] in,
	output logic reset
);

	initial begin
		repeat(200) @(negedge clk) begin
			in <= $random;
			reset <= !($random & 31);
		end
		reset <= 1'b0;
		in <= '0;
		repeat(10) @(posedge clk);
		
		repeat(200) begin
			in <= $random;
			in[3] <= 1'b1;
			@(posedge clk);
			in <= $random;
			@(posedge clk);
			in <= $random;
			@(posedge clk);
		end

		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_bytes;
		int errortime_out_bytes;
		int errors_done;
		int errortime_done;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [7:0] in;
	logic reset;
	logic [23:0] out_bytes_ref;
	logic [23:0] out_bytes_dut;
	logic done_ref;
	logic done_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,in,reset,out_bytes_ref,out_bytes_dut,done_ref,done_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in,
		.reset );
	reference_module good1 (
		.clk,
		.in,
		.reset,
		.out_bytes(out_bytes_ref),
		.done(done_ref) );
		
	top_module top_module1 (
		.clk,
		.in,
		.reset,
		.out_bytes(out_bytes_dut),
		.done(done_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_bytes) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_bytes", stats1.errors_out_bytes, stats1.errortime_out_bytes);
		else $display("Hint: Output '%s' has no mismatches.", "out_bytes");
		if (stats1.errors_done) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "done", stats1.errors_done, stats1.errortime_done);
		else $display("Hint: Output '%s' has no mismatches.", "done");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_bytes_ref, done_ref } === ( { out_bytes_ref, done_ref } ^ { out_bytes_dut, done_dut } ^ { out_bytes_ref, done_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_bytes_ref !== ( out_bytes_ref ^ out_bytes_dut ^ out_bytes_ref ))
		begin if (stats1.errors_out_bytes == 0) stats1.errortime_out_bytes = $time;
			stats1.errors_out_bytes = stats1.errors_out_bytes+1'b1; end
		if (done_ref !== ( done_ref ^ done_dut ^ done_ref ))
		begin if (stats1.errors_done == 0) stats1.errortime_done = $time;
			stats1.errors_done = stats1.errors_done+1'b1; end

	end
endmodule
