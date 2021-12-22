library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package motor_control_pkg is

    -- add possibility for faster modulator clock
    type motor_control_clock_record is record
        core_clock : std_logic;
    end record;
    
    type motor_control_FPGA_output_record is record
        d_voltage : integer;
        q_voltage : integer;
    end record;
    constant init_motor_control_FPGA_out : motor_control_FPGA_output_record := (0,0);
    
    type motor_control_data_input_record is record
        id_current : integer;
        iq_current : integer;
    end record;
    constant init_motor_control_data_in : motor_control_data_input_record := (0,0);
    
    type motor_control_data_output_record is record
        motor_control_is_ready : boolean;
    end record;
    constant init_motor_control_data_out : motor_control_data_output_record := 
    (motor_control_is_ready => false);
    
    component motor_control is
        port (
            motor_control_clocks   : in motor_control_clock_record;
            motor_control_FPGA_out : out motor_control_FPGA_output_record;
            motor_control_data_in  : in motor_control_data_input_record;
            motor_control_data_out : out motor_control_data_output_record
        );
    end component motor_control;
    
    -- signal motor_control_clocks   : motor_control_clock_record;
    -- signal motor_control_FPGA_out : motor_control_FPGA_output_record;
    -- signal motor_control_data_in  : motor_control_data_input_record;
    -- signal motor_control_data_out : motor_control_data_output_record
    
    -- u_motor_control : motor_control
    -- port map( motor_control_clocks ,
    --	      motor_control_FPGA_out  ,
    --	      motor_control_data_in   ,
    --	      motor_control_data_out);
end package motor_control_pkg;
