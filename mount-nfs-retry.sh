#!/bin/bash

# 加载配置文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    # 默认配置（如果配置文件不存在）
    NFS_SERVER="10.3.0.252"
    NFS_REMOTE_PATH="/volume1/Media"
    MOUNT_POINT="/vol02/media"
    CHECK_FOLDER="Movies"
    RETRY_INTERVAL=10
    LOG_FILE="/var/log/mount-nfs-retry.log"
fi

mkdir -p "$MOUNT_POINT"

while true; do
  echo "$(date): 检查NFS服务可用性..."
  if showmount -e "$NFS_SERVER" &>/dev/null; then
    echo "$(date): NFS服务可用，检查挂载状态..."
    if mountpoint -q "$MOUNT_POINT"; then
      echo "$(date): 已挂载成功 -> $MOUNT_POINT"
      # 检查Movies文件夹是否存在
      if [ -d "$MOUNT_POINT/$CHECK_FOLDER" ]; then
        echo "$(date): 验证成功！找到 $CHECK_FOLDER 文件夹，挂载正常"
        exit 0
      else
        echo "$(date): 警告！挂载点存在但未找到 $CHECK_FOLDER 文件夹，可能挂载失败，强制卸载并重试..."
        umount -f "$MOUNT_POINT"
        sleep 2
      fi
    else
      # 如果已挂载但不可用，先umount
      mount | grep -q "$MOUNT_POINT" && umount -f "$MOUNT_POINT"
      echo "$(date): 未挂载，尝试挂载..."
      mount -t nfs "${NFS_SERVER}:${NFS_REMOTE_PATH}" "$MOUNT_POINT" 2>&1 | tee -a /var/log/mount-nfs-retry.log
      if mountpoint -q "$MOUNT_POINT"; then
        echo "$(date): 挂载成功！正在验证挂载内容..."
        # 检查Movies文件夹是否存在
        if [ -d "$MOUNT_POINT/$CHECK_FOLDER" ]; then
          echo "$(date): 验证成功！找到 $CHECK_FOLDER 文件夹，挂载正常"
          exit 0
        else
          echo "$(date): 挂载失败！未找到 $CHECK_FOLDER 文件夹，10秒后重试..."
          umount -f "$MOUNT_POINT"
          sleep $RETRY_INTERVAL
        fi
      else
        echo "$(date): 挂载失败，${RETRY_INTERVAL}秒后重试..."
        sleep $RETRY_INTERVAL
      fi
    fi
  else
    echo "$(date): NFS服务未就绪，${RETRY_INTERVAL}秒后重试..."
    sleep $RETRY_INTERVAL
  fi
done
