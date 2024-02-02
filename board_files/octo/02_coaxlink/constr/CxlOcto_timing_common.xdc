#-------------------------------------------------------------------------------
#-- NOTE: THIS FILE SHALL NOT BE MODIFIED.
#-------------------------------------------------------------------------------


################################################################################
# Primary Clocks
################################################################################
create_clock -period 4.000 -name cxph_gth_clk [get_ports cxph_gth_clk_p]


################################################################################
## Those signals are static signals. Once re/set they will stay LOW/HIGH.
## The multi cycle path constraint is added to improve the timing.

set_multicycle_path -setup 8 -from [get_pins */*/iMemorySizeChecker/SizeCheckDone_reg/C]
set_multicycle_path -hold -end 7 -from [get_pins */*/iMemorySizeChecker/SizeCheckDone_reg/C]

set_multicycle_path -setup 8 -from [get_pins */*/iMemorySizeChecker/FullSizeMem_reg/C]
set_multicycle_path -hold -end 7 -from [get_pins */*/iMemorySizeChecker/FullSizeMem_reg/C]


################################################################################
# I/O Constraints
################################################################################
# Multicycle path for Input I/Os
set_multicycle_path 5 -setup -from [get_ports io_ext1[3]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[3]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[4]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[4]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[5]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[5]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[6]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[6]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[7]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[7]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[8]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[8]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[9]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[9]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[10]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[10]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[11]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[11]]
set_multicycle_path 5 -setup -from [get_ports io_ext1[12]]
set_multicycle_path 4 -hold -end -from [get_ports io_ext1[12]]
# Multicycle path for Output I/Os
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[3]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[3]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[4]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[4]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[5]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[5]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[6]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[6]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[7]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[7]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[8]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[8]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[9]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[9]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[10]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[10]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[11]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[11]]
set_multicycle_path 5 -setup -start -to [get_ports io_ext1[12]]
set_multicycle_path 4 -hold -to [get_ports io_ext1[12]]
# Input delays
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[3]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[4]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[5]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[6]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[7]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[8]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[9]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[10]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[11]]
set_input_delay -clock extio_clk -max 8.000 [get_ports io_ext1[12]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[3]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[4]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[5]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[6]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[7]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[8]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[9]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[10]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[11]]
set_input_delay -clock extio_clk -min 2.000 [get_ports io_ext1[12]]
# Output delays
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[2]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[3]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[4]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[5]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[6]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[7]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[8]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[9]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[10]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[11]]
set_output_delay -clock extio_clk -max 7.000 [get_ports io_ext1[12]]
set_output_delay -clock extio_clk -max 0.000 [get_ports io_ext1[2]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[3]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[4]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[5]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[6]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[7]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[8]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[9]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[10]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[11]]
set_output_delay -clock extio_clk -min 0.000 [get_ports io_ext1[12]]
# False paths
set_false_path -from [get_ports {io_ext1[9]}] -to [get_ports {io_ext1[9]}]
set_false_path -from [get_ports {io_ext1[10]}] -to [get_ports {io_ext1[10]}]

set_false_path -from [get_ports {io_ext1[1]}]

set_false_path -to [get_ports {io_ext1[2]}] -through [get_pins {io_ext1_IOBUF[4]_inst/T}]
set_false_path -from [get_ports {io_ext1[2]}] -through [get_pins {io_ext1_IOBUF[4]_inst/T}]
set_false_path -to [get_ports {io_ext1[3]}] -through [get_pins {io_ext1_IOBUF[3]_inst/T}]
set_false_path -from [get_ports {io_ext1[3]}] -through [get_pins {io_ext1_IOBUF[3]_inst/T}]
set_false_path -to [get_ports {io_ext1[4]}] -through [get_pins {io_ext1_IOBUF[4]_inst/T}]
set_false_path -from [get_ports {io_ext1[4]}] -through [get_pins {io_ext1_IOBUF[4]_inst/T}]
set_false_path -to [get_ports {io_ext1[5]}] -through [get_pins {io_ext1_IOBUF[5]_inst/T}]
set_false_path -from [get_ports {io_ext1[5]}] -through [get_pins {io_ext1_IOBUF[5]_inst/T}]
set_false_path -to [get_ports {io_ext1[6]}] -through [get_pins {io_ext1_IOBUF[6]_inst/T}]
set_false_path -from [get_ports {io_ext1[6]}] -through [get_pins {io_ext1_IOBUF[6]_inst/T}]
set_false_path -to [get_ports {io_ext1[7]}] -through [get_pins {io_ext1_IOBUF[7]_inst/T}]
set_false_path -from [get_ports {io_ext1[7]}] -through [get_pins {io_ext1_IOBUF[7]_inst/T}]
set_false_path -to [get_ports {io_ext1[8]}] -through [get_pins {io_ext1_IOBUF[8]_inst/T}]
set_false_path -from [get_ports {io_ext1[8]}] -through [get_pins {io_ext1_IOBUF[8]_inst/T}]
set_false_path -to [get_ports {io_ext1[9]}] -through [get_pins {io_ext1_IOBUF[9]_inst/T}]
set_false_path -from [get_ports {io_ext1[9]}] -through [get_pins {io_ext1_IOBUF[9]_inst/T}]
set_false_path -to [get_ports {io_ext1[10]}] -through [get_pins {io_ext1_IOBUF[10]_inst/T}]
set_false_path -from [get_ports {io_ext1[10]}] -through [get_pins {io_ext1_IOBUF[10]_inst/T}]
set_false_path -to [get_ports {io_ext1[11]}] -through [get_pins {io_ext1_IOBUF[11]_inst/T}]
set_false_path -from [get_ports {io_ext1[11]}] -through [get_pins {io_ext1_IOBUF[11]_inst/T}]
set_false_path -to [get_ports {io_ext1[12]}] -through [get_pins {io_ext1_IOBUF[12]_inst/T}]
set_false_path -from [get_ports {io_ext1[12]}] -through [get_pins {io_ext1_IOBUF[12]_inst/T}]


