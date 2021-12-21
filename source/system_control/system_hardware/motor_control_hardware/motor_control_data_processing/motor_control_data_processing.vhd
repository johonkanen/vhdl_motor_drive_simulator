library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.motor_control_data_processing_pkg.all;
    use work.motor_control_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.dq_to_ab_transform_pkg.all;
    use math_library.permanent_magnet_motor_model_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.field_oriented_motor_control_pkg.all;
    use math_library.pi_controller_pkg.all;

entity motor_control_data_processing is
    port (
        system_clocks                          : in system_clocks_record;
        motor_control_data_processing_FPGA_in  : in motor_control_data_processing_FPGA_input_record;
        motor_control_data_processing_FPGA_out : out motor_control_data_processing_FPGA_output_record;
        motor_control_data_processing_data_in  : in motor_control_data_processing_data_input_record;
        motor_control_data_processing_data_out : out motor_control_data_processing_data_output_record
    );
end entity;

architecture rtl of motor_control_data_processing is

    alias main_clock is system_clocks.main_clock;

    signal control_multiplier : multiplier_record := init_multiplier;
    signal control_multiplier2 : multiplier_record := init_multiplier;

    signal id_current_control : motor_current_control_record := init_motor_current_control;
    signal iq_current_control : motor_current_control_record := init_motor_current_control;

    signal speed_control_multiplier : multiplier_record := init_multiplier;
    signal speed_controller : pi_controller_record := init_pi_controller;
    signal d_reference : int18 := -5000;

    signal speed_reference : int18 := 15e3;

    signal counter_for_100khz : natural range 0 to 2**12-1 := 1000;

    signal motor_control_clocks   : motor_control_clock_record;
    signal motor_control_FPGA_out : motor_control_FPGA_output_record;
    signal motor_control_data_in  : motor_control_data_input_record;
    signal motor_control_data_out : motor_control_data_output_record;
    
begin

    motor_control_data_processing_FPGA_out <= (data => '0');

------------------------------------------------------------------------
    test_motor_control : process(main_clock)
        
    begin
        if rising_edge(main_clock) then
            --------------------------------------------------
            create_multiplier(control_multiplier);
            create_motor_current_control(
                control_multiplier                                          ,
                id_current_control                                          ,
                default_motor_parameters.Lq                                 ,
                motor_control_data_processing_data_in.angular_speed         ,
                default_motor_parameters.rotor_resistance                   ,
                d_reference-motor_control_data_processing_data_in.d_current , 
                motor_control_data_processing_data_in.q_current);

            --------------------------------------------------
            create_multiplier(control_multiplier2);
            create_motor_current_control(
                control_multiplier2                                                                     ,
                iq_current_control                                                                      ,
                default_motor_parameters.Ld                                                             ,
                motor_control_data_processing_data_in.angular_speed                                     ,
                default_motor_parameters.rotor_resistance                                               ,
                get_pi_control_output(speed_controller)-motor_control_data_processing_data_in.q_current ,
                motor_control_data_processing_data_in.d_current);
            --------------------------------------------------
            create_multiplier(speed_control_multiplier);
            create_pi_controller(speed_control_multiplier, speed_controller, 4000, 250);

            --------------------------------------------------
            if counter_for_100khz > 0 then
                counter_for_100khz <= counter_for_100khz - 1;
            else
                counter_for_100khz <= 1000;

                request_motor_current_control(id_current_control);
                request_motor_current_control(iq_current_control);
                request_pi_control(speed_controller, motor_control_data_processing_data_in.speed_reference - motor_control_data_processing_data_in.angular_speed);
            end if;

            motor_control_data_processing_data_out <= (vd_voltage => -get_control_output(id_current_control),
                                                       vq_voltage => -get_control_output(iq_current_control));
        end if; --rising_edge
    end process test_motor_control;	
------------------------------------------------------------------------

------------------------------------------------------------------------
    u_motor_control : motor_control
    port map( motor_control_clocks   ,
              motor_control_FPGA_out ,
              motor_control_data_in  ,
              motor_control_data_out);
------------------------------------------------------------------------
end rtl;
