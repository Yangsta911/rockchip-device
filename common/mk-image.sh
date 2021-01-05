#!/bin/bash

COMMON_DIR=$(cd `dirname $0`; pwd)
if [ -h $0 ]
then
        CMD=$(readlink $0)
        COMMON_DIR=$(dirname $CMD)
fi
cd $COMMON_DIR
cd ../../..
TOP_DIR=$(pwd)

source $TOP_DIR/device/rockchip/.BoardConfig.mk

# Require buildroot host tools to do image packing.
if [ ! -d "$TARGET_OUTPUT_DIR" ]; then
    echo "Source buildroot/build/envsetup.sh"
    source $TOP_DIR/buildroot/build/envsetup.sh $RK_CFG_BUILDROOT
fi

# Prefer using buildroot host tools for compatible.
HOST_DIR=$TARGET_OUTPUT_DIR/host
export PATH=$HOST_DIR/usr/sbin:$HOST_DIR/usr/bin:$HOST_DIR/sbin:$HOST_DIR/bin:$PATH

fatal()
{
    echo -e "FATAL: " $@
    exit 1
}

usage()
{
    fatal "Usage: $0 <src_dir> <target_image> <fs_type> [size]"
}

[ ! $# -lt 3 ] || usage

export SRC_DIR=$1
export TARGET=$2
FS_TYPE=$3
SIZE=$4

if [ "$FS_TYPE" = "ubi" ]; then
    UBI_VOL_NAME=${5:-test}
    # default page size 2KB
    UBI_PAGE_SIZE=${6:-2048}
    # default block size 128KB
    UBI_BLOCK_SIZE=${7:-0x20000}
fi

TEMP=$(mktemp -u)

[ -d "$SRC_DIR" ] || usage

copy_to_ntfs()
{
    DEPTH=1
    while true;do
        find $SRC_DIR -maxdepth $DEPTH -mindepth $DEPTH -type d|grep -q "" \
            || break
        find $SRC_DIR -maxdepth $DEPTH -mindepth $DEPTH -type d \
            -exec sh -c 'ntfscp $TARGET "$1" "${1#$SRC_DIR}"' sh {} \; || \
                fatal "Please update buildroot to: \n83c061e7c9 rockchip: Select host-ntfs-3g"
        DEPTH=$(($DEPTH + 1))
    done

    find $SRC_DIR -type f \
        -exec sh -c 'ntfscp $TARGET "$1" "${1#$SRC_DIR}"' sh {} \; || \
            fatal "Failed to do ntfscp!"
}

copy_to_image()
{
    ls $SRC_DIR/* &>/dev/null || return 0

    echo "Copying $SRC_DIR into $TARGET (root permission required)"
    mkdir -p $TEMP || return -1
    sudo mount $TARGET $TEMP || return -1

    cp -rp $SRC_DIR/* $TEMP
    RET=$?

    sudo umount $TEMP
    rm -rf $TEMP

    return $RET
}

check_host_tool()
{
    which $1|grep -q "^$TARGET_OUTPUT_DIR"
}

mkimage()
{
    echo "Making $TARGET from $SRC_DIR with size(${SIZE}M)"
    rm -rf $TARGET
    dd of=$TARGET bs=1M seek=$SIZE count=0 2>&1 || fatal "Failed to dd image!"
    case $FS_TYPE in
        ext[234])
            if mke2fs -h 2>&1 | grep -wq "\-d"; then
                mke2fs -t $FS_TYPE $TARGET -d $SRC_DIR || return -1
            else
                echo "Detected old mke2fs(doesn't support '-d' option)!"
                mke2fs -t $FS_TYPE $TARGET || return -1
                copy_to_image || return -1
            fi
            # Set max-mount-counts to 0, and disable the time-dependent checking.
            tune2fs -c 0 -i 0 $TARGET
            ;;
        msdos|fat|vfat)
            # Use fat32 by default
            mkfs.vfat -F 32 $TARGET && \
			MTOOLS_SKIP_CHECK=1 \
			mcopy -bspmn -D s -i $TARGET $SRC_DIR/* ::/
            ;;
        ntfs)
            # Enable compression
            mkntfs -FCQ $TARGET
            if check_host_tool ntfscp; then
                copy_to_ntfs
            else
                copy_to_image
            fi
            ;;
    esac
}

mkimage_auto_sized()
{
    tar cf $TEMP $SRC_DIR &>/dev/null
    SIZE=$(du -m $TEMP|grep -o "^[0-9]*")
    rm -rf $TEMP
    echo "Making $TARGET from $SRC_DIR (auto sized)"

    MAX_RETRY=10
    RETRY=0

    while true;do
        EXTRA_SIZE=$(($SIZE / 50))
        SIZE=$(($SIZE + ($EXTRA_SIZE > 4 ? $EXTRA_SIZE : 4)))
        mkimage && break

        RETRY=$[RETRY+1]
        [ $RETRY -gt $MAX_RETRY ] && fatal "Failed to make image!"
        echo "Retring with increased size....($RETRY/$MAX_RETRY)"
    done
}

mk_ubi_image()
{
    temp_dir="`dirname $TARGET`"
    temp_ubifs_image=$temp_dir/temp.ubifs
    temp_ubinize_file=$temp_dir/ubinize.cfg
    ubifs_lebsize=$(( $UBI_BLOCK_SIZE - 2 * $UBI_PAGE_SIZE ))
    ubifs_miniosize=$UBI_PAGE_SIZE
    partition_size=$(( $SIZE ))

    if [ $partition_size -le 0 ]; then
        echo "Error: ubifs partition MUST set partition size"
        exit 1
    fi
    ubifs_maxlebcnt=$(( $partition_size / $ubifs_lebsize ))

    echo "ubifs_lebsize=$UBI_BLOCK_SIZE"
    echo "ubifs_miniosize=$UBI_PAGE_SIZE"
    echo "ubifs_maxlebcnt=$ubifs_maxlebcnt"
    mkfs.ubifs -x lzo -e $ubifs_lebsize -m $ubifs_miniosize -c $ubifs_maxlebcnt -d $SRC_DIR -F -v -o $temp_ubifs_image

    echo "[ubifs]" > $temp_ubinize_file
    echo "mode=ubi" >> $temp_ubinize_file
    echo "vol_id=0" >> $temp_ubinize_file
    echo "vol_type=dynamic" >> $temp_ubinize_file
    echo "vol_name=$UBI_VOL_NAME" >> $temp_ubinize_file
    echo "vol_alignment=1" >> $temp_ubinize_file
    echo "vol_flags=autoresize" >> $temp_ubinize_file
    echo "image=$temp_ubifs_image" >> $temp_ubinize_file
    ubinize -o $TARGET -m $ubifs_miniosize -p $UBI_BLOCK_SIZE -v $temp_ubinize_file
    rm -f $temp_ubifs_image $temp_ubinize_file
}

rm -rf $TARGET
case $FS_TYPE in
    squashfs)
        mksquashfs $SRC_DIR $TARGET -noappend -comp lz4
        ;;
    ext[234]|msdos|fat|vfat|ntfs)
        if [ ! "$SIZE" ]; then
            mkimage_auto_sized
        else
            mkimage && echo "Generated $TARGET"
        fi
        ;;
    ubi)
        mk_ubi_image
        ;;
    *)
        echo "File system: $FS_TYPE not support."
        usage
        ;;
esac
