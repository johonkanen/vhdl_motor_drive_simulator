library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

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
end package body test_pkg;

