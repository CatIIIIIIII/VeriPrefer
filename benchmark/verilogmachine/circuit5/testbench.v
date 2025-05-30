`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input [3:0] a, 
	input [3:0] b, 
	input [3:0] c, 
	input [3:0] d,
	input [3:0] e,
	output reg [3:0] q
);

	always @(*) 
		case (c)
			0: q = b;
			1: q = e;
			2: q = a;
			3: q = d;
			default: q = 4'hf;
		endcase
	
endmodule


module stimulus_gen (
	input clk,
	output logic [3:0] a,b,c,d,e,
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
		@(negedge clk) wavedrom_start("Unknown circuit");
			@(posedge clk) {a,b,c,d,e} <= {20'hab0de};
			repeat(18) @(posedge clk, negedge clk) c <= c + 1;
		wavedrom_stop();

		@(negedge clk) wavedrom_start("Unknown circuit");
			@(posedge clk) {a,b,c,d,e} <= {20'h12034};
			repeat(8) @(posedge clk, negedge clk) c <= c + 1;
			@(posedge clk) {a,b,c,d,e} <= {20'h56078};
			repeat(8) @(posedge clk, negedge clk) c <= c + 1;
		wavedrom_stop();
		
		repeat(100) @(posedge clk, negedge clk)
			{a,b,c,d,e} <= $urandom;
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_q;
		int errortime_q;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [3:0] a;
	logic [3:0] b;
	logic [3:0] c;
	logic [3:0] d;
	logic [3:0] e;
	logic [3:0] q_ref;
	logic [3:0] q_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,c,d,e,q_ref,q_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b,
		.c,
		.d,
		.e );
	reference_module good1 (
		.a,
		.b,
		.c,
		.d,
		.e,
		.q(q_ref) );
		
	top_module top_module1 (
		.a,
		.b,
		.c,
		.d,
		.e,
		.q(q_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_q) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "q", stats1.errors_q, stats1.errortime_q);
		else $display("Hint: Output '%s' has no mismatches.", "q");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { q_ref } === ( { q_ref } ^ { q_dut } ^ { q_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (q_ref !== ( q_ref ^ q_dut ^ q_ref ))
		begin if (stats1.errors_q == 0) stats1.errortime_q = $time;
			stats1.errors_q = stats1.errors_q+1'b1; end

	end
endmodule
