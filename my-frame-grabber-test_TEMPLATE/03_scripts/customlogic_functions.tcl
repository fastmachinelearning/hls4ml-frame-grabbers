# --------------------------------------------------------------------------------
# -- CustomLogic - CustomLogic Functions
# --------------------------------------------------------------------------------
# -- Procedures : customlogic_help
# --              customlogic_bitgen
# --              customlogic_prog_fpga
# --        File: customlogic_functions.tcl
# --        Date: 2018-11-15
# --         Rev: 0.1
# --      Author: PP
# --------------------------------------------------------------------------------
# -- 0.1, 2018-11-15, PP, Initial release
# --------------------------------------------------------------------------------

proc customlogic_help {} {
	puts {
CustomLogic Functions
-------------------------------------------------------------------------
Syntax: 
	customlogic_help
    customlogic_bitgen
	customlogic_prog_fpga

Usage: 
    Name        					Description
    ---------------------------------------------------------------------
	customlogic_help				The present help.
	customlogic_bitgen			    Generate .bit file.
    customlogic_prog_fpga			Program FPGA via JTAG (volatile).
									This function requires a Xilinx JTAG
									programmer.
-------------------------------------------------------------------------}
}

proc customlogic_bitgen {} {
	puts  " "
	puts  "EURESYS_INFO: Starting bitstream generation..."

	# Get Project & Release Paths
	set currentProject [get_projects]
	set currentProjectPath [get_property DIRECTORY [get_projects $currentProject]]
	set currentSettingsPath "$currentProjectPath/../02_coaxlink/settings"
	set currentReleasePath "$currentProjectPath/../06_release"
	cd $currentReleasePath

  ### ONLY FOR PROJECT MODE ###
	# # Check Open Run
	# set checkOpenRun_a [current_design -quiet]
	# set checkOpenRun_b [current_run -implementation ]
	# if {[regexp $checkOpenRun_b $checkOpenRun_a]} { 
	# 	puts  "EURESYS_INFO: Implementation \"$checkOpenRun_a\" already open."
	# } else {
	# 	# open_run [current_run -implementation]
	# 	open_run impl_1
  #   puts "Opened impl_1"    
	# }


	# Get UserID and PlatformID
	set fileCustomLogicSettings [open "$currentSettingsPath/CustomLogic.set" r]
	set dataCustomLogicSettings [read $fileCustomLogicSettings]
	close $fileCustomLogicSettings
	foreach {text value} $dataCustomLogicSettings {
		if [regexp {Platform:} $text] {
			set platformID $value
		}
		if [regexp {Firmware:} $text] {
			set userID $value
		}
	}

	# Generate Bitstream
	set_property BITSTREAM.CONFIG.USERID 32'h$userID [current_design]
    set_property BITSTREAM.CONFIG.USR_ACCESS $userID [current_design]
	set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
	write_bitstream -force $platformID.bit
	write_debug_probes -quiet -force $platformID
	
	puts  " "
	puts  "EURESYS_INFO: Bitstream generation completed."
	puts  " "
}

proc customlogic_prog_fpga {} {
	puts  " "
	puts  "EURESYS_INFO: Starting FPGA programming..."
	
	# Get Project & Release Paths
	set currentProject [get_projects]
	set currentProjectPath [get_property DIRECTORY [get_projects $currentProject]]
	set currentSettingsPath "$currentProjectPath/../02_coaxlink/settings"
	set currentReleasePath "$currentProjectPath/../06_release"
	cd $currentReleasePath
	
	# Get PlatformID
	set fileCustomLogicSettings [open "$currentSettingsPath/CustomLogic.set" r]
	set dataCustomLogicSettings [read $fileCustomLogicSettings]
	close $fileCustomLogicSettings
	foreach {text value} $dataCustomLogicSettings {
		if [regexp {Platform:} $text] {
			set platformID $value
		}
	}
	
	# Set File names
	set probeFile $platformID.ltx
	set programFile $platformID.bit
	
    # Get current part
    set devicePart [get_parts -of_objects [get_projects]]

	# Connect to JTAG programmer
	open_hw
	connect_hw_server
	open_hw_target
	current_hw_device [lindex [get_hw_devices $devicePart] 0]

	# Set files to be uploaded
	set_property PROBES.FILE $probeFile [lindex [get_hw_devices $devicePart] 0]
	set_property PROGRAM.FILE $programFile [lindex [get_hw_devices $devicePart] 0]

	# Program FPGA
	program_hw_devices [lindex [get_hw_devices $devicePart] 0]

	# Disconnect JTAG programmer
	close_hw_target
	disconnect_hw_server
	close_hw

	puts  " "
	puts  "EURESYS_INFO: FPGA programming completed."
	puts  " "
}

customlogic_help
