library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;

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
    type counter is record
        fast_counter : natural range 0 to 2**16-1;
        slow_counter : natural range 0 to 2**16-1;
        led_state : std_logic;
        fast_limit : natural range 0 to 2**16-1;
    end record;

    constant init_counter : counter := (0,0, '0', 10e3);

------------------------------------------------------------------------
    procedure create_counter
    (
        signal counter_object : inout counter;
        signal led_io : out std_logic;
        fast_limit : in natural range 0 to 2**16-1
    ) is
    begin
        led_io <= counter_object.led_state;
        counter_object.fast_counter <= counter_object.fast_counter + 1;
        if counter_object.fast_counter > fast_limit then
            counter_object.fast_counter <= 0;
            counter_object.slow_counter <= counter_object.slow_counter + 1;
        end if;
        if counter_object.slow_counter = 25e2 then
            counter_object.slow_counter <= 0;
            counter_object.led_state <= not counter_object.led_state;
        end if;
        
    end create_counter;

------------------------------------------------------------------------
    procedure create_counter
    (
        signal counter_object : inout counter;
        signal led_io : out std_logic
    ) is
    begin
        create_counter(counter_object, led_io, counter_object.fast_limit);
        
    end create_counter;

    function limit_to_32767
    (
        number : integer
    )
    return integer
    is
    begin
        if number > 32767 then
            return 32767;
        else
            return number;
        end if;
    end limit_to_32767;

------------------------------------------------------------------------
    signal led_blinker  : counter                    := init_counter;
    signal led_blinker1 : counter                    := init_counter;
    signal led_blinker2 : counter                    := init_counter;
    signal led_blinker3 : counter                    := init_counter;
    signal fast_limit   : natural range 0 to 2**16-1 := init_counter.fast_limit;

------------------------------------------------------------------------
    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal counter_for_100khz : natural range 0 to 2**12-1 := 1200;
    signal counter_for_uart : natural range 0 to 2**16-1 := 0;

------------------------------------------------------------------------
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;
    signal sine : natural range 0 to 2**16-1 := 0;

------------------------------------------------------------------------
    signal sine_vector : std_logic_vector(15 downto 0) := (others => '0');

------------------------------------------------------------------------
begin

    uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_FPGA_in.uart_rx <= uart_rx;
    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    led_blink : process(clk_120Mhz)
        
    begin
        if rising_edge(clk_120Mhz) then
            init_uart(uart_data_in);
            receive_data_from_uart(uart_data_out, led_blinker2.fast_limit);

            create_counter(led_blinker, led, fast_limit); -- this blinks as fast_limit is not record type
            create_counter(led_blinker1, led1);           -- this does not blink, initial record value lost
            create_counter(led_blinker2, led2);           -- this initializes fast_blink with 0
            create_counter(led_blinker3, led3);           -- this blinks, as fast limit driven with constant
            led_blinker3.fast_limit <= 25e3;

            create_multiplier(sincos_multiplier);
            create_sincos(sincos_multiplier, sincos);

            sine_vector <= std_logic_vector(to_unsigned(limit_to_32767(get_sine(sincos)),16));


            -- if button(1) = '1' then
                led  <= sine_vector(15);
                led1 <= sine_vector(14);
                led2 <= sine_vector(13);
                led3 <= sine_vector(12);
            -- end if;
                led  <= button_1;
                led2 <= button_2;


            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 1200;
                transmit_16_bit_word_with_uart(uart_data_in, led_blinker2.fast_limit);
                request_sincos(sincos, counter_for_uart);
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
