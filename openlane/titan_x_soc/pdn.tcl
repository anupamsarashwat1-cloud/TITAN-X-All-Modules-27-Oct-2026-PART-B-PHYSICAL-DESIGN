# SPDX-License-Identifier: Apache-2.0
# SMVDU TITAN-X SoC — Power Delivery Network (PDN) Configuration
# Defines VDD and VSS Power Grid on SkyWater 130nm 5-Metal Layer Stack

# Power Nets definition
set ::power_nets "VDD"
set ::ground_nets "VSS"

# Standard cell rail on met1
set_voltage_domain -name CORE -power VDD -ground VSS

# Core Power Rings (met4 horizontal, met5 vertical)
define_power_grid -name core_grid -voltage_domain CORE
add_ring -grid core_grid -layers {met4 met5} -widths {5.0 5.0} -spaces {2.0 2.0} -offset {3.0 3.0}

# Standard Cell Rails (met1)
add_stripe -grid core_grid -layer met1 -width 0.48 -pitch 5.44 -offset 0

# Intermediate Power Straps (met4 horizontal, met5 vertical)
add_stripe -grid core_grid -layer met4 -width 1.6 -pitch 40.0 -offset 10.0
add_stripe -grid core_grid -layer met5 -width 1.6 -pitch 40.0 -offset 10.0

# Connect all overlapping power layers
add_connection -grid core_grid -layers {met1 met4}
add_connection -grid core_grid -layers {met4 met5}
