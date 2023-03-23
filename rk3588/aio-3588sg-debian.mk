CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

DEVICE_NAME=$(echo ${CMD} | awk -F '/' '{print $NF}')
DEVICE_NAME=${DEVICE_NAME%\-*}
source $CUR_DIR/${DEVICE_NAME}-ubuntu.mk

# rootfs_system
export RK_ROOTFS_SYSTEM=debian

export RK_ROOTFS_IMG=debian/rootfs.img
