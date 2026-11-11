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
empty on purpose: Yugen uses stock AOSP board defaults, and LineageOS 24 has no
kernel build step at all. `BoardConfigReservedSize.mk` is the exception — it is
copied verbatim because partition reserved sizes affect whether a device with
GApps fits.

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

Licensed Apache-2.0. `BoardConfigReservedSize.mk` keeps its LineageOS
copyright notice.
