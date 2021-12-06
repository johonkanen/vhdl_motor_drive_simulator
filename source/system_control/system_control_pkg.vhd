library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_hardware_pkg.all;

package system_control_pkg is
    
    type system_control_FPGA_input_record is record
        system_hardware_FPGA_in  : system_hardware_FPGA_input_record;
    end record;
    
    type system_control_FPGA_output_record is record
        system_hardware_FPGA_out : system_hardware_FPGA_output_record;
    end record;
    
    type system_control_FPGA_inout_record is record
        system_hardware_FPGA_inout : system_hardware_FPGA_inout_record;
    end record;
    
    type system_control_data_input_record is record
        system_hardware_data_in  : system_hardware_data_input_record;
    end record;
    
    type system_control_data_output_record is record
        system_hardware_data_out : system_hardware_data_output_record;
    end record;
    
    component system_control is
        port (
            system_clocks           : in system_clocks_record;
            system_control_FPGA_in  : in system_control_FPGA_input_record;
            system_control_FPGA_out : out system_control_FPGA_output_record
        );
    end component system_control;
    
    -- signal system_control_clocks   : system_control_clock_record;
    -- signal system_control_FPGA_in  : system_control_FPGA_input_record;
    -- signal system_control_FPGA_out : system_control_FPGA_output_record;
    
    -- u_system_control : system_control
    -- port map( system_control_clocks ,
    -- 	  system_control_FPGA_in       ,
    --	  system_control_FPGA_out);

end package system_control_pkg;
