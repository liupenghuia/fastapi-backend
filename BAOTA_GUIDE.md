# 🎯 宝塔面板完全使用指南

## 📋 目录

1. [宝塔面板基础](#宝塔面板基础)
2. [首次登录设置](#首次登录设置)
3. [核心功能介绍](#核心功能介绍)
4. [网站管理](#网站管理)
5. [数据库管理](#数据库管理)
6. [文件管理](#文件管理)
7. [软件商店](#软件商店)
8. [FastAPI 项目管理](#fastapi-项目管理)
9. [安全设置](#安全设置)
10. [常见问题](#常见问题)

---

## 🚀 宝塔面板基础

### 访问地址

```
https://你的服务器IP:8888
https://123.57.5.50:8888
```

### 默认账号获取

如果忘记了账号密码，SSH 连接服务器后执行：

```bash
bt default
```

这会显示：
- 外网面板地址
- 内网面板地址
- 用户名
- 密码

### 修改面板设置

```bash
# 进入宝塔命令行
bt

# 常用命令：
# 5  - 修改面板密码
# 6  - 修改面板端口
# 7  - 强制修改MySQL管理员密码
# 14 - 关闭/开启面板SSL
# 22 - 显示面板错误日志
```

---

## 🔐 首次登录设置

### 1. 登录后的初始化

首次登录时会提示：
- 绑定宝塔官网账号（可选，建议绑定）
- 安装推荐的软件（Nginx、MySQL、PHP 等）

### 2. 推荐安装的软件

对于 FastAPI 项目，建议安装：

| 软件 | 版本 | 说明 |
|------|------|------|
| **Nginx** | 1.22+ | 必装，用于反向代理 |
| **MySQL** | 5.7/8.0 | 如需数据库，推荐 MySQL 8.0 |
| **Redis** | 最新版 | 缓存，高性能项目推荐 |
| **phpMyAdmin** | 最新版 | 管理 MySQL（可选）|
| **PM2 管理器** | 最新版 | 管理 Node.js 应用（可选）|

**不需要安装**：
- ❌ PHP（除非有 PHP 项目）
- ❌ Apache（已经有 Nginx）

---

## 🎛️ 核心功能介绍

### 左侧菜单栏

```
📊 首页          - 服务器状态监控
🌐 网站          - 管理网站和反向代理
📂 FTP           - FTP 服务器管理
🗄️ 数据库        - MySQL 数据库管理
📦 容器          - Docker 容器管理
🔒 安全          - 防火墙、SSH 设置
📁 文件          - 可视化文件管理
⚙️  计划任务      - 定时任务（备份等）
🔌 软件商店      - 安装各种软件
📝 面板设置      - 宝塔面板配置
```

---

## 🌐 网站管理

### 添加网站（部署 FastAPI）

1. 点击左侧 **"网站"** → **"添加站点"**

2. 填写信息：
   ```
   域名：api.example.com（或留空用IP访问）
   根目录：/www/wwwroot/api.example.com
   FTP：不创建
   数据库：不创建（或选择MySQL）
   PHP版本：纯静态
   ```

3. 创建后，点击 **"设置"** → **"反向代理"**

4. 添加反向代理：
   ```
   代理名称：FastAPI
   目标URL：http://127.0.0.1:8000
   ```

5. 高级设置（可选）：
   ```nginx
   # 自定义配置
   proxy_set_header Host $host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   ```

### SSL 证书配置

1. 网站设置 → **"SSL"**
2. 选择方式：
   - **Let's Encrypt**：免费自动续期（推荐）
   - **其他证书**：上传自己的证书
3. 点击 **"申请"**
4. 强制 HTTPS：开启

---

## 🗄️ 数据库管理

### 创建数据库

1. 左侧菜单 → **"数据库"**
2. 点击 **"添加数据库"**
3. 填写：
   ```
   数据库名：fastapi_db
   用户名：fastapi_user
   密码：自动生成（或自定义）
   访问权限：本地服务器
   ```

### 使用 phpMyAdmin

1. 软件商店 → 搜索 **"phpMyAdmin"** → 安装
2. 数据库页面 → 点击 **"phpMyAdmin"**
3. 使用数据库账号密码登录

### 数据库备份

1. 数据库列表 → 点击数据库 → **"备份"**
2. 或设置定时备份：
   - 左侧菜单 → **"计划任务"**
   - 任务类型：备份数据库
   - 执行周期：每天/每周
   - 备份到网盘（可选）

---

## 📁 文件管理

### 可视化文件操作

左侧菜单 → **"文件"**

功能：
- ✅ 上传/下载文件
- ✅ 在线编辑文件
- ✅ 解压/压缩
- ✅ 权限管理
- ✅ 回收站

### 快速定位

常用目录：
```
/www/wwwroot/           # 网站根目录
/www/server/nginx/      # Nginx 配置
/www/server/mysql/      # MySQL 数据
/var/log/               # 系统日志
/root/                  # root 用户目录
```

### 在线编辑

1. 找到文件 → 右键 → **"编辑"**
2. 修改后 → **"保存"**
3. 语法高亮支持多种语言

---

## 🔌 软件商店

### 推荐安装（FastAPI 相关）

#### 1. **Supervisor**（进程守护）

- 作用：管理 Python 应用，自动重启
- 安装后：软件商店 → Supervisor → **"设置"**
  
  示例配置：
  ```ini
  [program:fastapi]
  command=/var/www/fastapi-backend/venv/bin/gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 127.0.0.1:8000
  directory=/var/www/fastapi-backend
  user=root
  autostart=true
  autorestart=true
  stderr_logfile=/var/log/fastapi.err.log
  stdout_logfile=/var/log/fastapi.out.log
  ```

#### 2. **Redis**（缓存）

- 作用：高性能缓存数据库
- 安装：软件商店 → 搜索 "Redis" → 安装
- 管理：软件商店 → Redis → **"设置"**

#### 3. **MySQL**

- 作用：关系型数据库
- 推荐版本：MySQL 8.0
- 安装后修改密码：软件商店 → MySQL → **"设置"** → **"修改密码"**

#### 4. **Docker 管理器**

- 作用：容器化部署
- 功能：镜像管理、容器管理、网络管理

---

## 🎯 FastAPI 项目管理

### 方案 1：使用 Systemd（推荐，已配置）

你的项目已经配置好了 systemd 服务，无需额外配置。

在宝塔中管理：
1. **软件商店** → **"系统工具"** → **"Systemd管理器"**（需安装）
2. 可以图形化管理 systemd 服务

### 方案 2：使用 Supervisor

1. 安装 Supervisor（软件商店）
2. 添加守护进程（参考上面的配置）
3. 优点：Web界面管理、日志查看方便

### 方案 3：使用 PM2（Node.js 应用）

虽然 PM2 主要用于 Node.js，但也可以管理 Python 应用：

```bash
# 安装 PM2
npm install -g pm2

# 启动 FastAPI
pm2 start "gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 127.0.0.1:8000" --name fastapi

# 开机自启
pm2 startup
pm2 save
```

---

## 🔒 安全设置

### 1. 防火墙设置

左侧菜单 → **"安全"**

**必须开放的端口：**
```
22    - SSH（可修改为其他端口）
80    - HTTP
443   - HTTPS
8888  - 宝塔面板（建议修改）
3306  - MySQL（仅本地，不要对外开放）
```

**开放端口：**
- 点击 **"放行端口"**
- 输入端口号和备注
- 勾选 **"允许外部访问"**

### 2. SSH 安全

1. 修改 SSH 端口（避免暴力破解）
2. 禁用 root 密码登录
3. 使用 SSH 密钥登录

在宝塔中设置：
- **安全** → **"SSH安全"**
- 修改端口、禁用密码登录

### 3. 面板设置

**面板设置** → **"安全设置"**：

- ✅ 绑定域名（只允许域名访问）
- ✅ 绑定IP（白名单）
- ✅ 修改面板端口（默认8888）
- ✅ 开启 BasicAuth 认证
- ✅ 开启面板SSL

### 4. 监控报警

**面板设置** → **"监控报警"**：

- CPU 使用率告警
- 内存使用率告警
- 磁盘使用率告警
- 通过邮件/钉钉/微信通知

---

## 📊 系统监控

### 首页仪表盘

显示：
- ✅ CPU、内存、磁盘使用率
- ✅ 网络流量
- ✅ 系统负载
- ✅ 进程信息

### 性能优化

**首页** → **"系统优化"**：
- 一键优化Linux内核参数
- 提升服务器性能

---

## 🔧 常用操作技巧

### 1. 快速重启服务

**首页** → 服务列表：
- Nginx：点击 **"重载配置"** 或 **"重启"**
- MySQL：点击 **"重启"**
- Redis：点击 **"重启"**

### 2. 查看日志

**文件** → 导航到：
```
/www/wwwroot/nginx/logs/     # Nginx 访问日志
/var/log/nginx/              # Nginx 错误日志
/var/log/fastapi-access.log  # FastAPI 访问日志
/var/log/fastapi-error.log   # FastAPI 错误日志
```

右键文件 → **"查看"**

### 3. 计划任务

**计划任务** → **"添加任务"**：

常用任务：
- 释放内存（每天凌晨）
- 备份网站（每周）
- 备份数据库（每天）
- 清理日志（每月）

---

## 💡 FastAPI 项目最佳实践

### 1. 使用 Nginx 反向代理

✅ **已配置**：你的 FastAPI 已经通过 Nginx 代理

查看配置：
- **网站** → 找到你的站点 → **"配置文件"**

### 2. 配置 SSL 证书

**网站** → **"设置"** → **"SSL"**：
- 申请 Let's Encrypt 免费证书
- 开启 **"强制HTTPS"**

### 3. 设置定时备份

**计划任务** → **"添加任务"**：
```
任务类型：备份网站
网站名：你的网站
执行周期：每天 2:00
保留：最近 7 天
```

### 4. 监控应用日志

**文件** → 实时查看日志：
```bash
tail -f /var/log/fastapi-access.log
tail -f /var/log/fastapi-error.log
```

---

## ⚠️ 常见问题

### 1. 503 错误

**原因**：FastAPI 服务未启动

**解决**：
```bash
systemctl status fastapi-backend
systemctl start fastapi-backend
```

### 2. 502 错误

**原因**：Nginx 配置错误或端口被占用

**解决**：
- 检查 Nginx 配置
- 检查 FastAPI 是否在 8000 端口运行

### 3. 数据库连接失败

**原因**：MySQL 未启动或权限问题

**解决**：
- 宝塔面板重启 MySQL
- 检查数据库用户权限

### 4. 磁盘空间不足

**解决**：
- **首页** → 查看磁盘使用
- **文件** → 删除大文件
- **计划任务** → 清理日志

---

## 🎓 进阶技巧

### 1. 使用 Docker

**软件商店** → 安装 **"Docker管理器"**

部署 FastAPI 容器：
```dockerfile
# Dockerfile
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
```

### 2. 多站点管理

一台服务器部署多个项目：
- 使用不同域名
- 使用不同端口
- 通过 Nginx 反向代理区分

### 3. API 限流

Nginx 配置限流（防止 DDOS）：

```nginx
# 在网站配置文件中添加
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location /api {
    limit_req zone=api burst=20;
    proxy_pass http://127.0.0.1:8000;
}
```

---

## 📚 参考资源

- [宝塔官方文档](https://www.bt.cn/bbs/forum-39-1.html)
- [宝塔视频教程](https://www.bilibili.com/video/BV1d4411D7Qt)
- [Nginx 配置文档](https://nginx.org/en/docs/)

---

## 🎯 总结

宝塔面板的核心优势：
- ✅ 可视化管理，降低运维难度
- ✅ 一键安装常用软件
- ✅ 强大的文件管理功能
- ✅ 完善的备份和监控
- ✅ 免费且功能丰富

**建议工作流程：**
1. 用宝塔管理 Nginx、MySQL 等服务
2. 用 systemd 管理 FastAPI 应用（已配置）
3. 用宝塔的计划任务做备份
4. 用宝塔的监控查看服务器状态

---

**祝你玩转宝塔！🚀**
