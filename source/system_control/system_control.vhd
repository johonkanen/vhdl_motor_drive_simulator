library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;
    use work.system_hardware_pkg.all;
    use work.uart_pkg.all;

entity system_control is
    port (
        system_clocks           : in system_clocks_record;
        system_control_FPGA_in  : in system_control_FPGA_input_record;
        system_control_FPGA_out : out system_control_FPGA_output_record
    );
end entity;

architecture rtl of system_control is

    alias main_clock  is system_clocks.main_clock;

    signal system_hardware_FPGA_out : system_hardware_FPGA_output_record;
    signal system_hardware_data_in  : system_hardware_data_input_record;
    signal system_hardware_data_out : system_hardware_data_output_record;

    alias uart_data_in is system_hardware_data_in.uart_data_in;
    alias uart_data_out is system_hardware_data_out.uart_data_out;

    constant counter_value_for_100khz : natural := 1199;
    signal counter_for_100khz : natural range 0 to 2047 := 1199;
    signal uart_data_counter : natural range 0 to 2**16-1 := 0;

    signal uart_data_input : natural range 0 to 2**16-1 := 65535;

begin

------------------------------------------------------------------------
    system_control_FPGA_out <= (
                               system_hardware_FPGA_out => system_hardware_FPGA_out);
------------------------------------------------------------------------
    main : process(main_clock)
    begin
        if rising_edge(main_clock) then
            init_uart(uart_data_in);

            receive_data_from_uart(uart_data_out, uart_data_input);

            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                if uart_data_counter < uart_data_input then
                    uart_data_counter <= uart_data_counter + 1;
                else
                    uart_data_counter <= 0;
                end if;
                counter_for_100khz <= counter_value_for_100khz;
                transmit_16_bit_word_with_uart(uart_data_in , system_hardware_data_out.motor_control_hardware_data_out.d_current);
            end if;

        end if; --rising_edge
    end process main;	

------------------------------------------------------------------------
    u_system_hardware : system_hardware
    port map( system_clocks        ,
    	  system_control_FPGA_in.system_hardware_FPGA_in  ,
    	  system_hardware_FPGA_out ,
    	  system_hardware_data_in  ,
    	  system_hardware_data_out);

------------------------------------------------------------------------
end rtl;
