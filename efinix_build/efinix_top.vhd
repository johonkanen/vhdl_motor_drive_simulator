library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;

entity top is
    port (
        clk_120Mhz : in std_logic  ;
        led        : out std_logic ;
        uart_rx    : in std_logic  ;
        uart_tx    : out std_logic
    );
end entity top;


architecture rtl of top is

------------------------------------------------------------------------
    type counter is record
        fast_counter : natural range 0 to 2**16-1;
        slow_counter : natural range 0 to 2**16-1;
        led_state : std_logic;
    end record;

    constant init_counter : counter := (0,0, '0');

------------------------------------------------------------------------
    procedure create_counter
    (
        signal counter_object : inout counter;
        signal led_io : out std_logic
    ) is
    begin
        led_io <= counter_object.led_state;
        counter_object.fast_counter <= counter_object.fast_counter + 1;
        if counter_object.fast_counter > 10e3 then
            counter_object.fast_counter <= 0;
            counter_object.slow_counter <= counter_object.slow_counter + 1;
        end if;
        if counter_object.slow_counter = 25e2 then
            counter_object.slow_counter <= 0;
            counter_object.led_state <= not counter_object.led_state;
        end if;
        
    end create_counter;
------------------------------------------------------------------------
    signal led_blinker : counter := init_counter;

    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal counter_for_100khz : natural range 0 to 2**12-1 := 1200;
    signal counter_for_uart : natural range 0 to 2**16-1 := 0;
------------------------------------------------------------------------

begin

    uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_FPGA_in.uart_rx <= uart_rx;
    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    led_blink : process(clk_120Mhz)
        
    begin
        if rising_edge(clk_120Mhz) then
            create_counter(led_blinker, led);

            init_uart(uart_data_in);

            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 1200;
                transmit_16_bit_word_with_uart(uart_data_in, counter_for_uart);
                counter_for_uart <= counter_for_uart + 1;
            end if;
        end if; --rising_edge
    end process led_blink;	

    uart_clocks <= (clock => clk_120Mhz);

    u_uart : uart
    port map( uart_clocks,
    	  uart_FPGA_in,
    	  uart_FPGA_out,
    	  uart_data_in,
    	  uart_data_out);

end rtl;
