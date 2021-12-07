-- library ieee;
--     use ieee.std_logic_1164.all;
--     use ieee.numeric_std.all;
--
-- library work;
--     use work.system_clocks_pkg.all;
--     use work.motor_control_hardware_pkg.all;
--
-- entity motor_control_hardware is
--     port (
--         system_clocks                   : in system_clocks_record;
--         motor_control_hardware_FPGA_in  : in motor_control_hardware_FPGA_input_record;
--         motor_control_hardware_FPGA_out : out motor_control_hardware_FPGA_output_record;
--         motor_control_hardware_data_in  : in motor_control_hardware_data_input_record;
--         motor_control_hardware_data_out : out motor_control_hardware_data_output_record
--     );
-- end entity;


architecture simulated of motor_control_hardware is


    -- motor simulator libraries
        use math_library.multiplier_pkg.all;
        use math_library.permanent_magnet_motor_model_pkg.all;
    -- end motor simulator libraries
    signal id_multiplier    : multiplier_record := init_multiplier;
    signal iq_multiplier    : multiplier_record := init_multiplier;
    signal w_multiplier     : multiplier_record := init_multiplier;
    signal angle_multiplier : multiplier_record := init_multiplier;

    alias main_clock is system_clocks.main_clock;
        

    signal motor_control_data_processing_FPGA_in  : motor_control_data_processing_FPGA_input_record;
    signal motor_control_data_processing_FPGA_out : motor_control_data_processing_FPGA_output_record;
    signal motor_control_data_processing_data_in  : motor_control_data_processing_data_input_record;
    signal motor_control_data_processing_data_out : motor_control_data_processing_data_output_record;
    
    signal pmsm_model : permanent_magnet_motor_model_record := init_permanent_magnet_motor_model;

    constant counter_at_100khz : natural := 1200;
    signal simulator_counter : natural range 0 to 2**12-1 := 1200;

    signal vd_input_voltage : int18 := 300;
    signal vq_input_voltage : int18 := -300;

begin
    motor_control_hardware_FPGA_out <= (motor_control_data_processing_FPGA_out => motor_control_data_processing_FPGA_out);


    motor_simulator : process(main_clock)
        
    begin
        if rising_edge(main_clock) then
            create_multiplier(id_multiplier);
            create_multiplier(iq_multiplier);
            create_multiplier(w_multiplier);
            create_multiplier(angle_multiplier);
            --------------------------------------------------
            create_pmsm_model(
                pmsm_model       ,
                id_multiplier    ,
                iq_multiplier    ,
                w_multiplier     ,
                angle_multiplier ,
                default_motor_parameters);
            --------------------------------------------------
                if simulator_counter > 0 then
                    simulator_counter <= simulator_counter - 1;
                else
                    simulator_counter <= counter_at_100khz;

                    request_electrical_angle_calculation(pmsm_model);
                    request_angular_speed_calculation(pmsm_model);
                    request_id_calculation(pmsm_model , vd_input_voltage);
                    request_iq_calculation(pmsm_model , vq_input_voltage );
                end if;
            --------------------------------------------------
        end if; --rising_edge
    end process motor_simulator;	


    u_motor_control_data_processing : motor_control_data_processing
    port map( system_clocks ,
    	  motor_control_hardware_FPGA_in.motor_control_data_processing_FPGA_in       ,
    	  motor_control_data_processing_FPGA_out      ,
    	  motor_control_data_processing_data_in       ,
    	  motor_control_data_processing_data_out);

end simulated;
