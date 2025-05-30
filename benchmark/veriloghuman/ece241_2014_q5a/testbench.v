`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input clk,
	input areset,
	input x,
	output z
);

	parameter A=0,B=1,C=2;
	reg [1:0] state;
	always @(posedge clk, posedge areset) begin
		if (areset)
			state <= A;
		else begin
			case (state)
				A: state <= x ? C : A;
				B: state <= x ? B : C;
				C: state <= x ? B : C;
			endcase
		end
	end
	
	assign z = (state == C);
	
endmodule


module stimulus_gen (
	input clk,
	output logic x,
	output logic areset,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	input tb_match
);
	reg reset;
	assign areset = reset;

// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	


	task reset_test(input async=0);
		bit arfail, srfail, datafail;
	
		@(posedge clk);
		@(posedge clk) reset <= 0;
		repeat(3) @(posedge clk);
	
		@(negedge clk) begin datafail = !tb_match ; reset <= 1; end
		@(posedge clk) arfail = !tb_match;
		@(posedge clk) begin
			srfail = !tb_match;
			reset <= 0;
		end
		if (srfail)
			$display("Hint: Your reset doesn't seem to be working.");
		else if (arfail && (async || !datafail))
			$display("Hint: Your reset should be %0s, but doesn't appear to be.", async ? "asynchronous" : "synchronous");
		// Don't warn about synchronous reset if the half-cycle before is already wrong. It's more likely
		// a functionality error than the reset being implemented asynchronously.
	
	endtask


	initial begin
		x <= 0;
		reset <= 1;
		@(posedge clk) reset <= 0; x <= 1;
		@(posedge clk) x <= 0;
		reset_test(1);
		
		@(negedge clk) wavedrom_start();
			@(posedge clk) {reset,x} <= 2'h2;
			@(posedge clk) {reset,x} <= 2'h0;
			@(posedge clk) {reset,x} <= 2'h0;
			@(posedge clk) {reset,x} <= 2'h1;
			@(posedge clk) {reset,x} <= 2'h0;
			@(posedge clk) {reset,x} <= 2'h1;
			@(posedge clk) {reset,x} <= 2'h1;
			@(posedge clk) {reset,x} <= 2'h0;
			@(posedge clk) {reset,x} <= 2'h0;
		@(negedge clk) wavedrom_stop();
		repeat(400) @(posedge clk, negedge clk)
			{reset,x} <= {($random&31) == 0, ($random&1)==0 };

		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_z;
		int errortime_z;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic areset;
	logic x;
	logic z_ref;
	logic z_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,areset,x,z_ref,z_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.areset,
		.x );
	reference_module good1 (
		.clk,
		.areset,
		.x,
		.z(z_ref) );
		
	top_module top_module1 (
		.clk,
		.areset,
		.x,
		.z(z_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_z) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "z", stats1.errors_z, stats1.errortime_z);
		else $display("Hint: Output '%s' has no mismatches.", "z");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { z_ref } === ( { z_ref } ^ { z_dut } ^ { z_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (z_ref !== ( z_ref ^ z_dut ^ z_ref ))
		begin if (stats1.errors_z == 0) stats1.errortime_z = $time;
			stats1.errors_z = stats1.errors_z+1'b1; end

	end
endmodule
