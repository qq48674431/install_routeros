#!/bin/bash

# 检查系统启动方式（BIOS/UEFI）
if [ -d /sys/firmware/efi ]; then
    # UEFI 启动
    IMG_URL="https://github.com/Jungle4869/install-routeros-shc/releases/download/Ros7.19.1/chr-7.19.1.img"
    echo "检测到 UEFI 启动方式，使用 UEFI 镜像包"
else
    # BIOS 启动
    IMG_URL="https://github.com/Jungle4869/install-routeros-shc/releases/download/Ros7.19.1/chr-7.19.1-legacy.img"
    echo "检测到 BIOS 启动方式，使用 legacy 镜像包"
fi

# 下载对应的镜像
wget "$IMG_URL" -O /tmp/chr.img

cd /tmp

# 检测磁盘设备
STORAGE=$(lsblk | grep disk | awk '{print $1}' | head -n 1)
echo "STORAGE is $STORAGE"

# 获取默认网卡
ETH=$(ip route show default | sed -n 's/.* dev \([^\ ]*\) .*/\1/p')
echo "ETH is $ETH"

# 获取IP地址
ADDRESS=$(ip addr show "$ETH" | grep global | awk '{print $2}' | head -n 1)
echo "ADDRESS is $ADDRESS"

# 获取网关
GATEWAY=$(ip route list | grep default | awk '{print $3}')
echo "GATEWAY is $GATEWAY"

sleep 5

# 写入镜像到磁盘
dd if=chr.img of=/dev/"$STORAGE" bs=4M oflag=sync

echo "Ok, reboot"
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
