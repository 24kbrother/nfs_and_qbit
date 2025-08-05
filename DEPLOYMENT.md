# 部署指南

本文档说明如何将NFS挂载和qBittorrent自动启动项目部署到GitHub。

## 文件结构

```
NFS挂载/
├── README.md              # 项目说明文档
├── DEPLOYMENT.md          # 部署指南（本文件）
├── install.sh             # 安装脚本
├── uninstall.sh           # 卸载脚本
├── quick-install.sh       # 一键安装脚本
├── config.sh              # 配置文件
├── mount-nfs-retry.sh     # NFS挂载脚本
├── start-qbit-after-nfs.sh # qBittorrent启动脚本
├── start-nfs-and-qbit.sh  # 主控制脚本
└── nfs-qbit.service       # systemd服务文件
```

## 部署步骤

### 1. 准备GitHub仓库

1. 在GitHub上创建新仓库
2. 仓库名称建议：`chineseholiday` 或 `nfs-qbit-automation`
3. 设置为公开仓库（便于一键安装）

### 2. 上传文件

```bash
# 克隆仓库到本地
git clone https://github.com/your-username/chineseholiday.git
cd chineseholiday

# 复制NFS挂载文件夹
cp -r /path/to/your/NFS挂载 ./

# 提交文件
git add .
git commit -m "Add NFS mount and qBittorrent automation scripts"
git push origin main
```

### 3. 更新配置

在部署前，需要更新以下文件中的GitHub仓库地址：

1. **install.sh** - 第12行
2. **quick-install.sh** - 第25行
3. **README.md** - 所有GitHub链接

将 `your-username/chineseholiday` 替换为您的实际仓库地址。

### 4. 测试安装

部署完成后，测试一键安装：

```bash
# 测试一键安装
curl -fsSL https://raw.githubusercontent.com/your-username/chineseholiday/main/NFS挂载/quick-install.sh | bash
```

## 使用说明

### 用户安装方式

用户可以通过以下方式安装：

1. **一键安装**（推荐）：
   ```bash
   curl -fsSL https://raw.githubusercontent.com/your-username/chineseholiday/main/NFS挂载/quick-install.sh | bash
   ```

2. **手动安装**：
   ```bash
   git clone https://github.com/your-username/chineseholiday.git
   cd chineseholiday/NFS挂载
   bash install.sh
   ```

### 自定义配置

用户可以通过修改 `config.sh` 文件来自定义配置：

```bash
# 编辑配置文件
nano /root/nfs-qbit/config.sh
```

主要配置项：
- `NFS_SERVER` - NFS服务器IP
- `NFS_REMOTE_PATH` - NFS服务器路径
- `MOUNT_POINT` - 本地挂载点
- `CHECK_FOLDER` - 验证文件夹
- `QBIT_CONTAINER_NAME` - qBittorrent容器名

## 维护说明

### 更新脚本

1. 修改本地脚本
2. 测试功能
3. 提交到GitHub
4. 用户可以通过重新运行安装脚本来更新

### 版本管理

建议使用语义化版本号：
- 主版本号：重大功能变更
- 次版本号：新功能添加
- 修订号：bug修复

### 问题反馈

- 在GitHub仓库创建Issue
- 提供详细的错误信息和系统环境
- 包含相关日志文件

## 安全注意事项

1. **权限检查**：脚本需要root权限运行
2. **网络安全**：确保NFS服务器访问安全
3. **日志管理**：定期清理日志文件
4. **备份配置**：重要配置建议备份

## 故障排除

### 常见问题

1. **GitHub访问问题**
   - 检查网络连接
   - 确认仓库地址正确
   - 尝试使用SSH密钥

2. **权限问题**
   - 确保以root用户运行
   - 检查文件执行权限

3. **服务启动失败**
   - 检查systemd日志
   - 验证配置文件
   - 确认依赖服务运行

### 调试方法

```bash
# 查看服务状态
systemctl status nfs-qbit

# 查看详细日志
journalctl -u nfs-qbit -f

# 手动测试脚本
cd /root/nfs-qbit
./mount-nfs-retry.sh
./start-qbit-after-nfs.sh
```

## 许可证

建议使用MIT许可证，允许用户自由使用和修改。 