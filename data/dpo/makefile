.PHONY: vcs sim clean

TB = ./testbench.sv

vcs:
	vcs -full64 -sverilog +v2k -sverilog -debug_access+all \
	-f dut.f \
	-timescale=1ns/1ns \
	-debug_all \
	-cm line+cond+tgl+fsm+assert+branch \
	-cm_line contassign \
	-cm_dir coverage/cov.vdb \
	-l compile.log 								

sim:
	./simv +fsdb+sva_success \
	-cm line+cond+tgl+fsm+assert+branch \
	-cm_line contassign \
	-l run.log

clean:
	rm -rf *.log *.dat *.fsdb *.key *.h ${COVERAGE_DIR} csrc ${LOG_DIR} simv.daidir \
	simv DVEfiles verdiLog *.conf *.rc verdi_config_file coverage urgReport \
	mod0_red_texts.txt mod1_red_texts.txt extracted_*.txt renew_stimulate.txt 

