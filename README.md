# Xiaomi Mi 10T / 10T Pro (apollo) kernel for LineageOS 24 — BakaSU + SUSFS + NoMount + Baseband-guard

Kernel 4.19.325 for `apollo` (SM8250), based on the official
[LineageOS/android_kernel_xiaomi_sm8250](https://github.com/LineageOS/android_kernel_xiaomi_sm8250)
branch `lineage-24.0` (base commit `6b34d2476`), with:

| Component | Version | Notes |
|-----------|---------|-------|
| [BakaSU](https://github.com/Baka-SU/BakaSU) | `v4.2.0-rc3-99ff0a27` | git submodule in `KernelSU/`, linked as `drivers/kernelsu`. 2026-11-28 update fixes a regression where a failed SELinux policy-metadata snapshot made `selinux_hide` hard-abort instead of falling back to the backup lookup path. 2026-11-23 update: new `selinux_hide/` subsystem layout, `inode_setxattr` LSM hook, new `CONFIG_KSU_SUSFS_PRIORITY_UID_FILTER` option (default y) — all self-contained inside the submodule, no manual integration needed. |
| [SUSFS](https://gitlab.com/simonpunk/susfs4ksu) | v2.4.0 (patched 2026-11-27) | 4.19 patch + inline hooks from [JackA1ltman/NonGKI_Kernel_Build_2nd](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd). Five hunks (`fs/namespace.c`, `fs/super.c`, `fs/proc/task_mmu.c`, `fs/Makefile`, `mm/memory.c`) were ported by hand because `lineage-24.0` has the newer `fs_context` mount code; updates to the patch were merged back onto the hand-ported files with a 3-way merge against a pristine `lineage-24.0` checkout. 2026-11-28 update carried in two more upstream fixes: a missing NULL check before `kfree_rcu()`, and a SUS_PATH fix for `CONFIG_SDCARD_FS=y` (our kernel has it on) where the flag set on an sdcardfs inode was never visible through the per-app sdcardfs view — the lower inode is now flagged too. 2026-11-23 update carried in upstream bug fixes (SUS_PATH detection in `fs/readdir.c`, `kernel_read()` new/old signature auto-detection added to `fs/Makefile`, `kvmalloc` fix) without a version bump. |
| [NoMount](https://github.com/maxsteeel/nomount) | `dev` @ `87b0596` | copied into `fs/nomount/`, `CONFIG_NOMOUNT=y`. 2026-11-28 update: stale-backing-inode handling, rule rebinding when the backing file was replaced (not unlinked), cross-superblock lookup proxying, and a cached-file-handle correctness fix. 2026-11-23 update added a custom key-type registration, so `fs/nomount/Kconfig` has `select KEYS`. |
| [Baseband-guard](https://github.com/vc-teahouse/Baseband-guard) | `48d9fde` | git submodule in `security/baseband-guard`. `CONFIG_BBG=y`, `BLOCK_BOOT`/`BLOCK_RECOVERY` left off: protects the baseband/modem and other non-OTA partitions, while boot/recovery/dtbo stay flashable from a booted system. 2026-11-28 update only adds kernel 6.15+/6.19+ compatibility guards; no functional change for 4.19. |

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
