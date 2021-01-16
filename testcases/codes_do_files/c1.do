vsim -gui work.system
mem load -i Z:/college/arch/PDP11/src/control_store.mem -format mti /system/DCU_inst/cs/rom
mem load -i Z:/college/arch/PDP11/c1.mem /system/RAM_inst/ram
mem load -i Z:/college/arch/PDP11/c1.mem /system/RAM_inst/ram

add wave -position 0  sim:/system/clk_input
add wave -position 0 sim:/system/IR/q

add wave -position end  sim:/system/R(0)/R_reg/q
add wave -position end  sim:/system/R(1)/R_reg/q
add wave -position 4  sim:/system/R(2)/R_reg/q
add wave -position end  sim:/system/R(4)/R_reg/q
add wave -position end  sim:/system/SP/q

add wave -position end  sim:/system/DCU_inst/uAR_input
add wave -position end  sim:/system/DCU_inst/PLA_output
add wave -position 7  sim:/system/DCU_inst/uAR_output

force -freeze sim:/system/clk_input 0 0, 1 {50 ps} -r 100

run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
add wave -position 7 sim:/system/FLAGS/q
run
add wave -position end  sim:/system/ALU_inst/F
add wave -position end  sim:/system/ALU_inst/ALU_FLAGS
add wave -position end  sim:/system/ALU_inst/F_temp
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
add wave -position 2  sim:/system/clk
run
run