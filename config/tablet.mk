#
# Tablet common configuration. AOSP owns large-screen behaviour; this only
# keeps the inherit call valid for tablet device trees.
# SPDX-License-Identifier: Apache-2.0
#
$(call inherit-product, $(SRC_TARGET_DIR)/product/large_screen_common.mk)
