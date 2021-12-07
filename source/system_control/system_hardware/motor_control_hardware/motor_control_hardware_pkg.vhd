library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.uart_pkg.all;
    use work.motor_control_data_processing_pkg.all;

package motor_control_hardware_pkg is

    
    type motor_control_hardware_FPGA_input_record is record
        motor_control_data_processing_FPGA_in  : motor_control_data_processing_FPGA_input_record;
    end record;
    
    type motor_control_hardware_FPGA_output_record is record
        motor_control_data_processing_FPGA_out : motor_control_data_processing_FPGA_output_record;
    end record;
    
    type motor_control_hardware_FPGA_inout_record is record
        motor_control_data_processing_FPGA_inout : motor_control_data_processing_FPGA_inout_record;
    end record;
    
    type motor_control_hardware_data_input_record is record
        motor_control_data_processing_data_in  : motor_control_data_processing_data_input_record;
    end record;
    
    type motor_control_hardware_data_output_record is record
        motor_control_data_processing_data_out : motor_control_data_processing_data_output_record;
    end record;
    
    component motor_control_hardware is
        port (
            system_clocks : in system_clocks_record;
            motor_control_hardware_FPGA_in    : in motor_control_hardware_FPGA_input_record;
            motor_control_hardware_FPGA_out   : out motor_control_hardware_FPGA_output_record;
            motor_control_hardware_data_in    : in motor_control_hardware_data_input_record;
            motor_control_hardware_data_out   : out motor_control_hardware_data_output_record
        );
    end component motor_control_hardware;
    
    -- signal motor_control_hardware_clocks   : motor_control_hardware_clock_record;
    -- signal motor_control_hardware_FPGA_in  : motor_control_hardware_FPGA_input_record;
    -- signal motor_control_hardware_FPGA_out : motor_control_hardware_FPGA_output_record;
    -- signal motor_control_hardware_data_in  : motor_control_hardware_data_input_record;
    -- signal motor_control_hardware_data_out : motor_control_hardware_data_output_record;
    
    -- u_motor_control_hardware : motor_control_hardware
    -- port map( motor_control_hardware_clocks ,
    -- 	  motor_control_hardware_FPGA_in       ,
    --	  motor_control_hardware_FPGA_out      ,
    --	  motor_control_hardware_data_in       ,
    --	  motor_control_hardware_data_out);

end package motor_control_hardware_pkg;
