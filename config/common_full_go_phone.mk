#
# Android Go phone variant.
# SPDX-License-Identifier: Apache-2.0
#
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)
$(call inherit-product, vendor/lineage/config/telephony.mk)

PRODUCT_TYPE ?= go
