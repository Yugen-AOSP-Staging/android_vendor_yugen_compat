#
# Partition reserved-size defaults.
# SPDX-FileCopyrightText: 2023-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Copied from LineageOS's vendor/lineage. Device trees include this with
# -include, so its absence would silently shrink the product and system_ext
# partitions and make GApps installs fail on retrofit devices. Keeping the
# values identical to Lineage's means a device that builds there has the same
# partition headroom here.
#

ifeq ($(PRODUCT_VIRTUAL_AB_OTA),true)
    BOARD_PRODUCTIMAGE_MINIMAL_PARTITION_RESERVED_SIZE ?= true
endif

ifeq (,$(filter true, $(WITHOUT_RESERVED_SIZE) $(WITH_GMS)))
    BOARD_PRODUCTIMAGE_EXTFS_INODE_COUNT ?= -1

    ifeq ($(BOARD_PRODUCTIMAGE_MINIMAL_PARTITION_RESERVED_SIZE),true)
        ifeq ($(PRODUCT_IS_ATV),true)
            BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE ?= 465000000
        else
            BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE ?= 1188036608
        endif
    else
        ifeq ($(PRODUCT_IS_ATV),true)
            BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE ?= 485000000
        else
            BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE ?= 1957691392
        endif
    endif

    BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT ?= -1
    ifeq ($(PRODUCT_IS_ATV),true)
        BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE ?= 40000000
        BOARD_SYSTEM_EXTIMAGE_PARTITION_RESERVED_SIZE ?= 27000000
    else
        BOARD_SYSTEM_EXTIMAGE_EXTFS_INODE_COUNT ?= -1
        BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE ?= 94371840
        BOARD_SYSTEM_EXTIMAGE_PARTITION_RESERVED_SIZE ?= 94371840
    endif
endif
