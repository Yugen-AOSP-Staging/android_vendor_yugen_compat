#
# The file almost every LineageOS phone tree inherits. Keeping this path
# working is the entire reason this repository exists.
# SPDX-License-Identifier: Apache-2.0
#
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)
$(call inherit-product, vendor/lineage/config/telephony.mk)
