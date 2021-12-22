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
        button_1        : in std_logic  ;
        button_2        : in std_logic  ;
        led             : out std_logic ;
        led1            : out std_logic ;
        led2            : out std_logic ;
        led3            : out std_logic ;
        uart_rx         : in std_logic  ;
        main_pll_LOCKED : in std_logic  ;
        uart_tx         : out std_logic
    );
end entity top;


architecture rtl of top is

------------------------------------------------------------------------
    signal fast_limit   : natural range 0 to 2**16-1 := init_counter.fast_limit;
    signal led_blinker  : counter                    := init_counter;
    signal led_blinker1 : counter                    := init_counter;
    signal led_blinker2 : counter                    := init_counter;
    signal led_blinker3 : counter                    := init_counter;

------------------------------------------------------------------------
    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal counter_for_100khz : natural range 0 to 2**16-1 := 6e3;
    signal sincos_angle : unsigned(15 downto 0) := (others => '0');

------------------------------------------------------------------------
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;
    signal sincos2 : sincos_record := init_sincos;

------------------------------------------------------------------------
    signal w_multiplier : multiplier_record := init_multiplier;
    signal test_lcr     : test_lcr_record := init_test_lcr;

    signal u_in         : int18 := 5e3;
    signal u_in_counter : natural range 0 to 2**14-1 := 15e3;
------------------------------------------------------------------------
------------------------------------------------------------------------
begin

    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    test_efinix : process(clk_120Mhz)

    begin
        if rising_edge(clk_120Mhz) then
            -- object creation -- 
            create_counter(led_blinker , led , fast_limit);
            create_counter(led_blinker1, led1);
            create_counter(led_blinker2, led2);
            create_counter(led_blinker3, led3, led_blinker3.fast_limit);

            init_uart(uart_data_in);

            create_multiplier(sincos_multiplier);
            create_multiplier(w_multiplier);

            create_sincos(sincos_multiplier, sincos)  ;
            create_sincos(sincos_multiplier, sincos2) ;

            create_test_lcr_filter(w_multiplier, test_lcr, u_in);
            ----------------------

            ----------------------
            if button_is_pressed(button_2) then
                led_blinker2.fast_limit <= 38e3;
            end if;

            ----------------------
            -- test reusing 
            if sincos_is_ready(sincos) then
                request_sincos(sincos2, sincos_angle);
            end if;
            ----------------------


            -- knight rider 
            if button_is_pressed(button_1) then
                if get_cosine(sincos) > 0 then
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

            --- test creation at 100kHz
            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 1200;
                
                if u_in_counter /= 0 then
                    u_in_counter <= u_in_counter - 1;
                else
                    u_in_counter <= 15e3;
                    u_in <= -u_in;
                end if;

                request_test_lcr_filter_calculation(test_lcr);
                transmit_16_bit_word_with_uart(uart_data_in, get_lcr_capacitor_voltage(test_lcr) + 32768);

                -- counter 0 - 65535, is intended to oveflow
                sincos_angle <= sincos_angle + 1;
                request_sincos(sincos, sincos_angle);
            end if;

        end if; --rising_edge
    end process test_efinix;	

------------------------------------------------------------------------
------------------------------------------------------------------------
    uart_clocks <= (clock => clk_120Mhz);

    uart_FPGA_in <= (uart_transreceiver_FPGA_in=>(uart_rx_FPGA_in=>(uart_rx => (uart_rx))));

    u_uart : uart
    port map( uart_clocks,
    	  uart_FPGA_in,
    	  uart_FPGA_out,
    	  uart_data_in,
    	  uart_data_out);

------------------------------------------------------------------------
end rtl;
