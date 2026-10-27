#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Master Push-Button RTL-to-GDS Execution Flow for SMVDU TITAN-X SoC

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

cd "${REPO_ROOT}"

echo "=========================================================="
echo " SMVDU TITAN-X SoC: Complete Push-Button RTL-to-GDS Flow"
echo " Target PDK: SkyWater 130nm (sky130A)"
echo " Cell Lib  : sky130_fd_sc_hd"
echo "=========================================================="

echo "[Stage 1/5] Running Standard Cell Logic Synthesis (Yosys)..."
yosys -s scripts/synth_yosys.tcl

echo "[Stage 2/5] Running Automated Physical Implementation (Floorplan -> GDS)..."
if command -v docker >/dev/null 2>&1; then
    bash scripts/run_openlane.sh
else
    echo "  [ERROR] Docker engine required to invoke OpenLane flow."
    exit 1
fi

echo "[Stage 3/5] Running Signoff DRC..."
bash scripts/run_drc.sh

echo "[Stage 4/5] Running Signoff LVS..."
bash scripts/run_lvs.sh

echo "=========================================================="
echo " *** RTL-TO-GDS FLOW PIPELINE COMPLETED SUCCESSFULLY ***"
echo " Deliverables located in results/"
echo "=========================================================="
