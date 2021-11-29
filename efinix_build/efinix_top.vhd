library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk_120Mhz : in std_logic;
        led : out std_logic
    );
end entity top;


architecture rtl of top is

    type counter is record
        fast_counter : natural range 0 to 2**16-1;
        slow_counter : natural range 0 to 2**16-1;
        led_state : std_logic;
    end record;
    constant init_counter : counter := (0,0, '0');

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

    signal led_blinker : counter := init_counter;

begin

    led_blink : process(clk_120Mhz)
        
    begin
        if rising_edge(clk_120Mhz) then
            create_counter(led_blinker, led);
        end if; --rising_edge
    end process led_blink;	


end rtl;
