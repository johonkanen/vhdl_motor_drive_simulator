library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;
    use work.system_hardware_pkg.all;

entity system_control is
    port (
        system_clocks           : in system_clocks_record;
        system_control_FPGA_in  : in system_control_FPGA_input_record;
        system_control_FPGA_out : out system_control_FPGA_output_record
    );
end entity;

architecture rtl of system_control is

    signal system_hardware_FPGA_out : system_hardware_FPGA_output_record;
    signal system_hardware_data_in  : system_hardware_data_input_record;
    signal system_hardware_data_out : system_hardware_data_output_record;

begin

    system_control_FPGA_out <= (
                               system_hardware_FPGA_out => system_hardware_FPGA_out);

    u_system_hardware : system_hardware
    port map( system_clocks        ,
    	  system_control_FPGA_in.system_hardware_FPGA_in  ,
    	  system_hardware_FPGA_out ,
    	  system_hardware_data_in  ,
    	  system_hardware_data_out);

------------------------------------------------------------------------
end rtl;
