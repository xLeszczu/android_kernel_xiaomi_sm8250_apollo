# Xiaomi Mi 10T / 10T Pro (apollo) kernel for LineageOS 24 — BakaSU + SUSFS + NoMount

Kernel 4.19.325 for `apollo` (SM8250), based on the official
[LineageOS/android_kernel_xiaomi_sm8250](https://github.com/LineageOS/android_kernel_xiaomi_sm8250)
branch `lineage-24.0` (base commit `6b34d2476`), with:

| Component | Version | Notes |
|-----------|---------|-------|
| [BakaSU](https://github.com/Baka-SU/BakaSU) | `v4.2.0-rc3-5b76b884` | git submodule in `KernelSU/`, linked as `drivers/kernelsu`. Pinned to the last commit before upstream suspended SUSFS builds (10.10.2026). |
| [SUSFS](https://gitlab.com/simonpunk/susfs4ksu) | v2.3.0 | 4.19 patch + inline hooks from [JackA1ltman/NonGKI_Kernel_Build_2nd](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd). Four hunks (`fs/namespace.c`, `fs/super.c`, `fs/proc/task_mmu.c`) were ported by hand because `lineage-24.0` has the newer `fs_context` mount code. |
| [NoMount](https://github.com/maxsteeel/nomount) | `dev` @ `49be79a` | copied into `fs/nomount/`, `CONFIG_NOMOUNT=y`. |

The first commit of this branch is the untouched LineageOS `lineage-24.0` tree; the second commit
contains every change (`git show HEAD`). The SUSFS/NoMount configuration lives in
`arch/arm64/configs/vendor/xiaomi/apollo-bakasu.config`.

## Build

```sh
git clone --recurse-submodules <this repo>
cd android_kernel_xiaomi_sm8250_apollo
./build_apollo.sh
```

Needs clang + lld (the prebuilt release was made with Ubuntu clang 18.1.3), `flex`, `bison`,
`bc`, `git`. The result is `out/arch/arm64/boot/Image`.

## Install

Pack `Image` into an [AnyKernel3](https://github.com/liyafe1997/AnyKernel3) (`kona` branch) zip
as `kernels/Image` and flash it from recovery. It only replaces the kernel image; `dtb` and
`dtbo` stay as they are. **Keep a backup of your working `boot.img`.**

## Status

Boots and runs on the author's device with LineageOS 24 (Android 17). Not tested on other ROMs.
AOSP/LineageOS only — MIUI/HyperOS need a different display driver.

## Licenses

Kernel: GPL-2.0. BakaSU: GPL-2.0 (kernel part) / GPL-3.0. NoMount: GPL-3.0.
