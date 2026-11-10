#
# vendor/lineage — compatibility shim for Project Yugen.
# SPDX-License-Identifier: Apache-2.0
#
# Unmodified LineageOS device trees call
#
#     $(call inherit-product, vendor/lineage/config/common_full_phone.mk)
#
# Yugen runs the stock AOSP platform, so it does not ship LineageOS's
# vendor/lineage tree. This repository occupies that path and forwards every
# inherit call to vendor/yugen.
#
# Rules for this tree:
#   * Only product plumbing. No apps, no prebuilts, no platform code.
#   * Every file here must be a thin forwarder to vendor/yugen.
#   * If a device tree wants a Lineage package that AOSP does not provide,
#     that is a porting task. Do not stub the package name to make it link.
#

ifndef YUGEN_COMPAT_COMMON_MK
YUGEN_COMPAT_COMMON_MK := true

$(call inherit-product, vendor/yugen/config/common.mk)

# Lineage sets these before device makefiles run, and device trees branch on
# them. Keep the same defaults for phones so those branches stay valid.
PRODUCT_SIZE ?= full
PRODUCT_TYPE ?= phone

endif # YUGEN_COMPAT_COMMON_MK
