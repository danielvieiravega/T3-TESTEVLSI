onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_comm_protocol/rst_n
add wave -noupdate /tb_comm_protocol/clk
add wave -noupdate /tb_comm_protocol/send_i
add wave -noupdate /tb_comm_protocol/data_32_i
add wave -noupdate /tb_comm_protocol/busy_o
add wave -noupdate /tb_comm_protocol/msg_o
add wave -noupdate /tb_comm_protocol/valid_o
add wave -noupdate /tb_comm_protocol/data_8_o
add wave -noupdate -color {Medium Slate Blue} /tb_comm_protocol/DUV/current_state
add wave -noupdate -color {Medium Slate Blue} /tb_comm_protocol/DUV/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
