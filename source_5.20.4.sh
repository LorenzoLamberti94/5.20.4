# 5.20.4
conda activate gap_sdk_5.20.4
export GAP_RISCV_GCC_TOOLCHAIN="/home/lamberti/gap/5.20.4/gap_riscv_toolchain_ubuntu/install/"
source /home/lamberti/gap/5.20.4/gap_sdk_private/configs/gap9_evk_audio.sh
# export GAPY_OPENOCD_CABLE=$HOME/gap/5.20.4/gap_sdk_private/utils/openocd/tcl/interface/ftdi/olimex-arm-usb-ocd-h.cfg

#### how to run an app
# # Init cmake build directory, named "build"
# cmake -B build
# # Configure the application, using build directory "build"
# # --> here you may choose the plaform (board or gvsoc)
# cmake --build build --target menuconfig
# # Run the target
# cmake --build build --target run
