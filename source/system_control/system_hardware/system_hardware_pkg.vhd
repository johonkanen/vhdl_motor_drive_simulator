library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.motor_control_hardware_pkg.all;
    use work.uart_pkg.all;

package system_hardware_pkg is

    
    type system_hardware_FPGA_input_record is record
        -- motor_control_hardware_FPGA_in  : motor_control_hardware_FPGA_input_record;
        uart_FPGA_in  : uart_FPGA_input_group  ;
    end record;
    
    type system_hardware_FPGA_output_record is record
        -- motor_control_hardware_FPGA_out : motor_control_hardware_FPGA_output_record;
        uart_FPGA_out : uart_FPGA_output_group ;
    end record;
    
    type system_hardware_data_input_record is record
        motor_control_hardware_data_in  : motor_control_hardware_data_input_record;
    end record;
    
    type system_hardware_data_output_record is record
        motor_control_hardware_data_out : motor_control_hardware_data_output_record;
    end record;
    
    component system_hardware is
        port (
            system_clocks            : in system_clocks_record;
            system_hardware_FPGA_in  : in system_hardware_FPGA_input_record;
            system_hardware_FPGA_out : out system_hardware_FPGA_output_record;
            system_hardware_data_in  : in system_hardware_data_input_record;
            system_hardware_data_out : out system_hardware_data_output_record
        );
    end component system_hardware;
    
    -- signal system_hardware_clocks   : system_hardware_clock_record;
    -- signal system_hardware_FPGA_in  : system_hardware_FPGA_input_record;
    -- signal system_hardware_FPGA_out : system_hardware_FPGA_output_record;
    -- signal system_hardware_data_in  : system_hardware_data_input_record;
    -- signal system_hardware_data_out : system_hardware_data_output_record;
    
    -- u_system_hardware : system_hardware
    -- port map( system_hardware_clocks ,
    -- 	  system_hardware_FPGA_in       ,
    --	  system_hardware_FPGA_out      ,
    --	  system_hardware_data_in       ,
    --	  system_hardware_data_out);

end package system_hardware_pkg;
