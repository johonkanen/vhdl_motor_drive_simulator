library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.permanent_magnet_motor_model_pkg.all;
    use math_library.pmsm_electrical_model_pkg.all;
    use math_library.pmsm_mechanical_model_pkg.all;
    use math_library.state_variable_pkg.all;

entity top is
    port (
        clk_120Mhz      : in std_logic  ;
        led             : out std_logic ;
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
    signal led_blinker : counter := init_counter;
    signal fast_limit : natural range 0 to 2**16-1 := init_counter.fast_limit;
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
    type abc is (phase_a, phase_b, phase_c, id, iq, w, angle);
    type multiplier_array is array (abc range abc'left to abc'right) of multiplier_record;
    signal multiplier : multiplier_array := (init_multiplier,init_multiplier, init_multiplier, init_multiplier, init_multiplier, init_multiplier, init_multiplier);

    signal vd_input_voltage : int18 := 300;
    signal vq_input_voltage : int18 := -300;

    signal pmsm_model : permanent_magnet_motor_model_record := init_permanent_magnet_motor_model;

    alias id_multiplier is multiplier(id);
    alias iq_multiplier is multiplier(iq);
    alias w_multiplier is multiplier(w);

    signal inductor_current : state_variable_record := init_state_variable_gain(5000);
    signal has_been_initialized : boolean := false;
begin

    uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_FPGA_in.uart_rx <= uart_rx;
    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx;

------------------------------------------------------------------------
    led_blink : process(clk_120Mhz)
        
    begin
        if rising_edge(clk_120Mhz) then
            receive_data_from_uart(uart_data_out, inductor_current.integrator_gain);
            create_counter(led_blinker, led, fast_limit);

            init_uart(uart_data_in);
            create_multiplier(sincos_multiplier);
            create_sincos(sincos_multiplier, sincos);

            create_multiplier(multiplier(id));
            create_multiplier(multiplier(iq));
            create_multiplier(multiplier(w));
            create_multiplier(multiplier(angle));
            create_state_variable(inductor_current, multiplier(id), 5000);
            sequential_multiply(multiplier(iq), get_cosine(sincos), 55000);
            -- create_pmsm_model(
            --     pmsm_model        ,
            --     multiplier(id)    ,
            --     multiplier(iq)    ,
            --     multiplier(w)     ,
            --     multiplier(angle) ,
            --     vd_input_voltage  ,
            --     vq_input_voltage      );

            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 1200;
                transmit_16_bit_word_with_uart(uart_data_in, inductor_current.state);
                request_sincos(sincos, counter_for_uart);
                counter_for_uart <= counter_for_uart + 1;

                request_state_variable_calculation(inductor_current);
                request_id_calculation(pmsm_model);
                request_iq_calculation(pmsm_model);
                request_angular_speed_calculation(pmsm_model);

                if counter_for_uart = 32768 then
                    set_load_torque(pmsm_model, 1000);
                end if;
                if counter_for_uart = 0 then
                    set_load_torque(pmsm_model, -1000);
                end if;


                -- if not has_been_initialized then
                --     has_been_initialized <= true;
                --     inductor_current <= init_state_variable_gain(5000);
                --     pmsm_model <= init_permanent_magnet_motor_model;
                -- end if;
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
