#!/bin/bash

# NFS挂载和qBittorrent自动启动安装脚本
# 从GitHub获取文件并部署到指定位置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
GITHUB_REPO="your-username/chineseholiday"
GITHUB_BRANCH="main"
INSTALL_DIR="/root/nfs-qbit"
SERVICE_NAME="nfs-qbit"

# 显示欢迎信息
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  NFS挂载和qBittorrent自动启动安装脚本${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 获取用户输入
echo -e "${YELLOW}请输入GitHub仓库地址 (格式: username/repo):${NC}"
read -p "默认: $GITHUB_REPO: " input_repo
GITHUB_REPO=${input_repo:-$GITHUB_REPO}

echo -e "${YELLOW}请输入安装目录 (默认: $INSTALL_DIR):${NC}"
read -p "安装目录: " input_dir
INSTALL_DIR=${input_dir:-$INSTALL_DIR}

echo -e "${YELLOW}请输入服务名称 (默认: $SERVICE_NAME):${NC}"
read -p "服务名称: " input_service
SERVICE_NAME=${input_service:-$SERVICE_NAME}

echo ""
echo -e "${BLUE}配置信息:${NC}"
echo "GitHub仓库: $GITHUB_REPO"
echo "安装目录: $INSTALL_DIR"
echo "服务名称: $SERVICE_NAME"
echo ""

# 确认安装
echo -e "${YELLOW}确认安装? (y/N):${NC}"
read -p "" confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo -e "${RED}安装已取消${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}开始安装...${NC}"

# 检查依赖
echo "检查系统依赖..."
if ! command -v git &> /dev/null; then
    echo -e "${RED}错误: 未找到git命令${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}警告: 未找到docker命令，qBittorrent功能可能无法正常工作${NC}"
fi

# 创建安装目录
echo "创建安装目录..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 下载文件
echo "从GitHub下载文件..."
if [ -d "temp_download" ]; then
    rm -rf temp_download
fi

# 使用git clone或curl下载
if command -v git &> /dev/null; then
    echo "使用git下载..."
    git clone --depth 1 --branch "$GITHUB_BRANCH" "https://github.com/$GITHUB_REPO.git" temp_download
    cp -r temp_download/NFS挂载/* .
    rm -rf temp_download
else
    echo "使用curl下载..."
    # 这里可以添加curl下载逻辑
    echo -e "${RED}错误: 需要git来下载文件${NC}"
    exit 1
fi

# 设置执行权限
echo "设置脚本执行权限..."
chmod +x *.sh

# 修改脚本中的路径
echo "配置脚本路径..."
sed -i "s|SCRIPT_DIR=\"/root\"|SCRIPT_DIR=\"$INSTALL_DIR\"|g" start-nfs-and-qbit.sh

# 创建systemd服务文件
echo "创建systemd服务文件..."
cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=NFS Mount and qBittorrent Startup Service
After=network.target docker.service
Wants=docker.service

[Service]
Type=oneshot
ExecStart=$INSTALL_DIR/start-nfs-and-qbit.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
User=root
Group=root

# 重启策略
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
echo "重新加载systemd配置..."
systemctl daemon-reload

# 启用服务
echo "启用服务..."
systemctl enable "${SERVICE_NAME}.service"

echo ""
echo -e "${GREEN}安装完成！${NC}"
echo ""
echo -e "${BLUE}服务信息:${NC}"
echo "安装目录: $INSTALL_DIR"
echo "服务名称: $SERVICE_NAME"
echo ""
echo -e "${BLUE}可用命令:${NC}"
echo "启动服务: systemctl start $SERVICE_NAME"
echo "停止服务: systemctl stop $SERVICE_NAME"
echo "查看状态: systemctl status $SERVICE_NAME"
echo "查看日志: journalctl -u $SERVICE_NAME -f"
echo ""
echo -e "${YELLOW}注意: 服务将在系统启动时自动运行${NC}"
echo "" 