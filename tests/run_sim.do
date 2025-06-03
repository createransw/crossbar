vlib ./work
vlog ./src/round_robin.sv
vlog ./src/stream_xbar.sv
vlog ./tests/stream_xbar_test.sv

vsim ./work.stream_xbar_test

run -all
