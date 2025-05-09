`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module(
	input clk,
	input [7:0] in,
	output reg [7:0] anyedge);
	
	reg [7:0] d_last;	
			
	always @(posedge clk) begin
		d_last <= in;
		anyedge <= in ^ d_last;
	end
	
endmodule


module stimulus_gen (
	input clk,
	input tb_match,
	output reg [7:0] in,
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
		in <= 0;
		@(posedge clk);
		@(negedge clk) wavedrom_start("");
		repeat(2) @(posedge clk);
		in <= 1;
		repeat(4) @(posedge clk);
		in <= 0;
		repeat(4) @(negedge clk);
		in <= 6;
		repeat(2) @(negedge clk);
		in <= 0;		
		repeat(2) @(posedge clk);
		@(negedge clk) wavedrom_stop();
			
		repeat(200)
			@(posedge clk, negedge clk) in <= $random;
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_anyedge;
		int errortime_anyedge;

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
	logic [7:0] anyedge_ref;
	logic [7:0] anyedge_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,in,anyedge_ref,anyedge_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	reference_module good1 (
		.clk,
		.in,
		.anyedge(anyedge_ref) );
		
	top_module top_module1 (
		.clk,
		.in,
		.anyedge(anyedge_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_anyedge) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "anyedge", stats1.errors_anyedge, stats1.errortime_anyedge);
		else $display("Hint: Output '%s' has no mismatches.", "anyedge");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { anyedge_ref } === ( { anyedge_ref } ^ { anyedge_dut } ^ { anyedge_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (anyedge_ref !== ( anyedge_ref ^ anyedge_dut ^ anyedge_ref ))
		begin if (stats1.errors_anyedge == 0) stats1.errortime_anyedge = $time;
			stats1.errors_anyedge = stats1.errors_anyedge+1'b1; end

	end
endmodule
