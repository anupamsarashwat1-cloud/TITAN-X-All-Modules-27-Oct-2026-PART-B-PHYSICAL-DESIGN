#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Automated Magic & KLayout DRC Runner for SkyWater 130nm

set -e
PDK_ROOT=/home/anupam-sarashwat/.ciel
MAGIC_TECH=${PDK_ROOT}/sky130A/libs.tech/magic/sky130A.tech
OUTPUT_DIR=results/drc
mkdir -p ${OUTPUT_DIR}

echo "=========================================================="
echo " Running Design Rule Check (DRC) on SkyWater 130nm..."
echo " Tech File: ${MAGIC_TECH}"
echo "=========================================================="

if [ -f "results/gds/titan_x_soc.gds" ]; then
    GDS_FILE="results/gds/titan_x_soc.gds"
    magic -dnull -noconsole << MAGIC_EOF > ${OUTPUT_DIR}/magic_drc.log
tech load ${MAGIC_TECH}
gds flatglob *__*
gds read ${GDS_FILE}
load titan_x_top
select top cell
drc catchup
drc count
drc listall why
quit
MAGIC_EOF
    echo "DRC check completed. Report written to ${OUTPUT_DIR}/magic_drc.log"
else
    echo "[INFO] No final GDSII found yet. Run RTL-to-GDS flow first via scripts/run_flow.sh"
fi
