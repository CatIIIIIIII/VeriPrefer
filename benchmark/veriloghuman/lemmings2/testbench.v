`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input clk,
	input areset,
	input bump_left,
	input bump_right,
	input ground,
	output walk_left,
	output walk_right,
	output aaah
);
	parameter WL=0, WR=1, FALLL=2, FALLR=3;
	reg [1:0] state;
	reg [1:0] next;
    
    always_comb begin
		case (state)
			WL: next = ground ? (bump_left ? WR : WL) : FALLL;
			WR: next = ground ? (bump_right ? WL: WR) : FALLR;
			FALLL: next = ground ? WL : FALLL;
			FALLR: next = ground ? WR : FALLR;
		endcase
    end
    
    always @(posedge clk, posedge areset) begin
		if (areset) state <= WL;
        else state <= next;
	end
		
	assign walk_left = (state==WL);
	assign walk_right = (state==WR);
	assign aaah = (state == FALLL) || (state == FALLR);
	
endmodule


module stimulus_gen (
	input clk,
	output logic areset,
	output logic bump_left,
	output logic bump_right,
	output logic ground,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	input tb_match
);
	reg reset;
	assign areset = reset;

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


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	


	
	initial begin
		reset <= 1'b1;
		{bump_left, bump_right, ground} <= 3'h1;
		reset_test(1);
		{bump_right, bump_left} <= 3'h0;
		wavedrom_start("Falling");
		repeat(3) @(posedge clk);
		{bump_right, bump_left, ground} <= 0;
		repeat(3) @(posedge clk);
		{bump_right, bump_left, ground} <= 3;
		repeat(2) @(posedge clk);
		{bump_right, bump_left, ground} <= 0;
		repeat(3) @(posedge clk);
		{bump_right, bump_left, ground} <= 1;
		repeat(2) @(posedge clk);
		wavedrom_stop();
			
		reset <= 1'b1;
		@(posedge clk);
		repeat(400) @(posedge clk, negedge clk) begin
			{bump_right, bump_left} <= $random & $random;
			ground <= |($random & 7);
			reset <= !($random & 31);
		end

		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_walk_left;
		int errortime_walk_left;
		int errors_walk_right;
		int errortime_walk_right;
		int errors_aaah;
		int errortime_aaah;

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
	logic bump_left;
	logic bump_right;
	logic ground;
	logic walk_left_ref;
	logic walk_left_dut;
	logic walk_right_ref;
	logic walk_right_dut;
	logic aaah_ref;
	logic aaah_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,areset,bump_left,bump_right,ground,walk_left_ref,walk_left_dut,walk_right_ref,walk_right_dut,aaah_ref,aaah_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.areset,
		.bump_left,
		.bump_right,
		.ground );
	reference_module good1 (
		.clk,
		.areset,
		.bump_left,
		.bump_right,
		.ground,
		.walk_left(walk_left_ref),
		.walk_right(walk_right_ref),
		.aaah(aaah_ref) );
		
	top_module top_module1 (
		.clk,
		.areset,
		.bump_left,
		.bump_right,
		.ground,
		.walk_left(walk_left_dut),
		.walk_right(walk_right_dut),
		.aaah(aaah_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_walk_left) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "walk_left", stats1.errors_walk_left, stats1.errortime_walk_left);
		else $display("Hint: Output '%s' has no mismatches.", "walk_left");
		if (stats1.errors_walk_right) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "walk_right", stats1.errors_walk_right, stats1.errortime_walk_right);
		else $display("Hint: Output '%s' has no mismatches.", "walk_right");
		if (stats1.errors_aaah) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "aaah", stats1.errors_aaah, stats1.errortime_aaah);
		else $display("Hint: Output '%s' has no mismatches.", "aaah");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { walk_left_ref, walk_right_ref, aaah_ref } === ( { walk_left_ref, walk_right_ref, aaah_ref } ^ { walk_left_dut, walk_right_dut, aaah_dut } ^ { walk_left_ref, walk_right_ref, aaah_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (walk_left_ref !== ( walk_left_ref ^ walk_left_dut ^ walk_left_ref ))
		begin if (stats1.errors_walk_left == 0) stats1.errortime_walk_left = $time;
			stats1.errors_walk_left = stats1.errors_walk_left+1'b1; end
		if (walk_right_ref !== ( walk_right_ref ^ walk_right_dut ^ walk_right_ref ))
		begin if (stats1.errors_walk_right == 0) stats1.errortime_walk_right = $time;
			stats1.errors_walk_right = stats1.errors_walk_right+1'b1; end
		if (aaah_ref !== ( aaah_ref ^ aaah_dut ^ aaah_ref ))
		begin if (stats1.errors_aaah == 0) stats1.errortime_aaah = $time;
			stats1.errors_aaah = stats1.errors_aaah+1'b1; end

	end
endmodule
