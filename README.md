# NFS挂载和qBittorrent自动启动服务

这是一个自动化脚本集合，用于在Linux系统上自动挂载NFS存储并启动qBittorrent容器。

## 功能特性

- 🔄 自动检测和挂载NFS存储
- ✅ 验证挂载点内容（检查Movies文件夹）
- 🐳 自动启动qBittorrent Docker容器
- 🔍 容器内NFS访问验证
- 🚀 systemd服务集成
- 📝 详细的日志记录

## 快速安装

### 一键安装

```bash
# 下载安装脚本
curl -fsSL https://raw.githubusercontent.com/your-username/chineseholiday/main/NFS挂载/install.sh | bash
```

### 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/your-username/chineseholiday.git
cd chineseholiday/NFS挂载

# 2. 运行安装脚本
bash install.sh
```

## 配置说明

### 默认配置

- **NFS服务器**: 10.3.0.252
- **NFS路径**: /volume1/Media
- **挂载点**: /vol02/media
- **验证文件夹**: Movies
- **qBittorrent容器名**: qbittorrent

### 自定义配置

安装过程中会提示您输入：
- GitHub仓库地址
- 安装目录
- 服务名称

## 使用方法

### 服务管理

```bash
# 启动服务
systemctl start nfs-qbit

# 停止服务
systemctl stop nfs-qbit

# 查看状态
systemctl status nfs-qbit

# 查看日志
journalctl -u nfs-qbit -f

# 重启服务
systemctl restart nfs-qbit
```

### 手动执行

```bash
# 进入安装目录
cd /root/nfs-qbit

# 手动执行NFS挂载
./mount-nfs-retry.sh

# 手动执行qBittorrent启动
./start-qbit-after-nfs.sh

# 执行完整流程
./start-nfs-and-qbit.sh
```

## 脚本说明

### mount-nfs-retry.sh
- 检测NFS服务可用性
- 自动挂载NFS存储
- 验证Movies文件夹存在
- 失败时自动重试

### start-qbit-after-nfs.sh
- 等待NFS挂载完成
- 验证容器内NFS访问
- 启动qBittorrent容器
- 容器重启验证

### start-nfs-and-qbit.sh
- 主控制脚本
- 按顺序执行挂载和启动
- 错误处理和日志记录

## 卸载

```bash
# 运行卸载脚本
bash uninstall.sh
```

## 故障排除

### 常见问题

1. **NFS挂载失败**
   - 检查NFS服务器地址和路径
   - 确认网络连接正常
   - 查看 `/var/log/mount-nfs-retry.log`

2. **qBittorrent容器启动失败**
   - 确认Docker服务运行
   - 检查容器名称是否正确
   - 验证NFS挂载点权限

3. **Movies文件夹不存在**
   - 确认NFS服务器上的文件夹路径
   - 检查挂载点内容

### 日志查看

```bash
# 查看NFS挂载日志
tail -f /var/log/mount-nfs-retry.log

# 查看服务日志
journalctl -u nfs-qbit -f

# 查看系统日志
journalctl -f
```

## 系统要求

- Linux系统（支持systemd）
- Git
- Docker（可选，用于qBittorrent）
- NFS客户端工具

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v1.0.0
- 初始版本
- 支持NFS自动挂载
- 支持qBittorrent自动启动
- systemd服务集成 