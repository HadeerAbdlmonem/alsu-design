vlib work
vlog ALSU_.v test_ALSU.v
vsim -voptargs=+acc work.alsu_tb
add wave *
run -all
