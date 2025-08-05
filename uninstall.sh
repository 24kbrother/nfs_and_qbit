#!/bin/bash

# NFS挂载和qBittorrent自动启动卸载脚本

set -e

# 默认配置
DEFAULT_INSTALL_DIR="/root/nfs_and_qbit"
DEFAULT_SERVICE_NAME="nfs-qbit"

echo "========================================"
echo "NFS挂载和qBittorrent自动启动卸载脚本"
echo "========================================"
echo ""

# 获取用户输入
echo "请输入安装目录 (直接回车使用默认值):"
echo "默认值: $DEFAULT_INSTALL_DIR"
read -p "安装目录: " input_dir
INSTALL_DIR=${input_dir:-$DEFAULT_INSTALL_DIR}

echo "请输入服务名称 (直接回车使用默认值):"
echo "默认值: $DEFAULT_SERVICE_NAME"
read -p "服务名称: " input_service
SERVICE_NAME=${input_service:-$DEFAULT_SERVICE_NAME}

echo ""
echo "卸载信息:"
echo "安装目录: $INSTALL_DIR"
echo "服务名称: $SERVICE_NAME"
echo ""

# 确认卸载
echo "确认卸载? (y/N):"
read -p "" confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "卸载已取消"
    exit 1
fi

echo ""
echo "开始卸载..."

# 停止服务
echo "停止服务..."
if systemctl is-active --quiet "${SERVICE_NAME}.service"; then
    systemctl stop "${SERVICE_NAME}.service"
    echo "服务已停止"
else
    echo "服务未运行"
fi

# 禁用服务
echo "禁用服务..."
if systemctl is-enabled --quiet "${SERVICE_NAME}.service"; then
    systemctl disable "${SERVICE_NAME}.service"
    echo "服务已禁用"
else
    echo "服务未启用"
fi

# 删除服务文件
echo "删除服务文件..."
if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    echo "服务文件已删除"
else
    echo "服务文件不存在"
fi

# 重新加载systemd
echo "重新加载systemd配置..."
systemctl daemon-reload

# 删除安装目录
echo "删除安装目录..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "安装目录已删除"
else
    echo "安装目录不存在"
fi

echo ""
echo "卸载完成！"
echo "" 