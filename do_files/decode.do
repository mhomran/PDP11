vsim -gui work.dcu
add wave  \
sim:/dcu/IR \
sim:/dcu/clk \
sim:/dcu/PLA_out \
sim:/dcu/PLA_output \
sim:/dcu/uAR_output \
sim:/dcu/uIR \
sim:/dcu/uAR_input

mem load -i {../PDP11/src/control_store.mem} /system/DCU_inst/cs/rom

force -freeze sim:/dcu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/dcu/IR 0000110110110110 0
run
run