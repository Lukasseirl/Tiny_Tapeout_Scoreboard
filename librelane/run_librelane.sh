
'''
#!/usr/bin/env bash

# =====================================================
# Author: Simon Dorrer
# Last Modified: 02.10.2025
# Description: This .sh file switches to the SKY130 PDK, runs the LibreLane flow and opens the layout in the OpenROAD GUI.
# =====================================================

set -e -x

cd $(dirname "$0")

# Switch to sky130A PDK
source sak-pdk-script.sh sky130A sky130_fd_sc_hd > /dev/null

# Set verbose logging
export OPENLANE_VERBOSE=1
export DEBUG=1
export SYNTH_VERBOSE=1

echo "Running LibreLane with verbose logging..."

# Run LibreLane with detailed output
librelane --manual-pdk config.json 2>&1 | tee librelane_detailed.log

# Check if successful
if [ $? -eq 0 ]; then
    echo "LibreLane completed successfully"
    # Open Layout in OpenROAD GUI
    librelane --manual-pdk config.json --last-run --flow OpenInOpenROAD
else
    echo "LibreLane failed. Check librelane_detailed.log for errors"
    # Show last errors from log
    echo "=== LAST ERRORS ==="
    tail -50 librelane_detailed.log | grep -i "error\|fail"
fi



'''
#!/usr/bin/env bash

# =====================================================
# Author: Simon Dorrer
# Last Modified: 02.10.2025
# Description: This .sh file switches to the SKY130 PDK, runs the LibreLane flow and opens the layout in the OpenROAD GUI.
# =====================================================

set -e -x

cd $(dirname "$0")

# Switch to sky130A PDK
source sak-pdk-script.sh sky130A sky130_fd_sc_hd > /dev/null

# Run LibreLane
librelane --manual-pdk config.json

# Open Layout in OpenROAD GUI
librelane --manual-pdk config.json --last-run --flow OpenInOpenROAD

