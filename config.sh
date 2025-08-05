#!/bin/bash

# NFS挂载和qBittorrent配置文件
# 用户可以根据自己的环境修改这些配置

# NFS配置
NFS_SERVER=""                      # NFS服务器IP地址（必须由用户输入）
NFS_REMOTE_PATH=""                 # NFS服务器上的路径（必须由用户输入）
MOUNT_POINT="/vol02/media"         # 本地挂载点
CHECK_FOLDER="Movies"              # 验证挂载成功的文件夹

# qBittorrent配置
QBIT_CONTAINER_NAME="qbittorrent"  # qBittorrent容器名称

# 重试配置
RETRY_INTERVAL=10                  # 重试间隔（秒）
MAX_RETRIES=60                    # 最大重试次数（0表示无限重试）

# 日志配置
LOG_FILE="/var/log/mount-nfs-retry.log"  # NFS挂载日志文件

# 服务配置
SERVICE_NAME="nfs-qbit"            # systemd服务名称
INSTALL_DIR="/root/nfs_and_qbit"   # 安装目录

# 验证函数
validate_config() {
    echo "验证配置..."
    
    # 检查NFS服务器地址
    if [[ -z "$NFS_SERVER" ]]; then
        echo "错误: NFS_SERVER 不能为空，请在安装时输入NFS服务器IP地址"
        return 1
    fi
    
    # 检查NFS路径
    if [[ -z "$NFS_REMOTE_PATH" ]]; then
        echo "错误: NFS_REMOTE_PATH 不能为空，请在安装时输入NFS路径"
        return 1
    fi
    
    # 检查挂载点
    if [[ -z "$MOUNT_POINT" ]]; then
        echo "错误: MOUNT_POINT 不能为空"
        return 1
    fi
    
    # 检查验证文件夹
    if [[ -z "$CHECK_FOLDER" ]]; then
        echo "错误: CHECK_FOLDER 不能为空"
        return 1
    fi
    
    # 检查容器名称
    if [[ -z "$QBIT_CONTAINER_NAME" ]]; then
        echo "错误: QBIT_CONTAINER_NAME 不能为空"
        return 1
    fi
    
    echo "配置验证通过"
    return 0
}

# 显示配置
show_config() {
    echo "当前配置:"
    echo "  NFS服务器: $NFS_SERVER"
    echo "  NFS路径: $NFS_REMOTE_PATH"
    echo "  挂载点: $MOUNT_POINT"
    echo "  验证文件夹: $CHECK_FOLDER"
    echo "  qBittorrent容器: $QBIT_CONTAINER_NAME"
    echo "  重试间隔: ${RETRY_INTERVAL}秒"
    echo "  最大重试次数: $MAX_RETRIES"
    echo "  日志文件: $LOG_FILE"
    echo "  服务名称: $SERVICE_NAME"
    echo "  安装目录: $INSTALL_DIR"
}

# 如果直接执行此脚本，显示配置
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_config
    echo ""
    validate_config
fi 