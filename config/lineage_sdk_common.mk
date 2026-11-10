#
# LineageOS SDK is deliberately not shipped.
# SPDX-License-Identifier: Apache-2.0
#
# vendor/lineage/config/common.mk in Lineage includes this to add the
# org.lineageos.platform library and its permissions. Yugen runs the AOSP
# framework, so there is no SDK to include and no Lineage app to consume it.
# Kept as an empty file because third-party device trees inherit it directly.
#
