#!/bin/bash

set -uexo pipefail

CONFIG="$1"
DEVICE_TREE="$2"
HEADER_VERSION="${3:-}"

cd ..

make $CONFIG

make -j $(nproc)
gzip u-boot-nodtb.bin -c > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/$DEVICE_TREE.dtb > u-boot-dtb

MKBOOTIMG_ARGS="--kernel u-boot-dtb --pagesize 4096 --base 0x0 --kernel_offset 0x8000 -o u-boot.img"
if [ -n "$HEADER_VERSION" ]; then
    MKBOOTIMG_ARGS="$MKBOOTIMG_ARGS --header_version $HEADER_VERSION"
fi
mkbootimg $MKBOOTIMG_ARGS
mkdir -p builder/output/
cp u-boot.img builder/output/u-boot.img
