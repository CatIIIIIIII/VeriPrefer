`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input [7:0] in,
	output parity
);

	assign parity = ^in;
	
endmodule


module stimulus_gen (
	input clk,
	output logic [7:0] in
);

	initial begin
		repeat(100) @(posedge clk, negedge clk)
			in <= $random;
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_parity;
		int errortime_parity;

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
	logic parity_ref;
	logic parity_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,parity_ref,parity_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	reference_module good1 (
		.in,
		.parity(parity_ref) );
		
	top_module top_module1 (
		.in,
		.parity(parity_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_parity) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "parity", stats1.errors_parity, stats1.errortime_parity);
		else $display("Hint: Output '%s' has no mismatches.", "parity");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { parity_ref } === ( { parity_ref } ^ { parity_dut } ^ { parity_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (parity_ref !== ( parity_ref ^ parity_dut ^ parity_ref ))
		begin if (stats1.errors_parity == 0) stats1.errortime_parity = $time;
			stats1.errors_parity = stats1.errors_parity+1'b1; end

	end
endmodule
