#-------------------------------------------------------------------------------
#-- NOTE: THIS FILE SHALL NOT BE MODIFIED.
#-------------------------------------------------------------------------------

################################################################################
# PCIe Timing Constraints
################################################################################
# create_clock -period 10.000 -name sys_clk [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/ODIV2}]
# create_clock -period 10.000 -name sys_clk_gt [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/O}]
create_generated_clock -name sys_clk_bufg -source [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/ODIV2}] -divide_by 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/bufg_gt_sysclk/O}]

# TXOUTCLKSEL switches during reset. Set the tool to analyze timing with TXOUTCLKSEL set to 'b101.
set_case_analysis 1 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[2]}]
set_case_analysis 0 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[1]}]
# set_case_analysis 1 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[0]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/*gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXRATE[0]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/*gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXRATE[0]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/*gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXRATE[1]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/*gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXRATE[1]}]

# Set Divide By 2
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[1]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[2]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[0]}]
# Set Divide By 2
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[0]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[1]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[2]}]
# Set Divide By 4
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/bufg_mcap_clk/DIV[0]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/bufg_mcap_clk/DIV[1]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/bufg_mcap_clk/DIV[2]}]
# Set Divide By 1
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[0]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[1]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[2]}]

set_false_path -from [get_ports perst_n]
set_false_path -through [get_cells -hierarchical -filter {NAME =~ */d2_user_rst_reg}]
create_clock -period 10.000 -name pcie_clk_p [get_ports pcie_clk_p]

# CDC Registers
# This path is crossing clock domains between pipe_clk and sys_clk
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/prst_n_r_reg[7]/C}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_prst_n/sync_vec[0].sync_cell_i/sync_reg[0]/D}]
# These paths are crossing clock domains between sys_clk and user_clk
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/idle_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/pcie3_uscale_top_inst/init_ctrl_inst/reg_phy_rdy_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_phystatus/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_rxresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_txresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]

# Asynchronous Pins
# These pins are not associated with any clock domain
set_false_path -through [get_pins -hierarchical -filter NAME=~*/RXELECIDLE]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/PCIEPERST0B]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/PCIERATEGEN3]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/RXPRGDIVRESETDONE]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/TXPRGDIVRESETDONE]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/PCIESYNCTXSYNCDONE]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/GTPOWERGOOD]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/CPLLLOCK]
set_false_path -through [get_pins -hierarchical -filter NAME=~*/QPLL1LOCK]

####################################################################################
# Update QPLL1 settings for PCIe GTH transceivers to avoid PCIe link-up issues.
# Visit https://support.xilinx.com/s/article/000035719?language=en_US for details.
####################################################################################

set_property QPLL1_CFG2         16'h0040 [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.GTHE3_COMMON && PARENT =~ "*pcie*" }]; # original value causing failures in PCIe link-up (spread-spectrum clock enabled): 16'h0000
set_property QPLL1_LOCK_CFG     16'h21E8 [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.GTHE3_COMMON && PARENT =~ "*pcie*" }]; # original value causing failures in PCIe link-up (spread-spectrum clock enabled): 16'h25E8
set_property QPLL1_LOCK_CFG_G3  16'h21E8 [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.GTHE3_COMMON && PARENT =~ "*pcie*" }]; # original value causing failures in PCIe link-up (spread-spectrum clock enabled): 16'h25E8

################################################################################
# Primary Clocks
################################################################################


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
create_generated_clock -name extio_clk -source [get_pins -hierarchical "bufg_gt_userclk/O"] -edges {1 5 11} [get_ports io_ext1[1]]
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
set_false_path -to [get_ports {io_ext1[2]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[4]_inst/T}]
set_false_path -from [get_ports {io_ext1[2]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[4]_inst/T}]
set_false_path -to [get_ports {io_ext1[3]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[3]_inst/T}]
set_false_path -from [get_ports {io_ext1[3]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[3]_inst/T}]
set_false_path -to [get_ports {io_ext1[4]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[4]_inst/T}]
set_false_path -from [get_ports {io_ext1[4]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[4]_inst/T}]
set_false_path -to [get_ports {io_ext1[5]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[5]_inst/T}]
set_false_path -from [get_ports {io_ext1[5]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[5]_inst/T}]
set_false_path -to [get_ports {io_ext1[6]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[6]_inst/T}]
set_false_path -from [get_ports {io_ext1[6]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[6]_inst/T}]
set_false_path -to [get_ports {io_ext1[7]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[7]_inst/T}]
set_false_path -from [get_ports {io_ext1[7]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[7]_inst/T}]
set_false_path -to [get_ports {io_ext1[8]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[8]_inst/T}]
set_false_path -from [get_ports {io_ext1[8]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[8]_inst/T}]
set_false_path -to [get_ports {io_ext1[9]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[9]_inst/T}]
set_false_path -from [get_ports {io_ext1[9]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[9]_inst/T}]
set_false_path -to [get_ports {io_ext1[10]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[10]_inst/T}]
set_false_path -from [get_ports {io_ext1[10]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[10]_inst/T}]
set_false_path -to [get_ports {io_ext1[11]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[11]_inst/T}]
set_false_path -from [get_ports {io_ext1[11]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[11]_inst/T}]
set_false_path -to [get_ports {io_ext1[12]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[12]_inst/T}]
set_false_path -from [get_ports {io_ext1[12]}] -through [get_pins {iCoaxlinkCore/iExtIOBusMux/EXTIO_bus_IOBUF[12]_inst/T}]

