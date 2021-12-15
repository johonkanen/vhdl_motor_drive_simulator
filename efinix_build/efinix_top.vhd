library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;
    use work.test_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.sincos_pkg.all;

entity top is
    port (
        clk_120Mhz      : in std_logic  ;
        button_1        : in std_logic;
        button_2        : in std_logic;
        led             : out std_logic ;
        led1            : out std_logic ;
        led2            : out std_logic ;
        led3            : out std_logic ;
        uart_rx         : in std_logic  ;
        main_pll_LOCKED : in std_logic;
        uart_tx         : out std_logic
    );
end entity top;


architecture rtl of top is

------------------------------------------------------------------------
    signal fast_limit   : natural range 0 to 2**16-1 := init_counter.fast_limit;
    signal led_blinker  : counter                    := init_counter;
    signal led_blinker1 : counter                    := init_counter;
    signal led_blinker2 : counter                    := init_counter;
    signal led_blinker3 : counter                    := (fast_counter => init_counter.fast_counter ,
                                                         slow_counter => init_counter.slow_counter ,
                                                         led_state    => init_counter.led_state    ,
                                                         fast_limit   => init_counter.fast_limit  );

------------------------------------------------------------------------
    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal counter_for_100khz : natural range 0 to 2**16-1 := 6e3;
    signal counter_for_uart : natural range 0 to 2**16-1 := 0;

------------------------------------------------------------------------
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;

------------------------------------------------------------------------
------------------------------------------------------------------------
begin

    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    led_blink : process(clk_120Mhz)
        
    begin
        if rising_edge(clk_120Mhz) then
            init_uart(uart_data_in);

            create_counter(led_blinker , led , fast_limit); -- this blinks
            create_counter(led_blinker1, led1);             -- this does not blink, initial record value 0
            create_counter(led_blinker2, led2);             -- this works correctly, the button seems to fix it
            if button_is_pressed(button_2) then
                led_blinker2.fast_limit <= 38e3;
            end if;

            create_counter(led_blinker3, led3);             -- this blinks correctly

            create_multiplier(sincos_multiplier);     -- this is a multiplier with interface functions
            create_sincos(sincos_multiplier, sincos); -- this creates a state machine for calculating sine/cosine functions

            -- knight rider 
            if button_is_pressed(button_1) then
                if get_sine(sincos) > 0 then
                    led3 <= set_1_when_larger_than(get_sine(sincos), 13e3);
                    led2 <= set_1_when_larger_than(get_sine(sincos), 18e3);
                    led1 <= set_1_when_larger_than(get_sine(sincos), 22e3);
                    led  <= set_1_when_larger_than(get_sine(sincos), 30e3);
                else
                    led  <= set_1_when_larger_than(get_sine(sincos), 13e3);
                    led1 <= set_1_when_larger_than(get_sine(sincos), 18e3);
                    led2 <= set_1_when_larger_than(get_sine(sincos), 22e3);
                    led3 <= set_1_when_larger_than(get_sine(sincos), 30e3);
                end if;
            end if;

            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 5000;
                transmit_16_bit_word_with_uart(uart_data_in, get_cosine(sincos));
                request_sincos(sincos, counter_for_uart);
                counter_for_uart <= counter_for_uart + 1;
            end if;

        end if; --rising_edge
    end process led_blink;	

    uart_clocks <= (clock => clk_120Mhz);

    uart_FPGA_in <= (uart_transreceiver_FPGA_in=>(uart_rx_FPGA_in=>(uart_rx => (uart_rx))));

    u_uart : uart
    port map( uart_clocks,
    	  uart_FPGA_in,
    	  uart_FPGA_out,
    	  uart_data_in,
    	  uart_data_out);

end rtl;
