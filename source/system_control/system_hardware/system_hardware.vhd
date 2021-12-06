library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_hardware_pkg.all;
    use work.uart_pkg.all;


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

    signal uart_clocks   : uart_clock_group       ;
    signal uart_FPGA_in  : uart_FPGA_input_group  ;
    signal uart_FPGA_out : uart_FPGA_output_group ;
    signal uart_data_in  : uart_data_input_group  ;
    signal uart_data_out : uart_data_output_group ;

begin

    system_hardware_FPGA_out <= (uart_FPGA_out =>uart_FPGA_out);

------------------------------------------------------------------------
    uart_clocks <= (clock => '1');
    u_uart : uart
    port map( uart_clocks ,
    	  uart_FPGA_in    ,
    	  uart_FPGA_out   ,
    	  uart_data_in    ,
    	  uart_data_out);

end rtl;
