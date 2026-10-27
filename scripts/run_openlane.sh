#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# OpenLane Docker Flow Runner for TITAN-X SoC
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

PDK_ROOT=/home/anupam-sarashwat/.ciel
OPENLANE_IMAGE="ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69"

echo "=========================================================="
echo " SMVDU TITAN-X SoC: OpenLane RTL-to-GDS Automated Flow"
echo " PDK Root: ${PDK_ROOT}"
echo " Design  : openlane/titan_x_soc"
echo "=========================================================="

# Execute OpenLane flow inside verified Docker container
docker run --rm \
    -v ${PDK_ROOT}:${PDK_ROOT} \
    -v ${REPO_ROOT}:/work \
    -e PDK_ROOT=${PDK_ROOT} \
    -e PDK=sky130A \
    -e STD_CELL_LIBRARY=sky130_fd_sc_hd \
    -u $(id -u):$(id -g) \
    ${OPENLANE_IMAGE} \
    /openlane/flow.tcl -design /work/openlane/titan_x_soc -tag titan_x_run
