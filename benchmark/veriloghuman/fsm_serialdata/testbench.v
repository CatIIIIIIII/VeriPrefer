`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input clk,
	input in,
	input reset,
	output [7:0] out_byte,
	output done
);
	parameter B0=0, B1=1, B2=2, B3=3, B4=4, B5=5, B6=6, B7=7, START=8, STOP=9, DONE=10, ERR=11;
	reg [3:0] state;
	reg [3:0] next;
    
    reg [9:0] byte_r;
    
    always_comb begin
		case (state)
			START: next = in ? START : B0;	// start bit is 0
			B0: next = B1;
			B1: next = B2;
			B2: next = B3;
			B3: next = B4;
			B4: next = B5;
			B5: next = B6;
			B6: next = B7;
			B7: next = STOP;
			STOP: next = in ? DONE : ERR;  // stop bit is 1. Idle state is 1.
			DONE: next = in ? START : B0;
			ERR: next = in ? START : ERR;
		endcase
    end
    
    always @(posedge clk) begin
		if (reset) state <= START;
        else state <= next;
	end
	
	always @(posedge clk) begin
		byte_r <= {in, byte_r[9:1]};
	end
		
	assign done = (state==DONE);
	assign out_byte = done ? byte_r[8:1] : 8'hx;
	
endmodule


module stimulus_gen (
	input clk,
	output logic in,
	output logic reset
);

	initial begin
		reset <= 1;
		in <= 1;
		@(posedge clk);
		reset <= 0;
		in <= 0;
		repeat(9) @(posedge clk);
		in <= 1;
		@(posedge clk);
		in <= 0;
		repeat(9) @(posedge clk);
		in <= 1;
		@(posedge clk);
		in <= 0;
		repeat(10) @(posedge clk);
		in <= 1;
		@(posedge clk);
		in <= 0;
		repeat(10) @(posedge clk);
		in <= 1;
		@(posedge clk);
		in <= 0;
		repeat(9) @(posedge clk);
		in <= 1;
		@(posedge clk);
		
		
		
		repeat(800) @(posedge clk, negedge clk) begin
			in <= $random;
			reset <= !($random & 31);
		end

		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_byte;
		int errortime_out_byte;
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

	logic in;
	logic reset;
	logic [7:0] out_byte_ref;
	logic [7:0] out_byte_dut;
	logic done_ref;
	logic done_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,in,reset,out_byte_ref,out_byte_dut,done_ref,done_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in,
		.reset );
	reference_module good1 (
		.clk,
		.in,
		.reset,
		.out_byte(out_byte_ref),
		.done(done_ref) );
		
	top_module top_module1 (
		.clk,
		.in,
		.reset,
		.out_byte(out_byte_dut),
		.done(done_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_byte) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_byte", stats1.errors_out_byte, stats1.errortime_out_byte);
		else $display("Hint: Output '%s' has no mismatches.", "out_byte");
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
	assign tb_match = ( { out_byte_ref, done_ref } === ( { out_byte_ref, done_ref } ^ { out_byte_dut, done_dut } ^ { out_byte_ref, done_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_byte_ref !== ( out_byte_ref ^ out_byte_dut ^ out_byte_ref ))
		begin if (stats1.errors_out_byte == 0) stats1.errortime_out_byte = $time;
			stats1.errors_out_byte = stats1.errors_out_byte+1'b1; end
		if (done_ref !== ( done_ref ^ done_dut ^ done_ref ))
		begin if (stats1.errors_done == 0) stats1.errortime_done = $time;
			stats1.errors_done = stats1.errors_done+1'b1; end

	end
endmodule
