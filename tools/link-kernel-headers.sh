#!/bin/bash
#
# Link a synced kernel tree's userspace headers into the drop-in directory that
# vendor/lineage/kernel-headers provides. Needed only by HALs that include
# device kernel headers AOSP does not carry, e.g.:
#
#   <display/drm/sde_drm.h>   Qualcomm UDFPS
#   <linux/msm_audio.h>       QTI audio
#   <sound/...>               MediaTek/QTI techpack audio
#
#   vendor/lineage/tools/link-kernel-headers.sh kernel/xiaomi/mt6785 [arm64]
#
# The headers are symlinked, not copied, so re-syncing the kernel updates them.
# This is an approximation of `make headers_install`: it links the kernel's
# UAPI directories as checked in, without the pruning that kernel's
# headers_install does. If a HAL then trips over a private kernel header,
# generate real headers instead:
#
#   make -C <kernel-dir> O=<out> ARCH=arm64 headers_install
#   cp -a <out>/usr/include/. vendor/lineage/kernel-headers/include/
#
# SPDX-License-Identifier: Apache-2.0
#
set -euo pipefail

top=$(cd "$(dirname "$0")/../../.." && pwd)
kernel=${1:-}
arch=${2:-arm64}

if [ -z "$kernel" ]; then
    echo "usage: ${0##*/} <kernel-source-dir> [arch]" >&2
    exit 2
fi

srcdir=$(cd "$top/$kernel" 2>/dev/null && pwd) || {
    echo "no such directory: $kernel" >&2
    exit 1
}

if [ ! -f "$srcdir/Makefile" ]; then
    echo "$kernel does not look like a kernel tree (no Makefile)" >&2
    exit 1
fi

dest="$top/vendor/lineage/kernel-headers/include"
mkdir -p "$dest"

# Drop links from a previous kernel or arch, keep anything real.
find "$dest" -maxdepth 1 -type l -delete

link_tree() {
    local from=$1 to=$2
    [ -d "$from" ] || return 0
    ln -sfn "$from" "$to"
    echo "  $(basename "$to")"
}

echo "linking UAPI headers from $kernel ($arch):"
for dir in "$srcdir"/include/uapi/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    link_tree "${dir%/}" "$dest/$name"
done

# <asm/*.h>. headers_install flattens this into asm/, so do the same.
link_tree "$srcdir/arch/$arch/include/uapi/asm" "$dest/asm"

# Qualcomm techpack audio ships its UAPI copy out of tree.
for dir in "$srcdir"/techpack/audio/include/uapi/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    [ -e "$dest/$name" ] && continue
    link_tree "${dir%/}" "$dest/$name"
done

echo
echo "done. Rebuild; if a module still misses a header, copy it from the kernel"
echo "tree into kernel-headers/include, or generate the whole tree with"
echo "make headers_install (see the header of this script)."
