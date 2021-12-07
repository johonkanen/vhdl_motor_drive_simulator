library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;

entity top is
    port (
        clock_reference         : in std_logic;
        system_control_FPGA_in  : in system_control_FPGA_input_record;
        system_control_FPGA_out : out system_control_FPGA_output_record
    );
end entity top;

architecture rtl of top is

    signal system_clocks : system_clocks_record;

begin

------------------------------------------------------------------------
    u_system_control : system_control
    port map( system_clocks      ,
    	  system_control_FPGA_in ,
    	  system_control_FPGA_out);

------------------------------------------------------------------------
end rtl;
