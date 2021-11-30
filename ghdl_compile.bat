echo off
set source=source/

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/sincos/sincos_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_internal_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/first_order_filter/first_order_filter_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/pi_controller/pi_controller_pkg.vhd

ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/state_variable/state_variable_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/lcr_filter_model/lcr_filter_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/inverter_model/inverter_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/power_supply_model/psu_inverter_simulation_models_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/power_supply_model/power_supply_simulation_model_pkg.vhd

ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/ac_motor_models/pmsm_electrical_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/ac_motor_models/pmsm_mechanical_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/ac_motor_models/permanent_magnet_motor_model_pkg.vhd

            ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
        ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_transreceiver_pkg.vhd
    ghdl -a --ieee=synopsys %source%/uart/uart_pkg.vhd
