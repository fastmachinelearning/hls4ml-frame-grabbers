source 03_scripts/create_vivado_project.tcl
set_property -name {xsim.simulate.runtime} -value {1000us} -objects [get_filesets sim_1]
launch_simulation

synth_design -directive Default
write_checkpoint -force ./07_vivado_project/synth_step
opt_design -directive Explore 
write_checkpoint -force ./07_vivado_project/opt_step
place_design -directive EarlyBlockPlacement
write_checkpoint -force ./07_vivado_project/place_step

set NLOOPS 5
for {set i 0} {$i < $NLOOPS} {incr i} {
    phys_opt_design -directive AggressiveExplore 
    write_checkpoint -force ./07_vivado_project/phys_opt_step
    phys_opt_design -directive AggressiveFanoutOpt
    write_checkpoint -force ./07_vivado_project/phys_opt_step
    phys_opt_design -directive AggressiveExplore 
    write_checkpoint -force ./07_vivado_project/phys_opt_step
    phys_opt_design -directive AlternateReplication
    write_checkpoint -force ./07_vivado_project/phys_opt_step
}
write_checkpoint -force ./07_vivado_project/phys_opt_step
route_design -directive Explore
write_checkpoint -force ./07_vivado_project/route_step
phys_opt_design -directive AggressiveExplore 
write_checkpoint -force ./07_vivado_project/post_route_phys_opt_step

report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_1 -file ./07_vivado_project/post_route_phys_opt_timing_summary.rpt
report_utilization -file ./07_vivado_project/post_route_util.rpt


source ./03_scripts/customlogic_functions.tcl
customlogic_bitgen