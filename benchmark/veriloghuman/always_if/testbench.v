`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input a,
	input b,
	input sel_b1,
	input sel_b2,
	output out_assign,
	output reg out_always
);

	assign out_assign = (sel_b1 & sel_b2) ? b : a;
	always @(*) out_always = (sel_b1 & sel_b2) ? b : a;
	
endmodule


module stimulus_gen (
	input clk,
	output logic a,b,sel_b1, sel_b2,
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
		{a, b, sel_b1, sel_b2} <= 4'b000;
		@(negedge clk) wavedrom_start("");
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0100;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1000;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1101;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0001;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0110;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1010;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1111;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0011;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0111;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1011;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b1111;
			@(posedge clk, negedge clk) {a,b,sel_b1,sel_b2} <= 4'b0011;
		wavedrom_stop();
		repeat(100) @(posedge clk, negedge clk)
			{a,b,sel_b1,sel_b2} <= $urandom;
		$finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_assign;
		int errortime_out_assign;
		int errors_out_always;
		int errortime_out_always;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic a;
	logic b;
	logic sel_b1;
	logic sel_b2;
	logic out_assign_ref;
	logic out_assign_dut;
	logic out_always_ref;
	logic out_always_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,sel_b1,sel_b2,out_assign_ref,out_assign_dut,out_always_ref,out_always_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b,
		.sel_b1,
		.sel_b2 );
	reference_module good1 (
		.a,
		.b,
		.sel_b1,
		.sel_b2,
		.out_assign(out_assign_ref),
		.out_always(out_always_ref) );
		
	top_module top_module1 (
		.a,
		.b,
		.sel_b1,
		.sel_b2,
		.out_assign(out_assign_dut),
		.out_always(out_always_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_assign) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_assign", stats1.errors_out_assign, stats1.errortime_out_assign);
		else $display("Hint: Output '%s' has no mismatches.", "out_assign");
		if (stats1.errors_out_always) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_always", stats1.errors_out_always, stats1.errortime_out_always);
		else $display("Hint: Output '%s' has no mismatches.", "out_always");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_assign_ref, out_always_ref } === ( { out_assign_ref, out_always_ref } ^ { out_assign_dut, out_always_dut } ^ { out_assign_ref, out_always_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_assign_ref !== ( out_assign_ref ^ out_assign_dut ^ out_assign_ref ))
		begin if (stats1.errors_out_assign == 0) stats1.errortime_out_assign = $time;
			stats1.errors_out_assign = stats1.errors_out_assign+1'b1; end
		if (out_always_ref !== ( out_always_ref ^ out_always_dut ^ out_always_ref ))
		begin if (stats1.errors_out_always == 0) stats1.errortime_out_always = $time;
			stats1.errors_out_always = stats1.errors_out_always+1'b1; end

	end
endmodule
