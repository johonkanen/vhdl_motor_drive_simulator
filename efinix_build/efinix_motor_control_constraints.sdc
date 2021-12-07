create_clock -period 33 -name extclk_30mhz
create_clock -period 8.333 -name clk_120Mhz

set_false_path -from * -to [get_ports *uart_tx*]

