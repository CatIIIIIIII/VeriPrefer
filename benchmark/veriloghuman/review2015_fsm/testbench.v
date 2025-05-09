`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module(
	input clk,
	input reset,
	input data,
    output reg shift_ena,
    output reg counting,
    input done_counting,
    output reg done,
    input ack );

	typedef enum logic[3:0] {
		S, S1, S11, S110, B0, B1, B2, B3, Count, Wait
	} States;
	
	States state, next;
	
	always_comb begin
		case (state)
			S: next = States'(data ? S1: S);
			S1: next = States'(data ? S11: S);
			S11: next = States'(data ? S11 : S110);
			S110: next = States'(data ? B0 : S);
			B0: next = B1;
			B1: next = B2;
			B2: next = B3;
			B3: next = Count;
			Count: next = States'(done_counting ? Wait : Count);
			Wait: next = States'(ack ? S : Wait);
			default: next = States'(4'bx);
		endcase
	end
	
	always @(posedge clk) begin
		if (reset) state <= S;
		else state <= next;
	end
		
	always_comb begin
		shift_ena = 0; counting = 0; done = 0;
		if (state == B0 || state == B1 || state == B2 || state == B3)
			shift_ena = 1;
		if (state == Count)
			counting = 1;
		if (state == Wait)
			done = 1;

		if (|state === 1'bx) begin
			{shift_ena, counting, done} = 'x;
		end
		
	end
	
	
endmodule


module stimulus_gen (
	input clk,
	output reg reset,
	output reg data, done_counting, ack,
	input tb_match
);
	bit failed = 0;
	
	always @(posedge clk, negedge clk)
		if (!tb_match) 
			failed <= 1;
	
	initial begin

		@(posedge clk);
		failed <= 0;
		reset <= 1;
		data <= 0;
		done_counting <= 1'bx;
		ack <= 1'bx;
		@(posedge clk) 
			data <= 1;
			reset <= 0;
		@(posedge clk) data <= 0;
		@(posedge clk) data <= 0;
		@(posedge clk) data <= 1;
		@(posedge clk) data <= 1;
		@(posedge clk) data <= 0;
		@(posedge clk) data <= 1;
		@(posedge clk);
			data <= 1'bx;
		repeat(4) @(posedge clk);
			done_counting <= 1'b0;
		repeat(4) @(posedge clk);
			done_counting <= 1'b1;
		@(posedge clk);
			done_counting <= 1'bx;
			ack <= 1'b0;
		repeat(3) @(posedge clk);
			ack <= 1'b1;
		@(posedge clk);
			ack <= 1'b0;
			data <= 1'b1;
		@(posedge clk);
			ack <= 1'bx;
			data <= 1'b1;
		@(posedge clk);
			data <= 1'b0;
		@(posedge clk);
			data <= 1'b1;
		@(posedge clk);
			data <= 1'bx;
		repeat(4) @(posedge clk);
			done_counting <= 1'b0;
		repeat(4) @(posedge clk);
			done_counting <= 1'b1;
		@(posedge clk);

		if (failed)
			$display("Hint: Your FSM didn't pass the sample timing diagram posted with the problem statement. Perhaps try debugging that?");
		
		
	
		repeat(5000) @(posedge clk, negedge clk) begin
			reset <= !($random & 255);
			data <= $random;
			done_counting <= !($random & 31);
			ack <= !($random & 31);
		end

		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_shift_ena;
		int errortime_shift_ena;
		int errors_counting;
		int errortime_counting;
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

	logic reset;
	logic data;
	logic done_counting;
	logic ack;
	logic shift_ena_ref;
	logic shift_ena_dut;
	logic counting_ref;
	logic counting_dut;
	logic done_ref;
	logic done_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,reset,data,done_counting,ack,shift_ena_ref,shift_ena_dut,counting_ref,counting_dut,done_ref,done_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.reset,
		.data,
		.done_counting,
		.ack );
	reference_module good1 (
		.clk,
		.reset,
		.data,
		.done_counting,
		.ack,
		.shift_ena(shift_ena_ref),
		.counting(counting_ref),
		.done(done_ref) );
		
	top_module top_module1 (
		.clk,
		.reset,
		.data,
		.done_counting,
		.ack,
		.shift_ena(shift_ena_dut),
		.counting(counting_dut),
		.done(done_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_shift_ena) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "shift_ena", stats1.errors_shift_ena, stats1.errortime_shift_ena);
		else $display("Hint: Output '%s' has no mismatches.", "shift_ena");
		if (stats1.errors_counting) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "counting", stats1.errors_counting, stats1.errortime_counting);
		else $display("Hint: Output '%s' has no mismatches.", "counting");
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
	assign tb_match = ( { shift_ena_ref, counting_ref, done_ref } === ( { shift_ena_ref, counting_ref, done_ref } ^ { shift_ena_dut, counting_dut, done_dut } ^ { shift_ena_ref, counting_ref, done_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (shift_ena_ref !== ( shift_ena_ref ^ shift_ena_dut ^ shift_ena_ref ))
		begin if (stats1.errors_shift_ena == 0) stats1.errortime_shift_ena = $time;
			stats1.errors_shift_ena = stats1.errors_shift_ena+1'b1; end
		if (counting_ref !== ( counting_ref ^ counting_dut ^ counting_ref ))
		begin if (stats1.errors_counting == 0) stats1.errortime_counting = $time;
			stats1.errors_counting = stats1.errors_counting+1'b1; end
		if (done_ref !== ( done_ref ^ done_dut ^ done_ref ))
		begin if (stats1.errors_done == 0) stats1.errortime_done = $time;
			stats1.errors_done = stats1.errors_done+1'b1; end

	end
endmodule
