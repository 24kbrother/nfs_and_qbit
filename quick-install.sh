#!/bin/bash

# 一键安装脚本 - 最简单的安装方式
# 使用方法: curl -fsSL https://raw.githubusercontent.com/your-username/chineseholiday/main/NFS挂载/quick-install.sh | bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  NFS挂载和qBittorrent一键安装${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 此脚本需要root权限运行${NC}"
   echo "请使用: sudo bash $0"
   exit 1
fi

# 默认配置
GITHUB_REPO="your-username/chineseholiday"
INSTALL_DIR="/root/nfs-qbit"
SERVICE_NAME="nfs-qbit"

echo -e "${YELLOW}开始一键安装...${NC}"
echo "安装目录: $INSTALL_DIR"
echo "服务名称: $SERVICE_NAME"
echo ""

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载文件
echo "下载安装文件..."
if command -v git &> /dev/null; then
    git clone --depth 1 "https://github.com/$GITHUB_REPO.git" repo
    cp -r repo/NFS挂载/* .
    rm -rf repo
else
    echo -e "${RED}错误: 需要git来下载文件${NC}"
    exit 1
fi

# 运行安装脚本
echo "运行安装脚本..."
if [ -f "install.sh" ]; then
    # 修改install.sh中的默认值
    sed -i "s|GITHUB_REPO=\"your-username/chineseholiday\"|GITHUB_REPO=\"$GITHUB_REPO\"|g" install.sh
    sed -i "s|INSTALL_DIR=\"/root/nfs-qbit\"|INSTALL_DIR=\"$INSTALL_DIR\"|g" install.sh
    sed -i "s|SERVICE_NAME=\"nfs-qbit\"|SERVICE_NAME=\"$SERVICE_NAME\"|g" install.sh
    
    # 自动确认安装
    echo "y" | bash install.sh
else
    echo -e "${RED}错误: 找不到安装脚本${NC}"
    exit 1
fi

# 清理临时目录
cd /
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}一键安装完成！${NC}"
echo ""
echo -e "${BLUE}服务已自动启动并设置为开机自启${NC}"
echo ""
echo -e "${BLUE}可用命令:${NC}"
echo "查看状态: systemctl status $SERVICE_NAME"
echo "查看日志: journalctl -u $SERVICE_NAME -f"
echo "重启服务: systemctl restart $SERVICE_NAME"
echo "" 