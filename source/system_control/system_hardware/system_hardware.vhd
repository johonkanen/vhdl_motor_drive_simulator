library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_hardware_pkg.all;
    use work.uart_pkg.all;
    use work.motor_control_hardware_pkg.all;


entity system_hardware is
    port (
        system_clocks            : in system_clocks_record;
        system_hardware_FPGA_in  : in system_hardware_FPGA_input_record;
        system_hardware_FPGA_out : out system_hardware_FPGA_output_record;
        system_hardware_data_in  : in system_hardware_data_input_record;
        system_hardware_data_out : out system_hardware_data_output_record
    );
end entity;

architecture rtl of system_hardware is

    alias main_clock is system_clocks.main_clock;

    signal uart_clocks   : uart_clock_group       ;
    signal uart_FPGA_out : uart_FPGA_output_group ;
    signal uart_data_in  : uart_data_input_group  ;
    signal uart_data_out : uart_data_output_group ;

    signal motor_control_hardware_FPGA_in  : motor_control_hardware_FPGA_input_record;
    signal motor_control_hardware_FPGA_out : motor_control_hardware_FPGA_output_record;
    signal motor_control_hardware_data_in  : motor_control_hardware_data_input_record;
    signal motor_control_hardware_data_out : motor_control_hardware_data_output_record;

begin

------------------------------------------------------------------------
    system_hardware_FPGA_out <= (
                                    uart_FPGA_out => uart_FPGA_out);

    system_hardware_data_out <= (
                                    uart_data_out => uart_data_out,
                                    motor_control_hardware_data_out => motor_control_hardware_data_out);

------------------------------------------------------------------------
    uart_clocks  <= (clock => main_clock);
    uart_data_in <= system_hardware_data_in.uart_data_in;

    u_uart : uart
    port map( uart_clocks ,
    	  system_hardware_FPGA_in.uart_FPGA_in    ,
    	  uart_FPGA_out   ,
    	  uart_data_in    ,
    	  uart_data_out);

------------------------------------------------------------------------
    u_motor_control_hardware : motor_control_hardware
    port map( system_clocks ,
    	  motor_control_hardware_FPGA_in       ,
    	  motor_control_hardware_FPGA_out      ,
    	  motor_control_hardware_data_in       ,
    	  motor_control_hardware_data_out);
------------------------------------------------------------------------
end rtl;
