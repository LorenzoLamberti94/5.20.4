# syntax=docker/dockerfile:1.7

############################
# Base runtime/dev image
############################
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

# System deps (dev-friendly; you can trim later)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
      git openssh-client ca-certificates \
      build-essential make cmake ninja-build pkg-config \
      python3 python3-pip python3-dev python3-venv python-is-python3 \
      rsync curl wget unzip file \
      device-tree-compiler \
      libusb-1.0-0-dev \
      # very common extras needed by GVSoC / cmake_sdk.build
      flex bison \
      libffi-dev libelf-dev zlib1g-dev \
      libglib2.0-dev \
      libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# Toolchain (kept in base so both dev + full images have it)
COPY --link gap_riscv_toolchain_ubuntu /opt/gap_riscv_toolchain
RUN test -x /opt/gap_riscv_toolchain/bin/riscv32-unknown-elf-gcc

ARG GAP_SDK_VERSION=5.20.4
ENV GAP_SDK_VERSION=${GAP_SDK_VERSION}
ENV GAP_SDK_HOME=/opt/gap_sdk_private
ENV PATH=/opt/gap_riscv_toolchain/bin:$PATH
ENV GAP_RISCV_GCC_TOOLCHAIN=/opt/gap_riscv_toolchain
ENV CHIP_FAMILY=9
ENV CHIP_VERSION=2
ENV TARGET_CHIP_FAMILY=GAP9
ENV TARGET_CHIP=GAP9_V2
ENV TARGET_NAME=gap9_v2
ENV BOARD_NAME=gap9_v2
ENV GVSOC_TARGETS="gap9.evk gap9.gap9_v2"

WORKDIR /work

# Nice shell defaults
RUN echo 'export GAP_SDK_HOME=/opt/gap_sdk_private' >> /root/.bashrc && \
    echo 'export PATH=/opt/gap_riscv_toolchain/bin:$PATH' >> /root/.bashrc && \
    echo 'alias gapenv="source /opt/gap_sdk_private/sourceme.sh"' >> /root/.bashrc


############################
# Python deps layer (cache-friendly)
############################
FROM base AS pydeps

# Only copy requirements to maximize cache reuse
COPY --link gap_sdk_private/requirements.txt /tmp/gap-sdk-requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install \
      -r /tmp/gap-sdk-requirements.txt \
      kconfiglib xxhash rich lz4 pandas matplotlib pytablewriter marko


############################
# SDK source layer (dev image)
# - DOES NOT build the full SDK (fast image builds)
############################
FROM pydeps AS dev

# Copy sources late so previous layers stay cached
COPY --link gap_sdk_private /opt/gap_sdk_private

# Optional: pre-seed boot binaries IF they exist in your build context
# (comment these out if they cause cache invalidations or aren't needed)
# COPY --link gap_sdk_private/install/target/bin/fsbl /opt/gap_sdk_private/install/target/bin/fsbl
# COPY --link gap_sdk_private/install/target/bin/ssbl /opt/gap_sdk_private/install/target/bin/ssbl

CMD ["bash"]


############################
# Optional full build stage
# Build with:
#   docker build --target full --build-arg BUILD_SDK=1 -t gap-sdk:full .
############################
FROM dev AS full

ARG BUILD_SDK=0

# Cache CMake/Ninja build outputs to speed up rebuilds
# (If the SDK uses a different build dir, adjust the cache target accordingly)
RUN --mount=type=cache,target=/opt/gap_sdk_private/build \
    if [ "$BUILD_SDK" = "1" ]; then \
      set -euxo pipefail; \
      cd /opt/gap_sdk_private; \
      make cmake_sdk.build || { \
        echo "=== CMakeError.log ==="; \
        find . -path "*CMakeFiles/CMakeError.log" -print -exec sed -n '1,200p' {} \; || true; \
        echo "=== CMakeOutput.log ==="; \
        find . -path "*CMakeFiles/CMakeOutput.log" -print -exec sed -n '1,200p' {} \; || true; \
        exit 1; \
      }; \
    else \
      echo "Skipping SDK full build (set --build-arg BUILD_SDK=1 to enable)"; \
    fi

CMD ["bash"]
