-- library ieee;
--     use ieee.std_logic_1164.all;
--     use ieee.numeric_std.all;
--
-- library work;
--     use work.system_clocks_pkg.all;
--     use work.motor_control_hardware_pkg.all;
--
-- entity motor_control_hardware is
--     port (
--         system_clocks                   : in system_clocks_record;
--         motor_control_hardware_FPGA_in  : in motor_control_hardware_FPGA_input_record;
--         motor_control_hardware_FPGA_out : out motor_control_hardware_FPGA_output_record;
--         motor_control_hardware_data_in  : in motor_control_hardware_data_input_record;
--         motor_control_hardware_data_out : out motor_control_hardware_data_output_record
--     );
-- end entity;

architecture simulated of motor_control_hardware is

    signal motor_control_data_processing_FPGA_in  : motor_control_data_processing_FPGA_input_record;
    signal motor_control_data_processing_FPGA_out : motor_control_data_processing_FPGA_output_record;
    signal motor_control_data_processing_data_in  : motor_control_data_processing_data_input_record;
    signal motor_control_data_processing_data_out : motor_control_data_processing_data_output_record;
    

begin
    motor_control_hardware_FPGA_out <= (motor_control_data_processing_FPGA_out => motor_control_data_processing_FPGA_out);

    u_motor_control_data_processing : motor_control_data_processing
    port map( system_clocks ,
    	  motor_control_hardware_FPGA_in.motor_control_data_processing_FPGA_in       ,
    	  motor_control_data_processing_FPGA_out      ,
    	  motor_control_data_processing_data_in       ,
    	  motor_control_data_processing_data_out);

end simulated;
