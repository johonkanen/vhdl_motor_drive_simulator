# vhdl_motor_drive_simulator
VHDL source file project for a hardware in the loop simulation of a permanen magnet motor with field oriented control design

The high and low level controls will be synthesized on fpga.
The field oriented control and pmsm model can be found on dynamic simulation library.

The project uses submodules, thus it needs to be cloned using


git clone --recurse-submodules -j8 https://github.com/johonkanen/vhdl_motor_drive_simulator.git
