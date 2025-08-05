#!/bin/bash

# NFS挂载和qBittorrent启动主控制脚本
# 按顺序执行：先挂载NFS，再启动qBittorrent
# 脚本路径：/root/start-nfs-and-qbit.sh

# 定义脚本路径
SCRIPT_DIR="/root"
NFS_SCRIPT="$SCRIPT_DIR/mount-nfs-retry.sh"
QBIT_SCRIPT="$SCRIPT_DIR/start-qbit-after-nfs.sh"

echo "$(date): 开始执行NFS挂载和qBittorrent启动流程..."

# 1. 首先执行NFS挂载脚本
echo "$(date): 步骤1 - 执行NFS挂载脚本..."
if [ -f "$NFS_SCRIPT" ]; then
    bash "$NFS_SCRIPT"
    NFS_EXIT_CODE=$?
    
    if [ $NFS_EXIT_CODE -eq 0 ]; then
        echo "$(date): NFS挂载成功！"
        
        # 2. NFS挂载成功后，执行qBittorrent启动脚本
        echo "$(date): 步骤2 - 执行qBittorrent启动脚本..."
        if [ -f "$QBIT_SCRIPT" ]; then
            bash "$QBIT_SCRIPT"
            QBIT_EXIT_CODE=$?
            
            if [ $QBIT_EXIT_CODE -eq 0 ]; then
                echo "$(date): 所有服务启动成功！"
                exit 0
            else
                echo "$(date): qBittorrent启动失败，退出码: $QBIT_EXIT_CODE"
                exit $QBIT_EXIT_CODE
            fi
        else
            echo "$(date): 错误：找不到qBittorrent启动脚本: $QBIT_SCRIPT"
            exit 1
        fi
    else
        echo "$(date): NFS挂载失败，退出码: $NFS_EXIT_CODE"
        exit $NFS_EXIT_CODE
    fi
else
    echo "$(date): 错误：找不到NFS挂载脚本: $NFS_SCRIPT"
    exit 1
fi 