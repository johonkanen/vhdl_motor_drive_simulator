library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package system_clocks_pkg is

    type system_clocks_record is record
        main_clock : std_logic;
    end record;

end package system_clocks_pkg;
