#!/bin/bash

# 一键安装脚本 - 最简单的安装方式
# 使用方法: curl -fsSL https://raw.githubusercontent.com/24kbrother/nfs_and_qbit/main/quick-install.sh | bash

set -e

# 确保使用bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# 默认配置
GITHUB_REPO="24kbrother/nfs_and_qbit"
INSTALL_DIR="/root/nfs_and_qbit"
SERVICE_NAME="nfs-qbit"

echo "========================================"
echo "NFS挂载和qBittorrent一键安装"
echo "========================================"
echo ""

# 检查是否为root用户
if [ $EUID -ne 0 ]; then
   echo "错误: 此脚本需要root权限运行"
   echo "请使用: sudo bash $0"
   exit 1
fi

echo "开始一键安装..."
echo "GitHub仓库: $GITHUB_REPO (固定地址)"
echo "安装目录: $INSTALL_DIR"
echo "服务名称: $SERVICE_NAME"
echo ""

# 强制要求用户输入NFS配置
echo "=== NFS配置 ==="

echo "请输入NFS服务器IP地址 (必填):"
echo "示例: 192.168.1.100"
read -p "NFS服务器IP: " nfs_server
if [ -z "$nfs_server" ]; then
    echo "错误: NFS服务器IP地址不能为空"
    exit 1
fi

echo "请输入NFS服务器上的共享路径 (必填):"
echo "示例: /volume1/Media"
read -p "NFS路径: " nfs_path
if [ -z "$nfs_path" ]; then
    echo "错误: NFS路径不能为空"
    exit 1
fi

echo "请输入本地挂载点路径 (直接回车使用默认值):"
echo "默认值: /vol02/media"
read -p "挂载点: " mount_point
mount_point=${mount_point:-"/vol02/media"}

echo "请输入验证挂载成功的文件夹名称 (直接回车使用默认值):"
echo "默认值: Movies"
read -p "验证文件夹: " check_folder
check_folder=${check_folder:-"Movies"}

echo "请输入qBittorrent容器名称 (直接回车使用默认值):"
echo "默认值: qbittorrent"
read -p "容器名称: " qbit_container
qbit_container=${qbit_container:-"qbittorrent"}

echo ""
echo "配置信息:"
echo "GitHub仓库: $GITHUB_REPO (固定)"
echo "NFS服务器: $nfs_server"
echo "NFS路径: $nfs_path"
echo "挂载点: $mount_point"
echo "验证文件夹: $check_folder"
echo "qBittorrent容器: $qbit_container"
echo ""

# 确认安装
echo "确认安装? (y/N):"
read -p "" confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "安装已取消"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载文件
echo "下载安装文件..."
git clone --depth 1 "https://github.com/$GITHUB_REPO.git" repo
cp -r repo/* .
rm -rf repo

# 运行安装脚本
echo "运行安装脚本..."
if [ -f "install.sh" ]; then
    # 修改install.sh中的默认值
    sed -i "s|GITHUB_REPO=\"24kbrother/nfs_and_qbit\"|GITHUB_REPO=\"$GITHUB_REPO\"|g" install.sh
    sed -i "s|INSTALL_DIR=\"/root/nfs_and_qbit\"|INSTALL_DIR=\"$INSTALL_DIR\"|g" install.sh
    sed -i "s|SERVICE_NAME=\"nfs-qbit\"|SERVICE_NAME=\"$SERVICE_NAME\"|g" install.sh
    
    # 创建临时配置文件
    cat > "temp_config.sh" << EOF
#!/bin/bash
nfs_server="$nfs_server"
nfs_path="$nfs_path"
mount_point="$mount_point"
check_folder="$check_folder"
qbit_container="$qbit_container"
EOF
    
    # 自动确认安装并传递配置
    echo "y" | bash install.sh
else
    echo "错误: 找不到安装脚本"
    exit 1
fi

# 清理临时目录
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "一键安装完成！"
echo ""
echo "服务已自动启动并设置为开机自启"
echo ""
echo "可用命令:"
echo "查看状态: systemctl status $SERVICE_NAME"
echo "查看日志: journalctl -u $SERVICE_NAME -f"
echo "重启服务: systemctl restart $SERVICE_NAME"
echo "" 