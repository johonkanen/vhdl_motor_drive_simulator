library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.motor_control_data_processing_pkg.all;

entity motor_control_data_processing is
    port (
        system_clocks                          : in system_clocks_record;
        motor_control_data_processing_FPGA_in  : in motor_control_data_processing_FPGA_input_record;
        motor_control_data_processing_FPGA_out : out motor_control_data_processing_FPGA_output_record;
        motor_control_data_processing_data_in  : in motor_control_data_processing_data_input_record;
        motor_control_data_processing_data_out : out motor_control_data_processing_data_output_record
    );
end entity;

architecture rtl of motor_control_data_processing is

    
begin

    motor_control_data_processing_FPGA_out <= (data => '0');

------------------------------------------------------------------------
end rtl;
