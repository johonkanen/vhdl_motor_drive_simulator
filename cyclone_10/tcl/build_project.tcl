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
#
source $project_root/cyclone_10/tcl/control_card_pin_map.tcl
source $project_root/get_vhdl_sources.tcl

set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/main_clocks/main_clocks.qip 

set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ethernet_clocks_generator/ethernet_clocks_generator.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ddio_in/ethddio_rx.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ddio_out/ethddio_tx.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/memory/dual_port_ethernet_ram.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/memory/transmit_ram/transmit_ram.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/memory/transmit_fifo/tx_fifo.qip


foreach x [get_vhdl_sources ../] \
{ \
    if {[lsearch -glob $x *math_library*] == 0} \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x -library math_library
    } \
    elseif {[lsearch -glob $x *dynamic_simulation_library*] == 0} \
    {
        set_global_assignment -name VHDL_FILE $source_folder/$x -library cl10_hw_library
    }\
    elseif {[lsearch -glob $x *cl10_hw_library*] == 0} \
    {
        set_global_assignment -name VHDL_FILE $source_folder/$x -library cl10_hw_library
    }\
    else \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x \
    } 
}

source $cyclone_10_tcl_dir/make_assignments.tcl
source $cyclone_10_tcl_dir/set_io_locations.tcl 
    export_assignments 

set_global_assignment -name SDC_FILE $cyclone_10_tcl_dir/ac_inout_constraints.sdc

execute_flow -compile 
