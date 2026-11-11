# android_vendor_yugen_compat — the `vendor/lineage` compatibility shim

Syncs to `vendor/lineage`. It exists so an **unmodified LineageOS device tree**
builds on Yugen's stock AOSP platform.

A LineageOS phone tree ends with:

```make
# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_sweet
```

Yugen does not ship LineageOS's vendor tree, so that path would be a hard build
error. This repository occupies it and forwards the call:

```
vendor/lineage/config/common_full_phone.mk
  └── common_mobile_full.mk
        └── common_mobile.mk
              └── common.mk  ──►  vendor/yugen/config/common.mk
```

Every other `config/*.mk` a device tree might inherit (`common_mini_phone`,
`common_full_tablet`, `common_tv`, `tablet`, `data_only`, …) is present as a
thin forwarder for the same reason.

## Rules

1. **Plumbing only.** No apps, prebuilts, audio packs, or platform code.
2. **One job per file.** Forward to `vendor/yugen`; do not add behaviour here.
3. **Never stub a missing package.** If a device tree asks for a Lineage app
   (`Aperture`, `Etar`, …), that is a porting decision for `snippets/devices.xml`
   or a device-specific repo. Adding a fake package name only moves the failure
   to `ninja`.

## Board config files

`BoardConfigLineage.mk`, `BoardConfigKernel.mk`, and `BoardConfigSoong.mk` are
empty on purpose: Yugen uses stock AOSP board defaults. `BoardConfigReservedSize.mk`
is the exception — it is copied verbatim because partition reserved sizes affect
whether a device with GApps fits.

Note that stock AOSP's `build/make/core/board_config.mk` never includes
`vendor/lineage/config/BoardConfigLineage.mk`; only LineageOS's `build/make`
fork has that hook. Device trees do not include it either, so these files are
inert here. Do not move required board variables into them.

## Kernel headers

Several device trees and HALs ask for kernel headers by module name:

| Module | LineageOS defines it in |
|---|---|
| `generated_kernel_headers` | `vendor/lineage/build/soong/Android.bp` |
| `prebuilt_kernel_headers` | same |
| `generated_kernel_header_defaults` | same, also inherited by `hardware/qcom-caf/common` |
| `prebuilt_kernel_header_defaults` | same |

`device_kernel_headers` is not in that list: AOSP has defined it in
`build/soong/Android.bp` since it became a `kernel_headers` module, so it
already exists on a stock platform and is left alone. It re-exports whatever
`TARGET_DEVICE_KERNEL_HEADERS`, `TARGET_BOARD_KERNEL_HEADERS` and
`TARGET_PRODUCT_KERNEL_HEADERS` point at.

LineageOS's versions run `make headers_install` on `TARGET_KERNEL_SOURCE`
through a `lineage_generator` Soong plugin. That plugin reads kernel variables
out of Soong, and stock AOSP's board configuration has no hook to export them —
LineageOS added one to `build/make`. Porting it would mean forking the build
system, which Yugen does not do.

`Android.bp` therefore defines them as plain header libraries exposing:

- AOSP's snapshotted kernel UAPI headers, via `libc_headers`. This covers
  `<linux/*.h>`, `<sound/*.h>`, `<asm/*.h>` — enough for `hardware/mediatek`'s
  `PowerOffAlarm`, its boot HAL, and most `device_kernel_headers` users.
- `kernel-headers/include/`, empty in git, for headers AOSP does not carry:
  `<display/drm/sde_drm.h>` for Qualcomm UDFPS, `<linux/msm_audio.h>` and the
  techpack `sound/` headers for QTI/MediaTek audio.

Fill the drop-in directory from a synced kernel tree:

```bash
vendor/lineage/tools/link-kernel-headers.sh kernel/xiaomi/mt6785 arm64
```

It symlinks `include/uapi/*`, `arch/<arch>/include/uapi/asm` and
`techpack/audio/include/uapi/*` (when present). The links are gitignored. If a
HAL then trips over a private kernel header, run a real
`make headers_install` and copy its `usr/include` in instead; the script says
how.

Two limits worth knowing: `TARGET_{DEVICE,BOARD,PRODUCT}_KERNEL_HEADERS` are
not consulted (AOSP's `kernel_headers` module type is not used here), and the
headers are the kernel's checked-in UAPI, not `headers_install`'s pruned copy.

## Known gaps

These are real and belong to the device bring-up, not to this shim:

- `overlay-lineage/lineage-sdk/...` overlays in device trees target
  `org.lineageos.platform`, which Yugen does not ship. They compile but never
  apply.
- Anything that calls into the Lineage SDK at runtime needs an AOSP-compatible
  replacement.
- `device/qcom/sepolicy_vndr` is per-SoC and is not declared globally; add it to
  the manifest when you add a device.
- MediaTek trees inherit `hardware/lineage/compat/frameworks/compat.mk` and
  reference `hardware/mediatek`, `hardware/xiaomi` and
  `device/mediatek/sepolicy_vndr`. Those are all in the hardware layer or in
  the device block of `snippets/devices.xml`, not here.
- Six Qualcomm display HALs use `export_cflags`, which only LineageOS's
  `build/soong` understands, so they are `notdefault` in the manifest. Yugen
  keeps AOSP Soong; see the manifest README for the three ways out.
- Kernel headers come from AOSP's UAPI snapshot plus whatever
  `tools/link-kernel-headers.sh` links in, not from a per-device
  `headers_install` run. See [Kernel headers](#kernel-headers).

Licensed Apache-2.0. `BoardConfigReservedSize.mk` keeps its LineageOS
copyright notice.
