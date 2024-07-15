# --------------------------------------------------------------------------------
# -- CustomLogic - Create Vivado Project
# --------------------------------------------------------------------------------
# --  Procedures: customlogicCreateProject
# --        File: create_vivado_project.tcl
# --------------------------------------------------------------------------------
# -- 0.1, 2018-10-19, PP, Initial release
# -- 0.2, 2019-10-29, PP, Added Vivado version check
# --                      Added automatic IP upgrade
# -- 0.3, 2021-06-18, PP, Updated list of files
# -- 0.4, 2023-02-20, PP, Updated to support Vitis 2022.2
# --------------------------------------------------------------------------------

proc customlogicCreateProject {} {
	puts  " "
	puts  "EURESYS_INFO: Creating the CustomLogic Vivado project..."
	
	# Check Vivado version
	set sup_viv_version 2022.2
	set cur_viv_version [version -short]
	puts "EURESYS_INFO: Current Vivado version: $cur_viv_version"
	if {[expr $cur_viv_version == $sup_viv_version]} {
		puts "EURESYS_INFO: CustomLogic is fully supported by the current Vivado version."
	} else {
		if {[expr $cur_viv_version > $sup_viv_version]} {
			puts "EURESYS_WARNING: The current Vivado version is newer than $sup_viv_version. CustomLogic may not be fully supported in this version."
		}
		if {[expr $cur_viv_version < $sup_viv_version]} {
			puts "EURESYS_ERROR: The current Vivado version is older than $sup_viv_version."
			puts "EURESYS_ERROR: Creating the CustomLogic Vivado project... aborted!"
			return
		}
	}

	# Set the reference directory for source file relative paths
	set script_dir [file dirname [file normalize [info script]]]
	set customlogic_dir [file normalize $script_dir/..]
	
	# Set Project name
	set project_name CustomLogic

	# Create project
	create_project $project_name $customlogic_dir/07_vivado_project -part xcku035-fbva676-2-e

	# Deactivate automatic order
	set_property source_mgmt_mode DisplayOnly [current_project]

	# Activate XPM_LIBRARIES
	set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]

	# Create 'sources_1' fileset (if not found)
	if {[string equal [get_filesets -quiet sources_1] ""]} {
		create_fileset -srcset sources_1
	}

	# Set 'sources_1' fileset object
	set obj [get_filesets sources_1]
	set files [list \
		"[file normalize "$customlogic_dir/02_coaxlink/hdl_enc/CustomLogicPkt.vp"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/hdl_enc/CustomLogicPkt.vhdp"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/hdl_enc/CustomLogicTopPkt.vhdp"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/dcp/CoaxlinkDcp.dcp"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_dwidth_clk_converter_S128_M512.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_dwidth_clk_converter_S256_M512.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_dwidth_clk_converter_S128_M512_wr.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_dwidth_clk_converter_S256_M512_rd.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_interconnect_3xS512_M512.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axi_lite_clock_converter.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/axis_data_fifo_256b.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/clk_wiz_cxp12.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/CounterDsp.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/EventSignalingBram.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/EventSignalingFifo_ku.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/evt_CDC_fifo.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/ExtIOConfigBram.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/fifo_memento.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/FrameSizeDwDsp.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/gth_cxp_low_cxp12.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/LUT12x8.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/mem_if.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/MultiplierDsp.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/PEGBram.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/PEGFifo_ku.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/PIXO_FIFO_259x1024.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/PoCXP_uBlaze.elf"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/PoCXP_uBlaze.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/reg2mem_rddwc.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/reg2mem_rdfifo.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/reg2mem_wrdwc.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/reg2mem_wrfifo.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/sin_fifo_134bx4k.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/sout_fifo_wr256_rd256.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/TimingMachineProg_BRAM_72x512.xcix"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/ips/WrAxiAddrFifo.xcix"]"\
		"[file normalize "$customlogic_dir/04_ref_design/mem_traffic_gen.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/control_registers.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/myproject_axi_wrp.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/CustomLogic.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/signal_inference.v"]"\
		"[file normalize "$customlogic_dir/04_ref_design/lut_bram_8x256.xcix"]"\
	]

  # Add model HDL files
  add_files -norecurse [glob 05_model_design_hls/myproject_axi/KCU035/syn/vhdl/*.vhd] -fileset sources_1

	add_files -norecurse -fileset $obj $files

	# Set 'sources_1' fileset properties
	set obj [get_filesets sources_1]
	set_property "top" "CustomLogicTop" $obj

	# Create 'constrs_1' fileset (if not found)
	if {[string equal [get_filesets -quiet constrs_1] ""]} {
		create_fileset -constrset constrs_1
	}

	# Set 'constrs_1' fileset object
	set obj [get_filesets constrs_1]
	set files [list \
		"[file normalize "$customlogic_dir/02_coaxlink/constr/CxlCxp12_loc_common.xdc"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/constr/CxlCxp12_xil_x8_gen3.xdc"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/constr/CxlCxp12_timing_common.xdc"]"\
		"[file normalize "$customlogic_dir/02_coaxlink/constr/Bitstream_settings.xdc"]"\
		"[file normalize "$customlogic_dir/04_ref_design/CustomLogic.xdc"]"\
	]
	add_files -norecurse -fileset $obj $files

	# Set 'constrs_1' fileset properties
	set obj [get_filesets constrs_1]
	set_property "target_constrs_file" "[file normalize "$customlogic_dir/04_ref_design/CustomLogic.xdc"]" $obj
	
	# Upgrade IPs (if needed)
	upgrade_ip [get_ips]
	
	# Generate IPs
	foreach IpName [get_ips] {
		generate_target all [get_files "$IpName.xci"]
	}

	# Associate ELF file
	set_property SCOPED_TO_REF PoCXP_uBlaze [get_files -all -of_objects [get_fileset sources_1] {PoCXP_uBlaze.elf}]
	set_property SCOPED_TO_CELLS { inst/microblaze_I } [get_files -all -of_objects [get_fileset sources_1] {PoCXP_uBlaze.elf}]

	# Set Implementation strategy
	set_property strategy Performance_ExploreWithRemap [get_runs impl_1]
	
	# Create 'sim_1' fileset (if not found)
	if {[string equal [get_filesets -quiet sim_1] ""]} {
		create_fileset -constrset sim_1
	}
	
	# Set 'sim_1' fileset object
	set obj [get_filesets sim_1]
	set files [list \
		"[file normalize "$customlogic_dir/04_ref_design/sim/Simulation_FileIO_pkg.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/sim/CustomLogicSimPkt.vhdp"]"\
		"[file normalize "$customlogic_dir/04_ref_design/sim/onboardmem.xcix"]"\
		"[file normalize "$customlogic_dir/04_ref_design/sim/SimulationCtrl_tb.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/sim/tb_top.vhd"]"\
		"[file normalize "$customlogic_dir/04_ref_design/sim/tb_top_behav.wcfg"]"\
	]
	add_files -norecurse -fileset $obj $files
	
	# Set 'sim_1' fileset properties
	set obj [get_filesets sim_1]
	set_property "top" "tb_top" $obj
	set_property RUNTIME 100us $obj
	set ipList [get_ips]
	foreach file $ipList {
		set_property used_in_simulation false [get_files $file.xci]
	}
	set_property used_in_simulation false [get_files "$customlogic_dir/02_coaxlink/hdl_enc/CustomLogicPkt.vp"]
	set_property used_in_simulation false [get_files "$customlogic_dir/02_coaxlink/hdl_enc/CustomLogicPkt.vhdp"]
	set_property used_in_synthesis false [get_files "$customlogic_dir/04_ref_design/sim/onboardmem/onboardmem.xci"]
	set_property used_in_implementation false [get_files "$customlogic_dir/04_ref_design/sim/onboardmem/onboardmem.xci"]
	set_property used_in_simulation true [get_files "$customlogic_dir/04_ref_design/sim/onboardmem/onboardmem.xci"]
	set_property used_in_simulation true [get_files "$customlogic_dir/04_ref_design/lut_bram_8x256/lut_bram_8x256.xci"]
	
	puts  "EURESYS_INFO: Creating the CustomLogic Vivado project... done"
}

customlogicCreateProject