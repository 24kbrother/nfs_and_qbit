#!/bin/bash

# 加载配置文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    # 默认配置（如果配置文件不存在）
    MOUNT_POINT="/vol02/media"
    QBIT_CONTAINER_NAME="qbittorrent"
    RETRY_INTERVAL=10
fi

REQUIRED_DIR="$MOUNT_POINT/Movies"

# 等待NFS挂载服务完成
sleep 10

echo "检测 NFS 挂载点和 Movies 文件夹是否就绪: $REQUIRED_DIR"

while true; do
  # 1. 检查宿主机挂载点和Movies文件夹
  if mountpoint -q "$MOUNT_POINT" && [ -d "$REQUIRED_DIR" ]; then
    echo "$(date): 宿主机NFS挂载点和Movies文件夹已就绪，检测容器状态..."
    # 如果容器已运行，先停止
    if [ "$(docker ps -q -f name=^/${QBIT_CONTAINER_NAME}$)" ]; then
      echo "$(date): 容器 $QBIT_CONTAINER_NAME 已在运行，先停止..."
      docker stop "$QBIT_CONTAINER_NAME" && echo "$(date): 容器 $QBIT_CONTAINER_NAME 已停止" || echo "$(date): 容器 $QBIT_CONTAINER_NAME 停止失败"
      echo "$(date): 停止容器后等待5秒..."
      sleep 10
    fi
    echo "$(date): 检测容器内可见性..."
    # 2. 用临时容器检测容器内能否看到Movies文件夹
    docker run --rm \
      -v "$MOUNT_POINT:/media" \
      --entrypoint /bin/sh \
      busybox:latest -c "[ -d /media/Movies ]" && CONTAINER_OK=1 || CONTAINER_OK=0

    if [ "$CONTAINER_OK" -eq 1 ]; then
      echo "$(date): 容器内也能访问到NFS挂载内容，准备启动qbittorrent容器"
      # 检查容器是否已运行
      if [ "$(docker ps -q -f name=^/${QBIT_CONTAINER_NAME}$)" ]; then
        echo "$(date): 容器 $QBIT_CONTAINER_NAME 已在运行，无需启动"
      else
        docker start "$QBIT_CONTAINER_NAME" && echo "$(date): 启动成功" || echo "$(date): 启动失败"
      fi
      break
    else
      echo "$(date): 容器内无法访问到NFS内容，${RETRY_INTERVAL}秒后重试"
      sleep $RETRY_INTERVAL
    fi
  else
    echo "$(date): 宿主机NFS挂载点或Movies文件夹未就绪，${RETRY_INTERVAL}秒后重试"
    sleep $RETRY_INTERVAL
  fi
  # 容器启动后，等待3分钟再重启一次容器
  echo "$(date): 等待3分钟后重启qbittorrent容器，确保NFS彻底可用..."
  sleep 180
  docker restart "$QBIT_CONTAINER_NAME" && echo "$(date): 容器 $QBIT_CONTAINER_NAME 已重启" || echo "$(date): 容器 $QBIT_CONTAINER_NAME 重启失败"
done