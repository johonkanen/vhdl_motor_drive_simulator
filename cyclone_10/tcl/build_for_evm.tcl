package require ::quartus::project
package require ::quartus::flow
package require cmdline

variable cyclone_10_tcl_dir [ file dirname [ file normalize [ info script ] ] ]

set project_root $cyclone_10_tcl_dir/../../
set source_folder $project_root/source
set fpga_device 10CL025YU256I7G
set output_dir ./output

set need_to_close_project 0

# Check that the right project is open
if {[project_exists motor_control]} \
{
    project_open -revision top motor_control
} \
else \
{
    project_new -revision top motor_control
}
set need_to_close_project 1
#
# read sources
source $project_root/get_vhdl_sources.tcl

set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/evm_clocks/main_clocks.qip 

foreach x [get_vhdl_sources ../] \
{ \
    if {[lsearch -glob $x *math_library*] == 0} \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x -library math_library
    } \
    elseif {[lsearch -glob $x *dynamic_simulation_library*] == 0} \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x -library math_library
    } \
    elseif {[lsearch -glob $x *cl10_hw_library*] == 0} \
    {
        set_global_assignment -name VHDL_FILE $source_folder/$x -library cl10_hw_library
    }\
    else \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x \
    } 
}

source $project_root/cyclone_10/tcl/evaluation_kit_pin_map.tcl
source $cyclone_10_tcl_dir/make_assignments.tcl
source $cyclone_10_tcl_dir/set_io_locations.tcl 
    export_assignments 

set_global_assignment -name SDC_FILE $cyclone_10_tcl_dir/ac_inout_constraints_evm.sdc

execute_flow -compile 
