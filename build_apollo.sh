#!/usr/bin/env bash
# Build the apollo kernel (LineageOS 24.0 base + BakaSU + SUSFS + NoMount).
# Usage: ./build_apollo.sh   (needs clang/lld, flex, bison, bc, zip, git)
set -euo pipefail
cd "$(dirname "$0")"

git submodule update --init KernelSU          # BakaSU pinned to the tested commit
[ -L drivers/kernelsu ] || ln -sfn ../KernelSU/kernel drivers/kernelsu

MK="ARCH=arm64 O=out LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CLANG_TRIPLE=aarch64-linux-gnu-"
C=arch/arm64/configs/vendor

mkdir -p out
make $MK vendor/kona-perf_defconfig
ARCH=arm64 scripts/kconfig/merge_config.sh -m -O out out/.config \
    $C/debugfs.config $C/xiaomi/sm8250-common.config $C/xiaomi/apollo.config \
    $C/xiaomi/apollo-bakasu.config
make $MK olddefconfig
make $MK -j"$(nproc)"

echo "Kernel image: out/arch/arm64/boot/Image"
echo "Package it with AnyKernel3 (https://github.com/liyafe1997/AnyKernel3, branch 'kona'):"
echo "  copy Image to kernels/Image and zip the folder."
