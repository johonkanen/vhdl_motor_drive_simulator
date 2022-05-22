library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;

package motor_control_data_processing_pkg is
    
    type motor_control_data_processing_FPGA_input_record is record
        data1 : std_logic;
    end record;
    
    type motor_control_data_processing_FPGA_output_record is record
        data : std_logic;
    end record;
    
    type motor_control_data_processing_FPGA_inout_record is record
        data : std_logic;
    end record;
    
    type motor_control_data_processing_data_input_record is record
        angle           : integer range -2**17 to 2**17-1;
        angular_speed   : integer range -2**17 to 2**17-1;
        d_current       : integer range -2**17 to 2**17-1;
        q_current       : integer range -2**17 to 2**17-1;
        speed_reference : integer range -2**17 to 2**17-1;
    end record;
    
    type motor_control_data_processing_data_output_record is record
        vd_voltage : integer range -2**17 to 2**17-1;
        vq_voltage : integer range -2**17 to 2**17-1;
    end record;
    
    component motor_control_data_processing is
        port (
            system_clocks : in system_clocks_record;
            motor_control_data_processing_FPGA_in    : in motor_control_data_processing_FPGA_input_record;
            motor_control_data_processing_FPGA_out   : out motor_control_data_processing_FPGA_output_record;
            motor_control_data_processing_data_in    : in motor_control_data_processing_data_input_record;
            motor_control_data_processing_data_out   : out motor_control_data_processing_data_output_record
        );
    end component motor_control_data_processing;
    
    -- signal motor_control_data_processing_clocks   : motor_control_data_processing_clock_record;
    -- signal motor_control_data_processing_FPGA_in  : motor_control_data_processing_FPGA_input_record;
    -- signal motor_control_data_processing_FPGA_out : motor_control_data_processing_FPGA_output_record;
    -- signal motor_control_data_processing_data_in  : motor_control_data_processing_data_input_record;
    -- signal motor_control_data_processing_data_out : motor_control_data_processing_data_output_record;
    
    -- u_motor_control_data_processing : motor_control_data_processing
    -- port map( motor_control_data_processing_clocks ,
    -- 	  motor_control_data_processing_FPGA_in       ,
    --	  motor_control_data_processing_FPGA_out      ,
    --	  motor_control_data_processing_data_in       ,
    --	  motor_control_data_processing_data_out);

end package motor_control_data_processing_pkg;
