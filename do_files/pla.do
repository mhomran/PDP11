vsim -gui work.pla

add wave  \
sim:/pla/uAR \
sim:/pla/IR
force -freeze sim:/pla/IR 16#0 0
run
force -freeze sim:/pla/IR 0000111000000000 0
run
quit -sim
# End time: 23:37:15 on Jan 13,2021, Elapsed time: 0:03:26
# Errors: 0, Warnings: 0
# Compile of PLA.vhd was successful.
vsim -gui work.pla
# vsim -gui work.pla 
# Start time: 23:37:30 on Jan 13,2021
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.pla(plaa)
add wave  \
sim:/pla/uAR \
sim:/pla/IR
force -freeze sim:/pla/IR 16#0 0
run
force -freeze sim:/pla/IR 0000111000000000 0
run

force -freeze sim:/pla/IR 0000101000000000 0
run
force -freeze sim:/pla/IR 0000011000000000 0
run
force -freeze sim:/pla/IR 0000001000000000 0
run

force -freeze sim:/pla/IR 1001001000000000 0
run

force -freeze sim:/pla/IR 1001001000100000 0
run
force -freeze sim:/pla/IR 1001001000010000 0
run
force -freeze sim:/pla/IR 1001001000110000 0
run
force -freeze sim:/pla/IR 1001001000111000 0
run
force -freeze sim:/pla/IR 1001001000001000 0
run