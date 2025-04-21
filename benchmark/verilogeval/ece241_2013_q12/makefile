
.PHONY: modelsim sim clean

TEST_DESIGN = ece241_2013_q12

modelsim:
	vlib work
	vlog +acc -work work -sv ${TEST_DESIGN}.v testbench.v ref.v

sim:
	vsim -c -do "run -all; quit" tb

clean:
	rm -rf *.log  work transcript vsim.wlf *.vcd
