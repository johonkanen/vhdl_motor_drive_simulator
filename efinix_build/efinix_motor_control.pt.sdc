
# Efinity Interface Designer SDC
# Version: 2021.1.165
# Date: 2021-11-29 20:50

# Copyright (C) 2017 - 2021 Efinix Inc. All rights reserved.

# Device: T120F324
# Project: efinix_motor_control
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 8.33 clk_120Mhz

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {extclk_30mhz}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {extclk_30mhz}]

# LVDS RX GPIO Constraints
############################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {uart_rx}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {uart_rx}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {led}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {led}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {uart_tx}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {uart_tx}]

# LVDS Rx Constraints
####################
