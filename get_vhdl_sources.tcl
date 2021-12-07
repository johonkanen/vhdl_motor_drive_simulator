proc get_vhdl_sources {void}\
{ 
    return \
    { 
        /math_library/multiplier/multiplier_pkg.vhd
        /math_library/sincos/sincos_pkg.vhd
        /math_library/division/division_internal_pkg.vhd
        /math_library/division/division_pkg.vhd
        /math_library/division/division_pkg_body.vhd
        /math_library/first_order_filter/first_order_filter_pkg.vhd
        /math_library/pi_controller/pi_controller_pkg.vhd

        /dynamic_simulation_library/state_variable/state_variable_pkg.vhd
        /dynamic_simulation_library/lcr_filter_model/lcr_filter_model_pkg.vhd
        /dynamic_simulation_library/inverter_model/inverter_model_pkg.vhd
        /dynamic_simulation_library/power_supply_model/psu_inverter_simulation_models_pkg.vhd
        /dynamic_simulation_library/power_supply_model/power_supply_simulation_model_pkg.vhd

        /dynamic_simulation_library/ac_motor_models/pmsm_electrical_model_pkg.vhd
        /dynamic_simulation_library/ac_motor_models/pmsm_mechanical_model_pkg.vhd
        /dynamic_simulation_library/ac_motor_models/permanent_magnet_motor_model_pkg.vhd
        /dynamic_simulation_library/ac_motor_models/field_oriented_motor_control/field_oriented_motor_control_pkg.vhd

        /system_clocks_pkg.vhd

                    /uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
                    /uart/uart_transreceiver/uart_tx/uart_tx.vhd
                    /uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
                    /uart/uart_transreceiver/uart_rx/uart_rx.vhd
                /uart/uart_transreceiver/uart_transreceiver_pkg.vhd
                /uart/uart_transreceiver/uart_transreceiver.vhd

            /uart/uart_pkg.vhd
            /uart/uart.vhd


                        /system_control/system_hardware/motor_control_hardware/motor_control_data_processing/motor_control_data_processing_pkg.vhd
                        /system_control/system_hardware/motor_control_hardware/motor_control_data_processing/motor_control_data_processing.vhd
                    /system_control/system_hardware/motor_control_hardware/motor_control_hardware_pkg.vhd
                    /system_control/system_hardware/motor_control_hardware/motor_control_hardware.vhd
                    /system_control/system_hardware/arch_motor_control_hardware.vhd
                /system_control/system_hardware/system_hardware_pkg.vhd
                /system_control/system_hardware/system_hardware.vhd

            /system_control/system_control_pkg.vhd
            /system_control/system_control.vhd

        top.vhd 
    } 
}
