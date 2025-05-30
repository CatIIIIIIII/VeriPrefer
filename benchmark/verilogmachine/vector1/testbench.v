`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input [15:0] in,
	output [7:0] out_hi,
	output [7:0] out_lo
);
	
	assign {out_hi, out_lo} = in;
	
endmodule


module stimulus_gen (
	input clk,
	output logic [15:0] in,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable	
);


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	



	always @(posedge clk, negedge clk)
		in <= $random;
	
	initial begin
		wavedrom_start("Random inputs");
		repeat(10) @(posedge clk);
		wavedrom_stop();
		repeat(100) @(negedge clk);
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_hi;
		int errortime_out_hi;
		int errors_out_lo;
		int errortime_out_lo;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [15:0] in;
	logic [7:0] out_hi_ref;
	logic [7:0] out_hi_dut;
	logic [7:0] out_lo_ref;
	logic [7:0] out_lo_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,out_hi_ref,out_hi_dut,out_lo_ref,out_lo_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	reference_module good1 (
		.in,
		.out_hi(out_hi_ref),
		.out_lo(out_lo_ref) );
		
	top_module top_module1 (
		.in,
		.out_hi(out_hi_dut),
		.out_lo(out_lo_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_hi) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_hi", stats1.errors_out_hi, stats1.errortime_out_hi);
		else $display("Hint: Output '%s' has no mismatches.", "out_hi");
		if (stats1.errors_out_lo) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_lo", stats1.errors_out_lo, stats1.errortime_out_lo);
		else $display("Hint: Output '%s' has no mismatches.", "out_lo");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_hi_ref, out_lo_ref } === ( { out_hi_ref, out_lo_ref } ^ { out_hi_dut, out_lo_dut } ^ { out_hi_ref, out_lo_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_hi_ref !== ( out_hi_ref ^ out_hi_dut ^ out_hi_ref ))
		begin if (stats1.errors_out_hi == 0) stats1.errortime_out_hi = $time;
			stats1.errors_out_hi = stats1.errors_out_hi+1'b1; end
		if (out_lo_ref !== ( out_lo_ref ^ out_lo_dut ^ out_lo_ref ))
		begin if (stats1.errors_out_lo == 0) stats1.errortime_out_lo = $time;
			stats1.errors_out_lo = stats1.errors_out_lo+1'b1; end

	end
endmodule
