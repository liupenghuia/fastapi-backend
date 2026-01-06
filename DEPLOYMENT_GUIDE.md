# 🚀 FastAPI 项目部署指南
## 阿里云服务器 + 域名部署完整教程

---

## 📋 目录

1. [服务器准备](#1-服务器准备)
2. [项目上传](#2-项目上传)
3. [环境配置](#3-环境配置)
4. [数据库配置](#4-数据库配置)
5. [运行应用](#5-运行应用)
6. [Nginx 配置](#6-nginx-配置)
7. [域名配置](#7-域名配置)
8. [SSL 证书（HTTPS）](#8-ssl-证书https)
9. [进程守护](#9-进程守护)
10. [常用维护命令](#10-常用维护命令)

---

## 1. 服务器准备

### 1.1 连接到阿里云服务器

```bash
# 使用 SSH 连接（替换为你的服务器 IP）
ssh root@你的服务器IP
# 或者使用密钥
ssh -i /path/to/your-key.pem root@你的服务器IP
```

### 1.2 更新系统

```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 1.3 安装必要软件

```bash
# Ubuntu/Debian
sudo apt install -y python3 python3-pip python3-venv nginx git

# CentOS/RHEL
sudo yum install -y python3 python3-pip nginx git
```

### 1.4 创建部署目录

```bash
# 创建项目目录
sudo mkdir -p /var/www/fastapi-backend
cd /var/www/fastapi-backend
```

---

## 2. 项目上传

### 方式 1：使用 Git（推荐）

```bash
# 如果你的项目在 GitHub
cd /var/www/fastapi-backend
git clone https://github.com/你的用户名/fastapi-backend.git .

# 或者从本地推送
# 本地执行：
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/fastapi-backend.git
git push -u origin main
```

### 方式 2：使用 SCP 上传

```bash
# 在本地执行（将项目打包上传）
cd /Users/a58/.gemini/antigravity/scratch/fastapi-backend
tar -czf fastapi-backend.tar.gz app requirements.txt .env

# 上传到服务器
scp fastapi-backend.tar.gz root@你的服务器IP:/var/www/fastapi-backend/

# 在服务器上解压
ssh root@你的服务器IP
cd /var/www/fastapi-backend
tar -xzf fastapi-backend.tar.gz
```

### 方式 3：使用 rsync（推荐，支持增量同步）

```bash
# 在本地执行
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' \
  /Users/a58/.gemini/antigravity/scratch/fastapi-backend/ \
  root@你的服务器IP:/var/www/fastapi-backend/
```

---

## 3. 环境配置

### 3.1 创建虚拟环境

```bash
cd /var/www/fastapi-backend
python3 -m venv venv
source venv/bin/activate
```

### 3.2 安装依赖

```bash
pip install --upgrade pip
pip install -r requirements.txt

# 额外安装生产环境依赖
pip install gunicorn
```

### 3.3 配置环境变量

```bash
# 编辑 .env 文件
nano /var/www/fastapi-backend/.env
```

**生产环境 .env 配置：**
```env
# 应用配置
APP_NAME="用户管理 API"
APP_VERSION="1.0.0"
DEBUG=False

# 安全配置（务必修改！）
SECRET_KEY="your-super-secret-production-key-min-32-chars-change-this"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 数据库配置
DATABASE_URL="sqlite+aiosqlite:///./app.db"

# CORS 配置（根据需要调整）
ALLOWED_ORIGINS=["https://你的域名.com"]
```

**⚠️ 安全提示：**
- 务必修改 `SECRET_KEY`，使用随机字符串（至少 32 位）
- 设置 `DEBUG=False`
- 配置正确的 `ALLOWED_ORIGINS`

**生成安全的 SECRET_KEY：**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## 4. 数据库配置

### 4.1 使用 SQLite（开发/小型项目）

```bash
# SQLite 数据库会自动创建，无需额外配置
cd /var/www/fastapi-backend
source venv/bin/activate
python3 -c "from app.core.database import init_db; import asyncio; asyncio.run(init_db())"
```

### 4.2 使用 PostgreSQL（生产环境推荐）

#### 安装 PostgreSQL

```bash
# Ubuntu/Debian
sudo apt install -y postgresql postgresql-contrib

# CentOS/RHEL
sudo yum install -y postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
```

#### 创建数据库和用户

```bash
# 切换到 postgres 用户
sudo -u postgres psql

-- 在 PostgreSQL 命令行中执行
CREATE DATABASE fastapi_db;
CREATE USER fastapi_user WITH PASSWORD 'your_strong_password';
GRANT ALL PRIVILEGES ON DATABASE fastapi_db TO fastapi_user;
\q
```

#### 安装 Python PostgreSQL 驱动

```bash
pip install asyncpg psycopg2-binary
```

#### 更新 .env 配置

```env
DATABASE_URL="postgresql+asyncpg://fastapi_user:your_strong_password@localhost/fastapi_db"
```

---

## 5. 运行应用

### 5.1 测试运行

```bash
cd /var/www/fastapi-backend
source venv/bin/activate

# 测试启动
uvicorn app.main:app --host 0.0.0.0 --port 8000

# 在另一个终端测试
curl http://你的服务器IP:8000/
```

### 5.2 使用 Gunicorn + Uvicorn（生产环境）

```bash
# 启动应用（4 个工作进程）
gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --access-logfile /var/log/fastapi-access.log \
  --error-logfile /var/log/fastapi-error.log \
  --daemon
```

**工作进程数量建议：** `CPU 核心数 × 2 + 1`

---

## 6. Nginx 配置

### 6.1 创建 Nginx 配置文件

```bash
sudo nano /etc/nginx/sites-available/fastapi-backend
```

**基本配置（HTTP）：**

```nginx
server {
    listen 80;
    server_name 你的域名.com www.你的域名.com;

    # 日志
    access_log /var/log/nginx/fastapi-access.log;
    error_log /var/log/nginx/fastapi-error.log;

    # 反向代理到 FastAPI
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API 文档路径
    location /docs {
        proxy_pass http://127.0.0.1:8000/docs;
        proxy_set_header Host $host;
    }

    location /redoc {
        proxy_pass http://127.0.0.1:8000/redoc;
        proxy_set_header Host $host;
    }

    # 文件上传大小限制
    client_max_body_size 10M;
}
```

### 6.2 启用配置

```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/fastapi-backend /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

### 6.3 配置防火墙

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable

# CentOS/RHEL (Firewalld)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

## 7. 域名配置

### 7.1 在阿里云添加 DNS 解析

1. 登录阿里云控制台
2. 进入 **云解析 DNS** → **域名解析**
3. 选择你的域名，点击 **解析设置**
4. 添加记录：

| 记录类型 | 主机记录 | 解析线路 | 记录值 | TTL |
|---------|---------|---------|--------|-----|
| A | @ | 默认 | 你的服务器IP | 10分钟 |
| A | www | 默认 | 你的服务器IP | 10分钟 |

### 7.2 验证 DNS 解析

```bash
# 等待 5-10 分钟后测试
ping 你的域名.com
nslookup 你的域名.com
```

### 7.3 测试访问

```bash
# 浏览器访问
http://你的域名.com/
http://你的域名.com/docs
```

---

## 8. SSL 证书（HTTPS）

### 8.1 安装 Certbot

```bash
# Ubuntu/Debian
sudo apt install -y certbot python3-certbot-nginx

# CentOS/RHEL
sudo yum install -y certbot python3-certbot-nginx
```

### 8.2 获取免费 SSL 证书

```bash
# 自动配置 Nginx
sudo certbot --nginx -d 你的域名.com -d www.你的域名.com

# 按照提示输入邮箱，同意条款
# Certbot 会自动修改 Nginx 配置并启用 HTTPS
```

### 8.3 自动续期

```bash
# Certbot 会自动创建续期任务
# 手动测试续期
sudo certbot renew --dry-run

# 查看定时任务
sudo systemctl status certbot.timer
```

### 8.4 完整 Nginx 配置（HTTPS）

Certbot 会自动生成，配置类似：

```nginx
server {
    listen 80;
    server_name 你的域名.com www.你的域名.com;
    
    # HTTP 重定向到 HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name 你的域名.com www.你的域名.com;

    # SSL 证书
    ssl_certificate /etc/letsencrypt/live/你的域名.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/你的域名.com/privkey.pem;

    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 日志
    access_log /var/log/nginx/fastapi-access.log;
    error_log /var/log/nginx/fastapi-error.log;

    # 反向代理
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    client_max_body_size 10M;
}
```

---

## 9. 进程守护

### 9.1 创建 Systemd 服务文件

```bash
sudo nano /etc/systemd/system/fastapi-backend.service
```

**服务配置：**

```ini
[Unit]
Description=FastAPI Backend Service
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/fastapi-backend
Environment="PATH=/var/www/fastapi-backend/venv/bin"

ExecStart=/var/www/fastapi-backend/venv/bin/gunicorn app.main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 127.0.0.1:8000 \
    --access-logfile /var/log/fastapi-access.log \
    --error-logfile /var/log/fastapi-error.log

ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### 9.2 设置权限

```bash
# 修改项目目录所有者
sudo chown -R www-data:www-data /var/www/fastapi-backend

# 如果使用 root 用户，修改服务文件中的 User 和 Group
```

### 9.3 启动服务

```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start fastapi-backend

# 查看状态
sudo systemctl status fastapi-backend

# 设置开机自启
sudo systemctl enable fastapi-backend
```

### 9.4 管理服务

```bash
# 启动
sudo systemctl start fastapi-backend

# 停止
sudo systemctl stop fastapi-backend

# 重启
sudo systemctl restart fastapi-backend

# 查看日志
sudo journalctl -u fastapi-backend -f
```

---

## 10. 常用维护命令

### 10.1 查看日志

```bash
# 应用日志
tail -f /var/log/fastapi-access.log
tail -f /var/log/fastapi-error.log

# Nginx 日志
tail -f /var/log/nginx/fastapi-access.log
tail -f /var/log/nginx/fastapi-error.log

# Systemd 日志
sudo journalctl -u fastapi-backend -f
```

### 10.2 更新代码

```bash
# 方式 1：Git 拉取
cd /var/www/fastapi-backend
git pull origin main

# 方式 2：rsync 同步
# 在本地执行
rsync -avz --exclude 'venv' --exclude '__pycache__' \
  /Users/a58/.gemini/antigravity/scratch/fastapi-backend/ \
  root@你的服务器IP:/var/www/fastapi-backend/

# 重启服务
sudo systemctl restart fastapi-backend
```

### 10.3 数据库备份

```bash
# SQLite 备份
cp /var/www/fastapi-backend/app.db /var/backups/app.db.$(date +%Y%m%d)

# PostgreSQL 备份
pg_dump -U fastapi_user fastapi_db > /var/backups/fastapi_db.$(date +%Y%m%d).sql

# 定时备份（crontab）
crontab -e
# 添加：每天凌晨 2 点备份
0 2 * * * cp /var/www/fastapi-backend/app.db /var/backups/app.db.$(date +\%Y\%m\%d)
```

### 10.4 监控和性能

```bash
# 查看进程
ps aux | grep gunicorn

# 查看端口占用
sudo netstat -tlnp | grep 8000

# 查看系统资源
htop

# 查看磁盘使用
df -h

# 查看内存使用
free -h
```

---

## 📋 部署检查清单

完成部署后，请检查：

- [ ] 服务器可以通过 SSH 连接
- [ ] 项目代码已上传到服务器
- [ ] Python 虚拟环境已创建并激活
- [ ] 依赖包已安装（`requirements.txt`）
- [ ] `.env` 文件已配置（生产环境配置）
- [ ] `SECRET_KEY` 已修改为随机字符串
- [ ] 数据库已初始化
- [ ] Gunicorn 可以正常启动应用
- [ ] Nginx 已安装并配置反向代理
- [ ] 防火墙已开放 HTTP/HTTPS 端口
- [ ] DNS 解析已生效
- [ ] 可以通过域名访问（HTTP）
- [ ] SSL 证书已安装（HTTPS）
- [ ] Systemd 服务已配置并启动
- [ ] 服务设置为开机自启
- [ ] 日志记录正常
- [ ] 可以访问 API 文档（`/docs`）

---

## 🔧 故障排查

### 问题 1：无法访问网站

```bash
# 检查 Nginx 状态
sudo systemctl status nginx

# 检查 FastAPI 服务状态
sudo systemctl status fastapi-backend

# 检查端口监听
sudo netstat -tlnp | grep 8000
sudo netstat -tlnp | grep 80

# 查看 Nginx 错误日志
tail -f /var/log/nginx/error.log
```

### 问题 2：502 Bad Gateway

```bash
# 检查 FastAPI 服务是否运行
sudo systemctl status fastapi-backend

# 检查应用日志
tail -f /var/log/fastapi-error.log

# 重启服务
sudo systemctl restart fastapi-backend
```

### 问题 3：DNS 解析失败

```bash
# 检查 DNS 解析
nslookup 你的域名.com

# 清除本地 DNS 缓存（本地电脑）
# Mac
sudo dscacheutil -flushcache

# Windows
ipconfig /flushdns
```

### 问题 4：SSL 证书问题

```bash
# 检查证书状态
sudo certbot certificates

# 强制续期
sudo certbot renew --force-renewal

# 重启 Nginx
sudo systemctl restart nginx
```

---

## 🎯 性能优化建议

### 1. 数据库优化

- 使用 PostgreSQL 替代 SQLite（生产环境）
- 添加数据库索引
- 配置连接池

### 2. 应用优化

```python
# 增加 Gunicorn 工作进程
--workers 8  # 根据 CPU 核心数调整
```

### 3. Nginx 优化

```nginx
# 启用 Gzip 压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript;

# 缓存静态文件
location /static {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### 4. 安全加固

```bash
# 禁用 root SSH 登录
sudo nano /etc/ssh/sshd_config
# PermitRootLogin no

# 配置防火墙只开放必要端口
sudo ufw default deny incoming
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

---

## 📚 参考资源

- [Nginx 官方文档](https://nginx.org/en/docs/)
- [Gunicorn 文档](https://docs.gunicorn.org/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Systemd 文档](https://www.freedesktop.org/wiki/Software/systemd/)

---

🎉 **恭喜！你的 FastAPI 应用已成功部署！**

访问：`https://你的域名.com/docs` 查看 API 文档
