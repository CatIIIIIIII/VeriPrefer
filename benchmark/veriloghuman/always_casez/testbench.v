`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input [7:0] in,
	output reg [2:0] pos
);

	always @(*) begin
		casez (in)
			default : pos = 2'h0;
			8'bzzzzzzz1: pos = 3'h0;
			8'bzzzzzz1z: pos = 3'h1;
			8'bzzzzz1zz: pos = 3'h2;
			8'bzzzz1zzz: pos = 3'h3;
			8'bzzz1zzzz: pos = 3'h4;
			8'bzz1zzzzz: pos = 3'h5;
			8'bz1zzzzzz: pos = 3'h6;
			8'b1zzzzzzz: pos = 3'h7;
		endcase
	end
	
endmodule


module stimulus_gen (
	input clk,
	output logic [7:0] in, 
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
		@(negedge clk) wavedrom_start("Priority encoder");
			@(posedge clk) in <= 8'h1;
			repeat(8) @(posedge clk) in <= in << 1;
			in <= 8'h10;
			repeat(8) @(posedge clk) in <= in + 1;
		@(negedge clk) wavedrom_stop();

		repeat(50) @(posedge clk, negedge clk) begin
			in <= $urandom;
		end
		repeat(260) @(posedge clk, negedge clk) begin
			in <= in + 1;
		end
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_pos;
		int errortime_pos;

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
	logic [2:0] pos_ref;
	logic [2:0] pos_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,pos_ref,pos_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	reference_module good1 (
		.in,
		.pos(pos_ref) );
		
	top_module top_module1 (
		.in,
		.pos(pos_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_pos) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "pos", stats1.errors_pos, stats1.errortime_pos);
		else $display("Hint: Output '%s' has no mismatches.", "pos");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { pos_ref } === ( { pos_ref } ^ { pos_dut } ^ { pos_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (pos_ref !== ( pos_ref ^ pos_dut ^ pos_ref ))
		begin if (stats1.errors_pos == 0) stats1.errortime_pos = $time;
			stats1.errors_pos = stats1.errors_pos+1'b1; end

	end
endmodule