################################################################################
# CDC Inter-Clock Constraints
################################################################################

# -- CoaxPress downlink tport constraints -----------------------------
set_false_path -from [get_pins {iCoaxlinkCore/iCxphGth/gth_inst/inst/gen_gtwizard_gthe3_top.gth_cxp_low_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins {iCoaxlinkCore/iCxphTportDl*/gtx_resetdone_s_reg[2]/D}]
set_false_path -from [get_pins */iCxphTportDl*/dl_ce_reg/C] -to [get_pins {*/iCxphTportDl*/dl_lock_s_reg[1]/D}]
set_false_path -from [get_pins */iCxphTportDl*/dl_rate_ch_t_reg/C] -to [get_pins {iCoaxlinkCore/iCxphTportDl*/dl_rate_ch_t_s_reg[2]/D}]
set_false_path -from [get_pins */iCxphTportDl*/dl_relock_req_t_reg/C] -to [get_pins {*/iCxphTportDl*/dl_relock_req_t_s_reg[2]/D}]
set_false_path -from [get_pins {*/iCxphTportDl*/dl_lock_s_reg[*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncLock_s_reg[2]/D}]

# -- CoaxPress internal core constraints -----------------------------
set_max_delay -datapath_only -from [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_ce_t_reg/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_ce_s_reg[2]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/MULTILINK_GEN[*].LINK_INST/tport_ul_data_reg[*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_data_s_1_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/MULTILINK_GEN[*].LINK_INST/tport_ul_k_reg/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_k_s_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_ce_reg/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_presc_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/tx_sr_reg[*]/R}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/CSR_INST/regs_tportcsr_reg[*][*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_presc_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/*/*/CSR_INST/regs_tportcsr_reg[*][*]/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_ce_reg/D}] 8.0


# -- CXP LINK ERROR COUNTER constraints -----------------------------
set_false_path -from [get_pins {*/*/*/MULTILINK_GEN[*].LINK_ERR_CNT_INST/ResetEncCnt_t_reg/C}] -to [get_pins {*/*/*/MULTILINK_GEN[*].LINK_ERR_CNT_INST/ResetEncCnt_s_reg[2]/D}]
set_false_path -to [get_pins {*/*/*/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncErrCnt_s_reg[*]/D}]
set_false_path -to [get_pins {*/*/*/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncErrDspOVF_s_reg[*]/D}]


# -- Video Backend constraints -----------------------------
set_max_delay -datapath_only -from [get_pins {*/iVideo/FB_INST/axi_read_sts_reg[*]/C}] -to [get_pins {*/iVideo/FB_INST/axi_read_sts_clk250_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/iVideo/FB_INST/axi_write_sts_reg[*]/C}] -to [get_pins {*/iVideo/FB_INST/axi_write_sts_clk250_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/iVideo/fb_MemDWLevel_d1_reg[*]/C}] -to [get_pins {*/iVideo/Framestore_MemDWLevel_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins {*/iVideo/STM_PROC_INST/iStmParser/s2_hdr_img_SourceTag_reg[*]/C}] -to [get_pins {*/iVideo/VideoEventSignaling_reg[ImgSourceTag][*]/D}] 8.0


# -- Timestamp Interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins */iTimestamp/Inst_TimeStamp/bl.DSP48E_2/DSP_OUTPUT_INST/CLK] -to [get_pins {*/iVideo/Timstamp_aclk_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins */iTimestamp/toggle_clk125_reg/C] -to [get_pins {*/iTimestamp/toggle_user_clk_s_reg[2]/D}] 8.0


# -- Fan Control Interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins {*/iFanSpeedMeasure/FanPulseCounter_l_reg[*]/C}] -to [get_pins {*/iFanSpeedMeasure/FanSpeedMeasured_i_reg[*]/D}] 8.000