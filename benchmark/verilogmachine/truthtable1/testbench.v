`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input x3,
	input x2,
	input x1,
	output f
);
	
	assign f = ( ~x3 & x2 & ~x1 ) | 
				( ~x3 & x2 & x1 ) |
				( x3 & ~x2 & x1 ) |
				( x3 & x2 & x1 ) ;
	
endmodule


module stimulus_gen (
	input clk,
	output reg x3, x2, x1,
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


	
	initial begin
		{x3, x2, x1} <= 3'h7;
		@(negedge clk) wavedrom_start("All 8 input combinations");
		repeat(8) @(posedge clk) {x3, x2, x1} <= {x3, x2, x1} + 1'b1;
		@(negedge clk) wavedrom_stop();
		repeat(40) @(posedge clk, negedge clk);
		{x3, x2, x1} <= $random;
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_f;
		int errortime_f;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic x3;
	logic x2;
	logic x1;
	logic f_ref;
	logic f_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,x3,x2,x1,f_ref,f_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.x3,
		.x2,
		.x1 );
	reference_module good1 (
		.x3,
		.x2,
		.x1,
		.f(f_ref) );
		
	top_module top_module1 (
		.x3,
		.x2,
		.x1,
		.f(f_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_f) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "f", stats1.errors_f, stats1.errortime_f);
		else $display("Hint: Output '%s' has no mismatches.", "f");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { f_ref } === ( { f_ref } ^ { f_dut } ^ { f_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (f_ref !== ( f_ref ^ f_dut ^ f_ref ))
		begin if (stats1.errors_f == 0) stats1.errortime_f = $time;
			stats1.errors_f = stats1.errors_f+1'b1; end

	end
endmodule
