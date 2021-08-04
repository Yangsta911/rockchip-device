#!/bin/bash
OPENWRT_VERSION=$1
OPENWRT_DEFCOFNIG=$2

TOP_DIR=$(pwd)
cd "$TOP_DIR"/openwrt_sdk/"$OPENWRT_VERSION"

./scripts/feeds update -a
./scripts/feeds install -a

if [ ! -f .config ]; then
	cp "$TOP_DIR"/configs/"$OPENWRT_DEFCONFIG" .config
	make defconfig
else
	echo "using .config file"
fi

make download -j$(nproc)
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

make -j$(nproc) V=s
