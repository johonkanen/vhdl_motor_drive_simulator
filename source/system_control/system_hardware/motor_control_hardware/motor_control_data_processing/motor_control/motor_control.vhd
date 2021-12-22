library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.motor_control_pkg.all;

entity motor_control is
    port (
        motor_control_clocks   : in motor_control_clock_group;
        motor_control_FPGA_out : out motor_control_FPGA_output_group;
        motor_control_data_in  : in motor_control_data_input_group;
        motor_control_data_out : out motor_control_data_output_group
    );
end entity;

architecture rtl of motor_control is

    alias clock is motor_control_clocks.core_clock;

begin


end rtl;
