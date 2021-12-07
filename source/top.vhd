library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;

entity top is
    port (
        input_clock         : in std_logic;
        system_control_FPGA_in  : in system_control_FPGA_input_record;
        system_control_FPGA_out : out system_control_FPGA_output_record
    );
end entity top;

architecture rtl of top is

    signal system_clocks : system_clocks_record;

------------------------------------------------------------------------
    component main_clocks IS
        PORT
        (
            areset : IN STD_LOGIC := '0' ;
            inclk0 : IN STD_LOGIC := '0' ;
            c0     : OUT STD_LOGIC       ;
            locked : OUT STD_LOGIC
        );
    END component main_clocks;

begin

------------------------------------------------------------------------
    u_main_clocks : main_clocks
    port map( areset => '0'                      ,
              inclk0 => input_clock              ,
              c0     => system_clocks.main_clock ,
              locked => open);

------------------------------------------------------------------------
    u_system_control : system_control
    port map( system_clocks      ,
    	  system_control_FPGA_in ,
    	  system_control_FPGA_out);

------------------------------------------------------------------------
end rtl;
