#!/bin/bash
#
# 脚本通过sdk/device/rockchip/.BoardConfig.mk来确定固件名称
#，请打包前确认.BoardConfig.mk链接正确
#

usage()
{
	echo "Usage: ./version imgname "
	echo "Usage: ./version 固件名 "
	exit -1
}

function init_firmware_info()
{
	if [ ! -d "pack" ];then
		mkdir pack
	fi

	day=$(echo $1 | awk -F '-' '{print $(NF-1)}')
	time=$(echo $1 | awk -F '-' '{print $(NF)}'| awk -F '.' '{print $1}')
	board=${1%-*}
	board=${board%-*}

	rockdev=$(pwd)

	kernel_dir=$(pwd)/../kernel
	uboot_dir=$(pwd)/../u-boot
	cd $kernel_dir
	kernel_commit=$(git log -1 | grep "commit" | awk -F ' ' '{print $2}')
	cd $uboot_dir
	uboot_commit=$(git log -1 | grep "commit" | awk -F ' ' '{print $2}')
	cd $rockdev

	if [ ! -f "commit/$board" ];then
		echo >  commit/${board}
	fi

	if [ $2 == "-n" ];then
		cp  tmp.txt ttmp.txt
		cat commit/${board} >> ttmp.txt
		cp ttmp.txt commit/${board}
		rm -rf ttmp.txt
		sed -i "1s/^/$1\n/" commit/${board}
		sed -i "2s/^/date: ${day-$time}\n/" commit/${board}
		sed -i "3s/^/kernel: ${kernel_commit}\n/" commit/${board}
		sed -i "4s/^/uboot:  ${uboot_commit}\n/" commit/${board}
		sed -i "5s/^/description: \n/" commit/${board}
	else
	
		sed -i "1s/^/$1\n/" commit/${board}
		sed -i "2s/^/date: ${day-$time}\n/" commit/${board}
		sed -i "3s/^/kernel: ${kernel_commit}\n/" commit/${board}
		sed -i "4s/^/uboot:  ${uboot_commit}\n/" commit/${board}
		sed -i "5s/^/description: \n\n\n/" commit/${board}
		vim commit/${board} +star +6
	
	fi
}

function package_firmware()
{
	toolsdir=$(pwd)/../tools
	mode=$(ls ./pack/$1 | grep "SDBOOT")

	if [ ! -n "$mode" ];then
		PACK_IMG="$1.7z pack/$1 pack/AndroidTool.zip pack/Linux_Upgrade_Tool pack/README.txt pack/commit"
	else 
		PACK_IMG="$1.7z pack/$1 pack/README.txt pack/commit"
	fi

	rm -rf  pack/AndroidTool.zip
	rm -rf  pack/Linux_Upgrade_Tool
	cp -r -f  $toolsdir/windows/AndroidTool.zip ./pack/ 
	cp -r -f $toolsdir/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool  ./pack/ 
	cp ../device/rockchip/common/pack/README.txt ./pack/
	cp -r -f ../device/rockchip/common/pack/commit ./pack/ 

	7z a $PACK_IMG
	echo -e "\e[36m $rockdev/$1.7z \e[0m"

}

if [ $# -lt 1 ] ; then 
	usage
fi

if [ -n "$2" ];then
	case $2 in
		init) 
			init_firmware_info  $1 $3;;
		pack)
			package_firmware $1;;
		*) 
			init_firmware_info $1
			package_firmware $1;;
	esac
fi
