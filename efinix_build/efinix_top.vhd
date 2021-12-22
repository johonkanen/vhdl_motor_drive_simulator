library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;
    use work.test_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.lcr_filter_model_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.permanent_magnet_motor_model_pkg.all;

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

    -- this does not work
    signal led_blinker3 : counter                    := (0,0,'0',25e3);

    signal lcr_filter : lcr_model_record := init_lcr_filter;

-- this does not work
    -- signal led_blinker3 : counter := (init_counter.fast_counter ,
    --                                  init_counter.slow_counter  ,
    --                                  init_counter.led_state     ,
    --                                  init_counter.fast_limit  );
-- this does not work
    -- signal led_blinker3 : counter := (fast_counter => 0   ,
    --                                   slow_counter => 0   ,
    --                                   led_state    => '0' ,
    --                                   fast_limit   => 25e3  );

-- this does not work
    -- signal led_blinker3 : counter := (fast_counter => init_counter.fast_counter ,
    --                                   slow_counter => init_counter.slow_counter ,
    --                                   led_state    => init_counter.led_state    ,
    --                                   fast_limit   => init_counter.fast_limit  );
    signal filter_capacitor_state : int18 := 0;
    signal filter_inductor_state  : int18 := 0;

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
    signal sincos2 : sincos_record := init_sincos;


    signal id_multiplier    : multiplier_record := init_multiplier;
    signal iq_multiplier    : multiplier_record := init_multiplier;
    signal w_multiplier     : multiplier_record := init_multiplier;
    signal angle_multiplier : multiplier_record := init_multiplier;
    signal pmsm_model : permanent_magnet_motor_model_record := init_permanent_magnet_motor_model;

    type test_lcr_record is record
        inductor_current       :  state_variable_record;
        capacitor_voltage      :  state_variable_record;
        process_counter        :  natural range 0 to 15;
        process_counter2       :  natural range 0 to 15;
        current_state_equation :  int18                ;
        voltage_state_equation :  int18                ;
        R_load                 :  integer              ;
        R_inductor             :  integer              ;
        u_in                   :  int18                ;
        u_in_counter           :  natural range 0 to 2**14-1;
    end record;
    constant init_test_lcr : test_lcr_record := (
        init_state_variable_gain(500), init_state_variable_gain(500), 15, 15, 0, 0, 500, 5000, 5000, 15e3);

    signal test_lcr : test_lcr_record := init_test_lcr;


------------------------------------------------------------------------
    procedure create_test_lcr_filter
    (
        signal hw_multiplier : inout multiplier_record;
        signal lcr_filter_object : inout test_lcr_record
    ) is
        alias inductor_current        is lcr_filter_object.inductor_current       ;
        alias capacitor_voltage       is lcr_filter_object.capacitor_voltage      ;
        alias process_counter         is lcr_filter_object.process_counter        ;
        alias process_counter2        is lcr_filter_object.process_counter2       ;
        alias current_state_equation  is lcr_filter_object.current_state_equation ;
        alias voltage_state_equation  is lcr_filter_object.voltage_state_equation ;
        alias R_load                  is lcr_filter_object.R_load                 ;
        alias R_inductor              is lcr_filter_object.R_inductor             ;
        alias u_in                    is lcr_filter_object.u_in                   ;
        alias u_in_counter            is lcr_filter_object.u_in_counter           ;
    begin

        -- working version consumes 1422 logic elements and non working version ~1070 logic elements

        -- this works
        create_state_variable(lcr_filter_object.inductor_current  , hw_multiplier , current_state_equation);
        create_state_variable(lcr_filter_object.capacitor_voltage , hw_multiplier , voltage_state_equation);

        -- this does not, uses aliases for inductor_current and capacitor_voltage
        -- create_state_variable(inductor_current  , hw_multiplier , current_state_equation);
        -- create_state_variable(capacitor_voltage , hw_multiplier , voltage_state_equation);
        
        CASE process_counter is
            WHEN 0 => multiply_and_increment_counter(hw_multiplier , process_counter , get_state(capacitor_voltage) , R_load);
            WHEN 1 => multiply_and_increment_counter(hw_multiplier , process_counter , get_state(inductor_current)  , R_inductor);
            WHEN others =>  -- do nothing
        end CASE;

        CASE process_counter2 is
            WHEN 0 => 
                if multiplier_is_ready(w_multiplier) then
                    voltage_state_equation <= get_multiplier_result(w_multiplier, 15);
                    increment(process_counter2);
                end if;

            WHEN 1 => 
                if multiplier_is_ready(w_multiplier) then
                    current_state_equation <= get_multiplier_result(w_multiplier, 15);
                    voltage_state_equation <= -voltage_state_equation + inductor_current;
                    increment(process_counter2);
                end if;

            WHEN 2 => 
                current_state_equation <= -current_state_equation - capacitor_voltage + u_in;
                increment(process_counter2);

            WHEN 3 => 
                request_state_variable_calculation(inductor_current);
                increment(process_counter2);
                      
            WHEN 4 => 
                if state_variable_calculation_is_ready(inductor_current) then
                    request_state_variable_calculation(capacitor_voltage);
                    increment(process_counter2);
                end if;

            WHEN others =>  -- do nothing
        end CASE;

    end create_test_lcr_filter;
------------------------------------------------------------------------


------------------------------------------------------------------------
------------------------------------------------------------------------
begin

    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    led_blink : process(clk_120Mhz)

    begin
        if rising_edge(clk_120Mhz) then
            init_uart(uart_data_in);

            create_multiplier(id_multiplier);
            create_multiplier(iq_multiplier);
            create_multiplier(angle_multiplier);

            create_counter(led_blinker , led , fast_limit);
            create_counter(led_blinker1, led1);
            create_counter(led_blinker2, led2);
            if button_is_pressed(button_2) then
                led_blinker2.fast_limit <= 38e3;
            end if;

            create_counter(led_blinker3, led3, led_blinker3.fast_limit);

            create_multiplier(sincos_multiplier)      ;
            create_sincos(sincos_multiplier, sincos)  ;
            create_sincos(sincos_multiplier, sincos2) ;

            if sincos_is_ready(sincos) then
                request_sincos(sincos2, counter_for_uart);
            end if;

            create_multiplier(w_multiplier);
            create_test_lcr_filter(w_multiplier, test_lcr);

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

            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else

                test_lcr.process_counter <= 0;
                test_lcr.process_counter2 <= 0;
                
                if test_lcr.u_in_counter /= 0 then
                    test_lcr.u_in_counter <= test_lcr.u_in_counter - 1;
                else
                    test_lcr.u_in_counter <= 15e3;
                    test_lcr.u_in <= -test_lcr.u_in;
                end if;
                counter_for_100khz <= 1200;
                transmit_16_bit_word_with_uart(uart_data_in, get_state(test_lcr.capacitor_voltage) + 32768);
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
