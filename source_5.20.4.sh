# 5.20.4
export GAP_SDK_BASE="$HOME/gap"
export GAP_SDK_VERSION="5.20.4"
export SDK_DIR="$GAP_SDK_BASE/$GAP_SDK_VERSION/"

# Activate conda environment
conda activate "gap_sdk_$SDK_VERSION"
#conda activate gap_sdk_5.20.4

# RISC-V toolchain
export GAP_RISCV_GCC_TOOLCHAIN="$SDK_DIR/gap_riscv_toolchain_ubuntu/install/"

# Source GAP SDK
source "$SDK_DIR/gap_sdk_private/sourceme.sh"

# Use Olimex (GAP9Shield)
# export GAPY_OPENOCD_CABLE=$SDK_DIR/gap_sdk_private/utils/openocd/tcl/interface/ftdi/olimex-arm-usb-ocd-h.cfg

# Use FTDI (GAP EVK)
# export GAPY_OPENOCD_CABLE=$SDK_DIR/gap_sdk_private/utils/openocd_tools/tcl/gapuino_ftdi.cfg

#### how to run an app
# # Init cmake build directory, named "build"
# cmake -B build
# # Configure the application, using build directory "build"
# # --> here you may choose the plaform (board or gvsoc)
# cmake --build build --target menuconfig
# # Run the target
# cmake --build build --target run
