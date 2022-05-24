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

    alias main_clock is system_clocks.main_clock;
    -- motor simulator libraries
        use math_library.multiplier_pkg.all;
        use math_library.dq_to_ab_transform_pkg.all;
        use math_library.permanent_magnet_motor_model_pkg.all;
        use math_library.sincos_pkg.all;
    -- end motor simulator libraries
    signal motor_control_data_processing_FPGA_in  : motor_control_data_processing_FPGA_input_record;
    signal motor_control_data_processing_FPGA_out : motor_control_data_processing_FPGA_output_record;
    signal motor_control_data_processing_data_in  : motor_control_data_processing_data_input_record;
    signal motor_control_data_processing_data_out : motor_control_data_processing_data_output_record;

    alias vd_input_voltage is motor_control_data_processing_data_out.vd_voltage;
    alias vq_input_voltage is motor_control_data_processing_data_out.vq_voltage;

    constant counter_at_100khz : natural := 1199;
    signal simulator_counter : natural range 0 to 2**12-1 := counter_at_100khz;
    signal stimulus_counter : natural range 0 to 2**16-1 := 65535;

    signal speed_reference : int18 := -20e3;
    signal speed_loop_counter : natural range 0 to 15 := 0;

------------------------------------------------------------------------
    type all_in_one_motor_model_record is record
        id_multiplier        : multiplier_record;
        iq_multiplier        : multiplier_record;
        w_multiplier         : multiplier_record;
        angle_multiplier     : multiplier_record;
        transform_multiplier : multiplier_record;
        sincos_multiplier    : multiplier_record;

        pmsm_model         : permanent_magnet_motor_model_record;
        sincos             : sincos_record                      ;
        dq_to_ab_transform : dq_to_ab_record                    ;
    end record;
------------------------------------------------------------------------
    constant init_all_in_one_motor_model : all_in_one_motor_model_record := (
        init_multiplier, init_multiplier,
        init_multiplier, init_multiplier,
        init_multiplier, init_multiplier,
        init_permanent_magnet_motor_model,
        init_sincos,
        init_dq_to_ab_transform);
------------------------------------------------------------------------
    procedure create_all_in_one_motor_model
    (
        signal motor_model_object : inout all_in_one_motor_model_record
    ) is
        alias m is motor_model_object;
    begin
            create_multiplier(m.id_multiplier);
            create_multiplier(m.iq_multiplier);
            create_multiplier(m.w_multiplier);
            create_multiplier(m.angle_multiplier);
            create_multiplier(m.transform_multiplier);
            create_multiplier(m.sincos_multiplier);
            --------------------------------------------------
            create_sincos(m.sincos_multiplier, m.sincos);
            request_sincos(m.sincos, get_electrical_angle(m.pmsm_model));
            --------------------------------------------------
            create_pmsm_model(
                m.pmsm_model       ,
                m.id_multiplier    ,
                m.iq_multiplier    ,
                m.w_multiplier     ,
                m.angle_multiplier ,
                default_motor_parameters);
            --------------------------------------------------
    end create_all_in_one_motor_model;

    signal motor_model : all_in_one_motor_model_record := init_all_in_one_motor_model;

------------------------------------------------------------------------     

begin
    motor_control_hardware_FPGA_out <= (motor_control_data_processing_FPGA_out => motor_control_data_processing_FPGA_out);

------------------------------------------------------------------------
    motor_simulator : process(main_clock)
        alias id_multiplier        is motor_model.id_multiplier        ;
        alias iq_multiplier        is motor_model.iq_multiplier        ;
        alias w_multiplier         is motor_model.w_multiplier         ;
        alias angle_multiplier     is motor_model.angle_multiplier     ;
        alias transform_multiplier is motor_model.transform_multiplier ;
        alias sincos_multiplier    is motor_model.sincos_multiplier    ;
        alias pmsm_model           is motor_model.pmsm_model           ;
        alias sincos               is motor_model.sincos               ;
        alias dq_to_ab_transform   is motor_model.dq_to_ab_transform   ;
    begin
        if rising_edge(main_clock) then

            --------------------------------------------------
            create_all_in_one_motor_model(motor_model);
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

            --------------------------------------------------
            CASE stimulus_counter is
                WHEN 32768 => set_load_torque(pmsm_model, 20e3);
                WHEN 16384 => speed_reference <= 10e3;
                WHEN 49152 => speed_reference <= -20e3;
                WHEN 0 => set_load_torque(pmsm_model, -20e3);
                WHEN others => -- do nothing
            end CASE;

            --------------------------------------------------
            motor_control_hardware_data_out.d_current <= get_q_component(pmsm_model);

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
