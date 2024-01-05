#!/bin/bash

# 设定你的SSD设备标识符和挂载点
SSD_DEVICE="/dev/disk2"
MOUNT_POINT="/Volumes/YourSSDMountPoint"

# 尝试卸载设备
if diskutil unmountDisk "$SSD_DEVICE"; then
    echo "SSD已成功卸载。"
    exit 0
else
    echo "无法卸载SSD，可能有程序正在使用它。"
fi

# 列出正在使用SSD的进程
echo "正在查找使用中的文件..."
OPEN_FILES=$(sudo lsof "$MOUNT_POINT")

if [ -n "$OPEN_FILES" ]; then
    echo "以下进程正在使用SSD："
    echo "$OPEN_FILES"
    
    # 提示用户选择
    while true; do
        read -p "是否要强制关闭这些进程? [y/n] " yn
        case $yn in
            [Yy]* )
                echo "正在关闭所有进程..."
                echo "$OPEN_FILES" | awk '{print \$2}' | uniq | tail -n +2 | xargs sudo kill -9
                if diskutil unmountDisk "$SSD_DEVICE"; then
                    echo "SSD已成功卸载。"
                else
                    echo "无法卸载SSD，即使尝试关闭所有进程。"
                fi
                break;;
            [Nn]* )
                echo "请手动关闭这些进程后再尝试卸载SSD。"
                exit 1;;
            * )
                echo "请输入y或n。";;
        esac
    done
else
    echo "没有找到使用中的文件。"
fi
