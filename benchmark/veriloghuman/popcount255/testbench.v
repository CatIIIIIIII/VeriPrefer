`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input [254:0] in,
	output reg [7:0] out
);

	always_comb  begin
		out = 0;
		for (int i=0;i<255;i++)
			out = out + in[i];
	end
	
endmodule


module stimulus_gen (
	input clk,
	output logic [254:0] in,
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
		in <= 255'h0;
		wavedrom_start("");
		@(posedge clk, negedge clk) in <= 255'h0;
		@(posedge clk, negedge clk) in <= 255'h0;
		@(posedge clk, negedge clk) in <= 255'h1;
		@(posedge clk, negedge clk) in <= 255'h1;
		@(posedge clk, negedge clk) in <= 255'h3;
		@(posedge clk, negedge clk) in <= 255'h3;
		@(posedge clk, negedge clk) in <= 255'h7;
		@(posedge clk, negedge clk) in <= 255'haaaa;
		@(posedge clk, negedge clk) in <= 255'hf00000;
		@(posedge clk, negedge clk) in <= 255'h0;
		wavedrom_stop();
		repeat (200) @(posedge clk, negedge clk) begin
			in <= {$random, $random, $random, $random, $random, $random, $random, $random};
		end
		@(posedge clk);
		in <= '0;
		@(posedge clk)
		in <= '1;
		@(posedge clk)
		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
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

	logic [254:0] in;
	logic [7:0] out_ref;
	logic [7:0] out_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,out_ref,out_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	reference_module good1 (
		.in,
		.out(out_ref) );
		
	top_module top_module1 (
		.in,
		.out(out_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
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
	assign tb_match = ( { out_ref } === ( { out_ref } ^ { out_dut } ^ { out_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_ref !== ( out_ref ^ out_dut ^ out_ref ))
		begin if (stats1.errors_out == 0) stats1.errortime_out = $time;
			stats1.errors_out = stats1.errors_out+1'b1; end

	end
endmodule
