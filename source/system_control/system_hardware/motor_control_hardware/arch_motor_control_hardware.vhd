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
        use math_library.dq_to_ab_transform_pkg.all;
        use math_library.permanent_magnet_motor_model_pkg.all;
        use math_library.sincos_pkg.all;
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

    constant counter_at_100khz : natural := 1199;
    signal simulator_counter : natural range 0 to 2**12-1 := counter_at_100khz;

    alias vd_input_voltage is motor_control_data_processing_data_out.vd_voltage;
    alias vq_input_voltage is motor_control_data_processing_data_out.vq_voltage;

    signal transform_multiplier : multiplier_record := init_multiplier;
    signal dq_to_ab_transform : dq_to_ab_record := init_dq_to_ab_transform;

    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;

    signal stimulus_counter : natural range 0 to 2**16-1 := 65535;

    signal speed_reference : int18 := -20e3;
    signal speed_loop_counter : natural range 0 to 15 := 0;

begin
    motor_control_hardware_FPGA_out <= (motor_control_data_processing_FPGA_out => motor_control_data_processing_FPGA_out);


    motor_simulator : process(main_clock)
        
    begin
        if rising_edge(main_clock) then
            create_multiplier(id_multiplier);
            create_multiplier(iq_multiplier);
            create_multiplier(w_multiplier);
            create_multiplier(angle_multiplier);
            create_multiplier(transform_multiplier);
            create_multiplier(sincos_multiplier);


            --------------------------------------------------
            create_sincos(sincos_multiplier, sincos);
            request_sincos(sincos, get_electrical_angle(pmsm_model));
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


                    request_id_calculation(pmsm_model , vd_input_voltage);
                    request_iq_calculation(pmsm_model , vq_input_voltage );

                    if stimulus_counter > 0 then
                        stimulus_counter <= stimulus_counter - 1;
                    else
                        stimulus_counter <= 65535;
                    end if;

                    speed_loop_counter <= speed_loop_counter + 1;
                    if speed_loop_counter = 9 then
                        speed_loop_counter <= 0;
                        request_electrical_angle_calculation(pmsm_model);
                        request_angular_speed_calculation(pmsm_model);
                    end if;
                end if;




                CASE stimulus_counter is
                    WHEN 32768 => set_load_torque(pmsm_model, 20e3);
                    WHEN 16384 => speed_reference <= 10e3;
                    WHEN 49152 => speed_reference <= -20e3;
                    WHEN 0 => set_load_torque(pmsm_model, -20e3);
                    WHEN others => -- do nothing
                end CASE;


            --------------------------------------------------
                motor_control_hardware_data_out.d_current <= get_angular_speed(pmsm_model);

                motor_control_data_processing_data_in <= (angular_speed  => get_angular_speed(pmsm_model),
                                                         angle           => get_electrical_angle(pmsm_model),
                                                         d_current       => get_d_component(pmsm_model),
                                                         q_current       => get_q_component(pmsm_model),
                                                         speed_reference => speed_reference);

        end if; --rising_edge
    end process motor_simulator;	


------------------------------------------------------------------------
    u_motor_control_data_processing : motor_control_data_processing
    port map( system_clocks ,
    	  motor_control_hardware_FPGA_in.motor_control_data_processing_FPGA_in       ,
    	  motor_control_data_processing_FPGA_out      ,
    	  motor_control_data_processing_data_in       ,
    	  motor_control_data_processing_data_out);

------------------------------------------------------------------------
end simulated;
