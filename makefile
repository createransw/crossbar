VSIM_PATH = path/linuxaloem/vsim
QUARTUS_PATH = path/quartus/bin/quartus_sh
PROJECT_NAME = stream_xbar

test:
	$(VSIM_PATH) -c -do ./tests/run_sim.do

compile:
	$(QUARTUS_PATH) --flow compile $(PROJECT_NAME)
