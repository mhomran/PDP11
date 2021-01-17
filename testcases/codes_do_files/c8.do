vsim -gui work.system
mem load -i ../PDP11/src/control_store.mem -format mti /system/DCU_inst/cs/rom
mem load -i ../PDP11/testcases/assembled/c8.mem /system/RAM_inst/ram

add wave -position 0  sim:/system/clk_input
add wave -position 0 sim:/system/IR/q
add wave -position end  sim:/system/R(1)/R_reg/q
add wave -position end  sim:/system/R(2)/R_reg/q
add wave -position end  sim:/system/R(4)/R_reg/q

add wave sim:/system/PC/q
add wave sim:/system/SP/q
add wave -position end  sim:/system/DCU_inst/uAR_output

add wave  sim:/system/IRQ
force -freeze sim:/system/clk_input 0 0, 1 {50 ps} -r 100
run 2000ps
force -freeze sim:/system/IRQ 1 0
run 1000ps
force -freeze sim:/system/IRQ 0 0
run 8800ps
