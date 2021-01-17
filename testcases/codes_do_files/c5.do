vsim -gui work.system
mem load -i ../PDP11/src/control_store.mem -format mti /system/DCU_inst/cs/rom
mem load -i ../PDP11/testcases/assembled/c5.mem /system/RAM_inst/ram

add wave -position 0  sim:/system/clk_input
add wave -position 0 sim:/system/IR/q

add wave -position end  sim:/system/R(0)/R_reg/q
add wave -position end  sim:/system/R(2)/R_reg/q
add wave -position end  sim:/system/R(4)/R_reg/q
add wave -position end  sim:/system/SP/q
add wave -position end sim:/system/FLAGS/q

add wave -position end  sim:/system/DCU_inst/uAR_input
add wave -position end  sim:/system/DCU_inst/PLA_output
add wave -position end  sim:/system/DCU_inst/uAR_output

force -freeze sim:/system/clk_input 0 0, 1 {50 ps} -r 100

run 8700ps