################################################################################
# CDC Inter-Clock Constraints
################################################################################
# -- Video Backend constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iVideo/FB_INST/axi_read_sts_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iVideo/FB_INST/axi_read_sts_clk250_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iVideo/FB_INST/axi_write_sts_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iVideo/FB_INST/axi_write_sts_clk250_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iVideo/fb_MemDWLevel_d1_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iVideo/Framestore_MemDWLevel_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iVideo/STM_PROC_INST/iStmParser/s2_hdr_img_SourceTag_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iVideo/VideoEventSignaling_reg[ImgSourceTag][*]/D}] 8.0

# -- Trigger interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTrigger/ul_trig_rising_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iMemento/genEventUnit[*].Argument1_d1_reg[*][*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/ToggleTrigMessInit_reg[0][0]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iTrigger/PreviousTriggerMessageType_reg/D}] 8.0

# -- Timestamp Interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTimestamp/Inst_TimeStamp/bl.DSP48E_2/DSP_OUTPUT_INST/CLK}] -to [get_pins -hierarchical -filter {NAME =~ */iVideo/Timstamp_aclk_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTimestamp/toggle_clk125_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iTimestamp/toggle_user_clk_s_reg[2]/D}] 8.0

# -- Fan Control Interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iFanSpeedCtrl/FanPulseCounter_l_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iFanSpeedCtrl/FanSpeedMeasured_i_reg[*]/D}] 8.000

# -- I2C Interface constraints ----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iRegInterface/I2cCfgCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Chip_Add_Reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iRegInterface/I2cCfgCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Data_To_Write_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iRegInterface/I2cCfgCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/I2C_RdNotWr_reg/D*}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iRegInterface/I2cCfgCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Sub_Add_Reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/I2cQsfpCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Chip_Add_Reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/I2cQsfpCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Data_To_Write_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/I2cQsfpCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/I2C_RdNotWr_reg/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/I2cQsfpCtrlReg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Sub_Add_Reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Instr_Failed_Flg_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iRegInterface/reg_rd_data_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Instr_Finished_Flg_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iRegInterface/reg_rd_data_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iI2cCfgCtrl/iI2C_CFG/Received_Data_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iRegInterface/reg_rd_data_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Instr_Failed_Flg_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/reg_rd_data_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Instr_Finished_Flg_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/reg_rd_data_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iQsfp_ctrl/iI2C_ISSP_PSOC/Received_Data_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iTargetInterface/reg_rd_data_reg[*]/D}] 8.0

# -- CoaxPress Event Interface constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */evt_tag_ack_l0_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */evt_tag_ack_l1_reg[*][*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */evt_ack_tog_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */evt_ack_sr_333MHz_reg[*][*]/D}] 8.0

# -- CoaxPress internal core constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_ce_t_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_ce_s_reg[2]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_INST/tport_ul_data_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_data_s_1_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_INST/tport_ul_k_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/ul_k_s_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_INST/rx_trig_2_0_delay_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iEventSignaling/EventStatus_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_INST/rx_trig_2_0_linktriggern_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iEventSignaling/EventStatus_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_ce_reg/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_presc_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/CSR_INST/regs_up_stream_mode_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/tx_sr_reg[*]/R}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/CSR_INST/regs_tportcsr_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_presc_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/CSR_INST/regs_tportcsr_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].TPORT_UPLINK_INST/UPLINK_TX_INST/ui_ce_reg/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/HEARTBEAT_REC_INST/hbt_timestamp_reg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iHbtFifo/write_reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/HEARTBEAT_REC_INST/hbt_host_id_reg_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iHbtFifo/hbt_metadata_reg_reg[*]/D}] 8.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iCxp/STM_READER_INST/stat_err_sts_tag_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */gMementoChannel[*].stat_war_sts_tag_l_reg[*][*]/D}] 8.0

# -- CXP LINK ERROR COUNTER constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */gXgmiiLock[*].cxph_tport_dl_lock_333Mhz_dly_reg[*][*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncLock_s_reg[*]/D}] 6.0
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_ERR_CNT_INST/ResetEncCnt_t_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_ERR_CNT_INST/ResetEncCnt_s_reg[2]/D}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncErrCnt_s_reg[*]/D}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ */iCxp/MULTILINK_GEN[*].LINK_ERR_CNT_INST/EncErrDspOVF_s_reg[*]/D}]

# -- CoaxPress to Fiber Converter constraints -----------------------------
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_ce_t_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_ce_sr_reg[*]/D}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/UPLINK_RX_INST/out_data_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_data_sr_reg[*][*]/D}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/UPLINK_RX_INST/out_charisk_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_data_sr_reg[*][*]/D}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_serr_sr_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UL_LLOCK_TIMEOUT/done_reg/D}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_serr_sr_reg[*]/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UL_LLOCK_TIMEOUT/timeout_reg_reg[*]/R}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/UPLINK_RX_INST/out_serr_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/UPLINK_TPORT_GEN[*].UPLINK_TPORT_INST/ul_serr_sr_reg[*]/D}] 6.0
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/speed_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */iXgmiiToCxp/XTC_UPLINK_LOW_INST/xgmii_txd_reg[*]/D}] 6.0