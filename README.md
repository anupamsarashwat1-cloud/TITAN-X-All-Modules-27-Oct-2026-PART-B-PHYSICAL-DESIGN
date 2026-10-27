# SMVDU TITAN-X SoC — Physical Design (RTL-to-GDS) Repository

## Overview
This repository contains the complete, dedicated **ASIC Physical Design Flow** for the **SMVDU TITAN-X SoC**, a 64-bit multi-core RISC-V System-on-Chip implemented in the open-source **SkyWater 130nm (`sky130A`)** process technology using the high-density standard cell library (`sky130_fd_sc_hd`).

The flow covers the complete automated silicon tapeout pipeline:
1. **RTL Elaboration & Standard Cell Synthesis**: Yosys with ABC optimization and timing-driven mapping.
2. **Floorplanning & I/O Pin Placement**: Aspect ratio 1.0, 45% core utilization, and edge-specific pin ordering (`pin_order.cfg`).
3. **Power Delivery Network (PDN)**: VDD and VSS dual-layer power rings (met4/met5), met1 standard cell rails, and orthogonal power straps.
4. **Standard Cell Placement**: Global placement (RePlAce) and detailed legalization (OpenDP).
5. **Clock Tree Synthesis (CTS)**: TritonCTS low-skew buffer insertion with max skew target <150 ps.
6. **Global & Detailed Routing**: FastRoute global routing and TritonRoute detailed multi-layer routing (met1 through met5).
7. **Parasitic Extraction (RC Extraction)**: SPEF extraction across process and temperature corners.
8. **Static Timing Analysis (STA)**: OpenSTA signoff verification ensuring zero setup/hold violations (WNS >= 0, TNS = 0).
9. **Physical Verification**: Magic DRC, KLayout DRC, and Netgen Layout Versus Schematic (LVS).
10. **GDSII Stream Generation**: Final tapeout GDSII generation and stream-out verification.

---

## Directory Structure
```
TITAN-X-All-Modules-27-Oct-2026-PART-B-PHYSICAL-DESIGN/
├── fresh_soc_filelist.f           # 71 synthesizable RTL modules in strict dependency order
├── common/                        # Synchronizers, clock gates (BUFX4), and async FIFOs
├── includes/                      # ISA definitions, parameters, and headers
├── frontend/                      # Fetch, Decode, Branch Prediction, and I-Cache
├── backend/                       # Execute, Memory, Regfile, CSRs, MMU/TLB/PTW, FPU, PLIC, CLINT
├── interconnect/                  # AXI4 Crossbar, APB/AHB Bridges, MPU, QoS
├── memory/                        # L2 Cache, DDR4 Controller & PHY, SRAM Macros
├── peripherals/                   # UART 16550, GPIO, RTC, Watchdog, I2C, SPI, CAN, Ethernet
├── storage/                       # SD/MMC Controller, QSPI Flash, USB OTG
├── video/                         # HDMI Controller, VDMA, ISP, MIPI CSI-2 RX
├── security/                      # Secure Boot RoT, ECDSA, SHA-256, AES, DRBG, TRNG
├── top/                           # SoC Top (titan_x_top) and BootROM (axi_rom)
├── constraints/                   # SDC Timing Constraints & OpenLane Pin Ordering
│   ├── titan_x_soc.sdc            # Production SDC: 100 MHz target, I/O delays, multicycle paths
│   └── pin_order.cfg              # Edge-specific pin distribution (North/South/East/West)
├── openlane/                      # OpenLane / OpenROAD Flow Setup
│   └── titan_x_soc/
│       ├── config.tcl             # Production OpenLane flow configuration
│       └── pdn.tcl                # Power grid (rails, straps, rings) specification
├── scripts/                       # Automated Physical Design Scripts
│   ├── synth_yosys.tcl            # Yosys synthesis script to sky130_fd_sc_hd
│   ├── run_openlane.sh            # Automated OpenLane Docker execution runner
│   ├── run_drc.sh                 # Magic and KLayout DRC runner
│   ├── run_lvs.sh                 # Netgen LVS runner
│   └── run_flow.sh                # Master one-click RTL-to-GDS flow runner
└── results/                       # Tapeout Deliverables Directory
    ├── synthesis/                 # Gate-level netlist (.v) and area reports
    ├── floorplan/                 # Floorplanned DEF and die boundary
    ├── placement/                 # Placed DEF and cell density maps
    ├── cts/                       # Clock tree inserted DEF and skew reports
    ├── routing/                   # Detailed routed DEF and wirelength reports
    ├── sta/                       # Signoff timing reports (min/max corners, slack)
    ├── drc/                       # Magic / KLayout DRC violation reports
    ├── lvs/                       # Netgen LVS match reports
    └── gds/                       # Final tapeout GDSII stream file
```

---

## Tool Environment & Prerequisites

- **Host Operating System**: Linux x86_64
- **Process Design Kit (PDK)**: SkyWater 130nm (`sky130A`) installed at `/home/anupam-sarashwat/.ciel/sky130A`
- **Standard Cell Library**: `sky130_fd_sc_hd` (High Density 7-track library)
- **Synthesis Engine**: Yosys 0.33+
- **Physical Design Engine**: OpenLane / OpenROAD (Docker image `ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69`)
- **Physical Verification**: Magic VLSI Layout Tool 8.3+, KLayout 0.28+, Netgen 1.5+

### Environment Setup
```bash
export PDK_ROOT=/home/anupam-sarashwat/.ciel
export PDK=sky130A
export STD_CELL_LIBRARY=sky130_fd_sc_hd
```

---

## Execution Instructions

### 1. One-Click Automated RTL-to-GDS Flow
To run the complete automated flow from RTL elaboration down to GDSII:
```bash
bash scripts/run_flow.sh
```

### 2. Standalone Logic Synthesis (Yosys)
To synthesize the RTL into a gate-level netlist mapped to SkyWater 130nm standard cells:
```bash
yosys -s scripts/synth_yosys.tcl
```
Outputs generated in `results/synthesis/`:
- `titan_x_soc_gl.v`: Gate-level Verilog netlist
- `area.rpt`: Detailed standard cell instance counts and area breakdown

### 3. OpenLane Automated Physical Implementation
To execute the Docker-based OpenLane flow (Floorplan, PDN, Placement, CTS, Routing, Extraction, and GDS generation):
```bash
bash scripts/run_openlane.sh
```

### 4. Standalone Signoff DRC (Magic / KLayout)
```bash
bash scripts/run_drc.sh
```

### 5. Standalone Signoff LVS (Netgen)
```bash
bash scripts/run_lvs.sh
```

---

## Physical Design Signoff Criteria
| Metric | Signoff Threshold | Target Status |
| :--- | :--- | :--- |
| **Target Frequency** | 100 MHz (10.0 ns clock period) | Met |
| **Worst Negative Slack (WNS)** | $\ge 0.00\text{ ns}$ | Clean (Zero Setup Violations) |
| **Total Negative Slack (TNS)** | $= 0.00\text{ ns}$ | Clean |
| **Worst Hold Slack (WHS)** | $\ge 0.00\text{ ns}$ | Clean (Zero Hold Violations) |
| **Clock Skew** | $< 150\text{ ps}$ across all registers | Signoff Met |
| **Core Utilization** | $45.0\%$ to $50.0\%$ | Optimal Routability |
| **Magic DRC Violations** | $0$ Errors | Tapeout Clean |
| **Netgen LVS Matching** | $100\%$ Nets & Instances Matched | Tapeout Clean |
