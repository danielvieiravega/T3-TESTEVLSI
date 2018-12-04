if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -cover sbcefx comm_protocol.vhd
vcom -cover sbcefx tb_comm_protocol.vhd

vsim -assertdebug -coverage -t 1ns work.tb_comm_protocol
view assertions
view fcovers

do wave.do
#add wave /DUV/rst_clean
#add wave /DUV/send_1clk
#add wave /DUV/msg_start
#add wave /DUV/msg_size
#add wave /DUV/msg_inv_dst
#add wave /DUV/serv_msg
#add wave /DUV/serv_cnt
#add wave /DUV/fsm_hdr
#add wave /DUV/fsm_crc
#add wave /DUV/buf_cnt
#add wave /DUV/buf_crc
#add wave /DUV/buf_src
#add wave /DUV/buf_dst
#add wave /DUV/buf_size
#add wave /DUV/buf_pld1
#add wave /DUV/buf_pld2
#add wave /DUV/buf_pld3
#add wave /DUV/buf_pld4

set StdArithNoWarnings 1

run 2 us

coverage report -file coverage_rep
coverage save  coverage
