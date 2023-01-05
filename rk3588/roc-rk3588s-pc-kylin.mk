CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

DEVICE_NAME=$(echo ${CMD} | awk -F '/' '{print $NF}')
DEVICE_NAME=${DEVICE_NAME%\-*}
source $CUR_DIR/${DEVICE_NAME}-ubuntu.mk

# parameter for GPT table
export RK_PARAMETER=parameter-kylin.txt
