#-------------------------------------------------------------------------------
#-- NOTE: THIS FILE SHALL NOT BE MODIFIED.
#-------------------------------------------------------------------------------


################################################################################
# Pinout and Related I/O Constraints
################################################################################
set_property PACKAGE_PIN AC22 [get_ports perst_n]
set_property IOSTANDARD LVCMOS33 [get_ports perst_n]
set_property PACKAGE_PIN AA17 [get_ports wake_n]
set_property IOSTANDARD LVCMOS33 [get_ports wake_n]

set_property LOC GTHE3_COMMON_X0Y1 [get_cells -hierarchical -filter {NAME =~ */refclk_ibuf}]
set_property PACKAGE_PIN P6 [get_ports pcie_clk_p]

# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# UltraScale GT Transceiver User Guide (UG) for more information.

# PCIe Lanes
set_property LOC GTHE3_CHANNEL_X0Y0 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y1 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y2 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y3 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y4 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y5 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y6 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y7 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST}]

set_property LOC PCIE_3_1_X0Y0 [get_cells -hierarchical -filter {NAME =~ */pcie/inst/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst}]

###############################################################################
# Timing Constraints
###############################################################################
create_clock -period 10.000 -name sys_clk [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/ODIV2}]
create_clock -period 10.000 -name sys_clk_gt [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/O}]
create_generated_clock -name sys_clk_bufg -source [get_pins -hierarchical -filter {NAME =~ */refclk_ibuf/ODIV2}] -divide_by 1 [get_pins -hierarchical -filter {NAME =~ */pcie/inst/bufg_gt_sysclk/O}]

# TXOUTCLKSEL switches during reset. Set the tool to analyze timing with TXOUTCLKSEL set to 'b101.
set_case_analysis 1 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[2]}]
set_case_analysis 0 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[1]}]
set_case_analysis 1 [get_nets -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/PHY_TXOUTCLKSEL[0]}]

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
create_generated_clock -name extio_clk -source [get_pins -hierarchical "bufg_gt_userclk/O"] -edges {1 5 11} [get_ports io_ext1[1]]


#------------------------------------------------------------------------------
# CDC Registers
#------------------------------------------------------------------------------
# This path is crossing clock domains between pipe_clk and sys_clk
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/prst_n_r_reg[7]/C}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_prst_n/sync_vec[0].sync_cell_i/sync_reg[0]/D}]
# These paths are crossing clock domains between sys_clk and user_clk
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/idle_reg/C}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/pcie3_uscale_top_inst/init_ctrl_inst/reg_phy_rdy_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_phystatus/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_rxresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_ultrascale_0_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_ultrascale_0_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXUSRCLK2}] -to [get_pins -hierarchical -filter {NAME =~ */pcie/inst/gt_top_i/phy_rst_i/sync_txresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]

#------------------------------------------------------------------------------
# Asynchronous Pins
#------------------------------------------------------------------------------
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

###############################################################################
# End
###############################################################################
