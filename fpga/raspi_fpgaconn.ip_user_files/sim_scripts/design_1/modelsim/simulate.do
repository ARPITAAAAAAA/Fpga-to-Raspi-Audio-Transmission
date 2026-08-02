onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L microblaze_v11_0_0 -L blk_mem_gen_v8_4_2 -L blk_mem_gen_v8_3_6 -L axi_bram_ctrl_v4_1_0 -L dist_mem_gen_v8_0_12 -L lib_pkg_v1_0_2 -L lib_cdc_v1_0_2 -L lib_srl_fifo_v1_0_2 -L fifo_generator_v13_2_3 -L lib_fifo_v1_0_12 -L axi_lite_ipif_v3_0_4 -L interrupt_control_v3_1_4 -L axi_quad_spi_v3_2_17 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_18 -L axi_data_fifo_v2_1_17 -L axi_crossbar_v2_1_19 -L axi_uartlite_v2_0_22 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_15 -L mdm_v3_2_15 -L proc_sys_reset_v5_0_13 -L axi_protocol_converter_v2_1_18 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.design_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {design_1.udo}

run -all

quit -force
