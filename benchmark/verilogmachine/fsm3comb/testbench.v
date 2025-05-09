`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input in,
	input [1:0] state,
	output reg [1:0] next_state,
	output out
);
	parameter A=0, B=1, C=2, D=3;
    
    always_comb begin
		case (state)
			A: next_state = in ? B : A;
			B: next_state = in ? B : C;
			C: next_state = in ? D : A;
			D: next_state = in ? B : C;
		endcase
    end
    
	assign out = (state==D);
	
endmodule


module stimulus_gen (
	input clk,
	output logic in,
	output logic [1:0] state
);

	initial begin
		repeat(100) @(posedge clk, negedge clk) begin
			in <= $random;
			state <= $random;
		end

		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_next_state;
		int errortime_next_state;
		int errors_out;
		int errortime_out;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic in;
	logic [1:0] state;
	logic [1:0] next_state_ref;
	logic [1:0] next_state_dut;
	logic out_ref;
	logic out_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,state,next_state_ref,next_state_dut,out_ref,out_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in,
		.state );
	reference_module good1 (
		.in,
		.state,
		.next_state(next_state_ref),
		.out(out_ref) );
		
	top_module top_module1 (
		.in,
		.state,
		.next_state(next_state_dut),
		.out(out_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_next_state) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "next_state", stats1.errors_next_state, stats1.errortime_next_state);
		else $display("Hint: Output '%s' has no mismatches.", "next_state");
		if (stats1.errors_out) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out", stats1.errors_out, stats1.errortime_out);
		else $display("Hint: Output '%s' has no mismatches.", "out");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { next_state_ref, out_ref } === ( { next_state_ref, out_ref } ^ { next_state_dut, out_dut } ^ { next_state_ref, out_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (next_state_ref !== ( next_state_ref ^ next_state_dut ^ next_state_ref ))
		begin if (stats1.errors_next_state == 0) stats1.errortime_next_state = $time;
			stats1.errors_next_state = stats1.errors_next_state+1'b1; end
		if (out_ref !== ( out_ref ^ out_dut ^ out_ref ))
		begin if (stats1.errors_out == 0) stats1.errortime_out = $time;
			stats1.errors_out = stats1.errors_out+1'b1; end

	end
endmodule
