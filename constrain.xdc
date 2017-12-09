set_property -dict {PACKAGE_PIN E3 IOSTANDARD  LVCMOS33} [get_ports {CLK100MHZ}];
create_clock -period 10.0 -name sys_clk_pin -waveform {0.0 5.0} -add [get_ports {CLK100MHZ}];

set_property -dict {PACKAGE_PIN F6  IOSTANDARD LVCMOS33} [get_ports {OUT[0]}];
set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33} [get_ports {OUT[1]}];
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports {OUT[2]}];
set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33} [get_ports {OUT[3]}];
set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports {OUT[4]}];
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports {OUT[5]}];
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports {OUT[6]}];
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {OUT[7]}];

set_property -dict {PACKAGE_PIN D9  IOSTANDARD LVCMOS33} [get_ports {RESET}];
