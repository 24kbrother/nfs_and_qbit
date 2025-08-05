#!/bin/bash

# 一键安装脚本 - 最简单的安装方式
# 使用方法: curl -fsSL https://raw.githubusercontent.com/24kbrother/nfs_and_qbit/main/quick-install.sh | bash

set -e

# 确保使用bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# 固定配置
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
echo "安装目录: $INSTALL_DIR (固定)"
echo "服务名称: $SERVICE_NAME (固定)"
echo ""

# 第一步：先下载脚本
echo "第一步：从GitHub下载脚本..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "正在下载脚本文件..."
git clone --depth 1 "https://github.com/$GITHUB_REPO.git" repo
if [ $? -ne 0 ]; then
    echo "错误: 无法从GitHub下载脚本，请检查网络连接"
    exit 1
fi

echo "脚本下载成功！"
echo ""

# 第二步：获取用户配置
echo "第二步：配置NFS设置"
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
echo "安装目录: $INSTALL_DIR (固定)"
echo "服务名称: $SERVICE_NAME (固定)"
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
    cd /
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 第三步：开始安装
echo "第三步：开始安装..."

# 创建安装目录
echo "创建安装目录..."
mkdir -p "$INSTALL_DIR"

# 复制脚本文件
echo "复制脚本文件..."
cp -r repo/* "$INSTALL_DIR/"

# 设置执行权限
echo "设置脚本执行权限..."
chmod +x "$INSTALL_DIR"/*.sh

# 修改配置文件
echo "配置NFS和qBittorrent设置..."
cat > "$INSTALL_DIR/config.sh" << EOF
#!/bin/bash

# NFS挂载和qBittorrent配置文件

# NFS配置
NFS_SERVER="$nfs_server"           # NFS服务器IP地址
NFS_REMOTE_PATH="$nfs_path"        # NFS服务器上的路径
MOUNT_POINT="$mount_point"         # 本地挂载点
CHECK_FOLDER="$check_folder"        # 验证挂载成功的文件夹

# qBittorrent配置
QBIT_CONTAINER_NAME="$qbit_container"  # qBittorrent容器名称

# 重试配置
RETRY_INTERVAL=10                  # 重试间隔（秒）
MAX_RETRIES=60                    # 最大重试次数（0表示无限重试）

# 日志配置
LOG_FILE="/var/log/mount-nfs-retry.log"  # NFS挂载日志文件

# 服务配置
SERVICE_NAME="$SERVICE_NAME"       # systemd服务名称
INSTALL_DIR="$INSTALL_DIR"         # 安装目录

# 验证函数
validate_config() {
    echo "验证配置..."
    
    # 检查NFS服务器地址
    if [ -z "\$NFS_SERVER" ]; then
        echo "错误: NFS_SERVER 不能为空，请在安装时输入NFS服务器IP地址"
        return 1
    fi
    
    # 检查NFS路径
    if [ -z "\$NFS_REMOTE_PATH" ]; then
        echo "错误: NFS_REMOTE_PATH 不能为空，请在安装时输入NFS路径"
        return 1
    fi
    
    # 检查挂载点
    if [ -z "\$MOUNT_POINT" ]; then
        echo "错误: MOUNT_POINT 不能为空"
        return 1
    fi
    
    # 检查验证文件夹
    if [ -z "\$CHECK_FOLDER" ]; then
        echo "错误: CHECK_FOLDER 不能为空"
        return 1
    fi
    
    # 检查容器名称
    if [ -z "\$QBIT_CONTAINER_NAME" ]; then
        echo "错误: QBIT_CONTAINER_NAME 不能为空"
        return 1
    fi
    
    echo "配置验证通过"
    return 0
}

# 显示配置
show_config() {
    echo "当前配置:"
    echo "  NFS服务器: \$NFS_SERVER"
    echo "  NFS路径: \$NFS_REMOTE_PATH"
    echo "  挂载点: \$MOUNT_POINT"
    echo "  验证文件夹: \$CHECK_FOLDER"
    echo "  qBittorrent容器: \$QBIT_CONTAINER_NAME"
    echo "  重试间隔: \${RETRY_INTERVAL}秒"
    echo "  最大重试次数: \$MAX_RETRIES"
    echo "  日志文件: \$LOG_FILE"
    echo "  服务名称: \$SERVICE_NAME"
    echo "  安装目录: \$INSTALL_DIR"
}

# 如果直接执行此脚本，显示配置
if [ "\${BASH_SOURCE[0]}" = "\${0}" ]; then
    show_config
    echo ""
    validate_config
fi
EOF

# 修改脚本中的路径
echo "配置脚本路径..."
sed -i "s|SCRIPT_DIR=\"/root/nfs_and_qbit\"|SCRIPT_DIR=\"$INSTALL_DIR\"|g" "$INSTALL_DIR/start-nfs-and-qbit.sh"

# 创建systemd服务文件
echo "创建systemd服务文件..."
cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=NFS Mount and qBittorrent Startup Service
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
ExecStart=$INSTALL_DIR/start-nfs-and-qbit.sh
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