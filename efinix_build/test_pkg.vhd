library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.state_variable_pkg.all;

package test_pkg is
------------------------------------------------------------------------
    type counter is record
        fast_counter : natural range 0 to 2**16-1;
        slow_counter : natural range 0 to 2**16-1;
        led_state    : std_logic;
        fast_limit   : natural range 0 to 2**16-1;
    end record;

    constant init_counter : counter := (0,0, '0', 10e3);

------------------------------------------------------------------------
    type test_lcr_record is record
        inductor_current       :  state_variable_record;
        capacitor_voltage      :  state_variable_record;
        process_counter        :  natural range 0 to 15;
        process_counter2       :  natural range 0 to 15;
        current_state_equation :  int18                ;
        voltage_state_equation :  int18                ;
        R_load                 :  integer              ;
        R_inductor             :  integer              ;
    end record;

    constant init_test_lcr : test_lcr_record := (
        init_state_variable_gain(500), init_state_variable_gain(500), 15, 15, 0, 0, 500, 5000);

    procedure request_test_lcr_filter_calculation (
        signal lcr_filter_object : out test_lcr_record);

------------------------------------------------------------------------
    procedure create_test_lcr_filter (
        signal hw_multiplier     : inout multiplier_record;
        signal lcr_filter_object : inout test_lcr_record;
        u_in                     : in int18);
------------------------------------------------------------------------
    function get_lcr_capacitor_voltage ( lcr_filter_object : test_lcr_record)
        return integer;
------------------------------------------------------------------------
    procedure create_counter (
        signal counter_object : inout counter;
        signal led_io         : out std_logic;
        fast_limit            : in natural range 0 to 2**16-1);
------------------------------------------------------------------------
    procedure create_counter (
        signal counter_object : inout counter;
        signal led_io         : out std_logic);
------------------------------------------------------------------------
    function limit_to_32767 ( number : integer)
        return integer;
------------------------------------------------------------------------
    function set_1_when_larger_than ( left, right : integer)
        return std_logic ;
------------------------------------------------------------------------
    function button_is_pressed ( button : std_logic )
        return boolean;
------------------------------------------------------------------------

end package test_pkg;

package body test_pkg is
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure create_counter
    (
        signal counter_object : inout counter;
        signal led_io : out std_logic;
        fast_limit : in natural range 0 to 2**16-1
    ) is
    begin
        led_io <= counter_object.led_state;
        if counter_object.slow_counter > 25e2 then
            counter_object.slow_counter <= 0;
            counter_object.led_state <= not counter_object.led_state;
        end if;

        counter_object.fast_counter <= counter_object.fast_counter + 1;
        if counter_object.fast_counter > fast_limit then
            counter_object.fast_counter <= 0;
            counter_object.slow_counter <= counter_object.slow_counter + 1;
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

------------------------------------------------------------------------
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
    function set_1_when_larger_than
    (
        left, right : integer
    )
    return std_logic 
    is
    begin
        if abs(left) > abs(right) then
            return '1';
        else
            return '0';
        end if;
    end set_1_when_larger_than;
------------------------------------------------------------------------
    function button_is_pressed
    (
        button : std_logic 
    )
    return boolean
    is
    begin
        return button = '0';
    end button_is_pressed;
------------------------------------------------------------------------

------------------------------------------------------------------------
    procedure create_test_lcr_filter
    (
        signal hw_multiplier : inout multiplier_record;
        signal lcr_filter_object : inout test_lcr_record;
        u_in : in int18
    ) is
        alias inductor_current        is lcr_filter_object.inductor_current       ;
        alias capacitor_voltage       is lcr_filter_object.capacitor_voltage      ;
        alias process_counter         is lcr_filter_object.process_counter        ;
        alias process_counter2        is lcr_filter_object.process_counter2       ;
        alias current_state_equation  is lcr_filter_object.current_state_equation ;
        alias voltage_state_equation  is lcr_filter_object.voltage_state_equation ;
        alias R_load                  is lcr_filter_object.R_load                 ;
        alias R_inductor              is lcr_filter_object.R_inductor             ;
    begin

        -- working version consumes ~1400 logic elements and non working version ~1000 logic elements

        -- this works, when aliases are not used
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
                if multiplier_is_ready(hw_multiplier) then
                    voltage_state_equation <= get_multiplier_result(hw_multiplier, 15);
                    increment(process_counter2);
                end if;

            WHEN 1 => 
                if multiplier_is_ready(hw_multiplier) then
                    current_state_equation <= get_multiplier_result(hw_multiplier, 15);
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
    procedure request_test_lcr_filter_calculation
    (
        signal lcr_filter_object : out test_lcr_record
    ) is
    begin
        lcr_filter_object.process_counter <= 0;
        lcr_filter_object.process_counter2 <= 0;
        
    end request_test_lcr_filter_calculation;
------------------------------------------------------------------------
    function get_lcr_capacitor_voltage
    (
        lcr_filter_object : test_lcr_record
    )
    return integer
    is
    begin
        return get_state(lcr_filter_object.capacitor_voltage);
    end get_lcr_capacitor_voltage;
------------------------------------------------------------------------
end package body test_pkg;

