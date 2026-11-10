#
# Book-style foldables. AOSP's large-screen config is pulled in by tablet.mk.
# SPDX-License-Identifier: Apache-2.0
#
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)
$(call inherit-product, vendor/lineage/config/tablet.mk)
$(call inherit-product, vendor/lineage/config/telephony.mk)
