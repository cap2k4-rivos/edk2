#!/bin/bash

set -e 

git submodule update --init --recursive

git clone git@gitlab.ba.rivosinc.com:rv/sw/int/fw/cpu/edk2-platforms.git

export GCC5_RISCV64_PREFIX=riscv64-unknown-linux-gnu-
export WORKSPACE=$(pwd)
export EDK_SOURCES=$(pwd)
export EDK_PLATFORMS=$EDK_SOURCES/edk2-platforms
export EDK_TOOLS=$EDK_SOURCES/BaseTools
export CONF_PATH=$EDK_SOURCES/Conf
export PACKAGES_PATH=$EDK_SOURCES:$EDK_PLATFORMS

python3 -m venv $EDK_SOURCES/.venv
source $EDK_SOURCES/.venv/bin/activate
cat $EDK_SOURCES/.venv/bin/activate
pip install -r $EDK_SOURCES/pip-requirements.txt --upgrade

source $EDK_SOURCES/edksetup.sh

make -C $EDK_SOURCES/BaseTools clean
make -C $EDK_SOURCES/BaseTools
make -C $EDK_SOURCES/BaseTools/Source/C
source $EDK_SOURCES/edksetup.sh BaseTools

# 0x90000000 - -l only takes decimal arguments
FD_BASE=2415919104
python $EDK_SOURCES/UefiPayloadPkg/UniversalPayloadBuild.py -t GCC5 --Fit -a RISCV64 -l $FD_BASE -c Platform/Rivos/RivosPlatformPkg/UefiPayloadPkg.dsc
