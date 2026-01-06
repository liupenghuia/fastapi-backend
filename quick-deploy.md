# 🚀 快速部署指南

## 方式一：自动化部署（推荐）

### 步骤 1：在本地运行部署脚本

```bash
# 给脚本添加执行权限
chmod +x deploy-to-server.sh

# 运行部署脚本
./deploy-to-server.sh
```

脚本会提示你输入：
- 服务器 IP 地址
- SSH 用户名（默认 root）
- 部署路径（默认 /var/www/fastapi-backend）

### 步骤 2：在服务器上运行配置脚本

```bash
# SSH 连接到服务器
ssh root@你的服务器IP

# 进入项目目录
cd /var/www/fastapi-backend

# 给脚本添加执行权限并运行
chmod +x server-setup.sh
./server-setup.sh
```

### 步骤 3：配置阿里云安全组

1. 登录阿里云控制台
2. 进入 **ECS 实例** → **安全组**
3. 点击 **配置规则** → **添加安全组规则**
4. 添加以下规则：

| 方向 | 授权策略 | 协议类型 | 端口范围 | 授权对象 |
|------|---------|---------|---------|---------|
| 入方向 | 允许 | TCP | 80/80 | 0.0.0.0/0 |
| 入方向 | 允许 | TCP | 443/443 | 0.0.0.0/0 |
| 入方向 | 允许 | TCP | 22/22 | 0.0.0.0/0 |

### 步骤 4：访问你的 API

打开浏览器访问：
- **API 文档**: http://你的服务器IP/docs
- **ReDoc**: http://你的服务器IP/redoc

---

## 方式二：手动部署

### 1. 上传代码到服务器

```bash
# 使用 rsync 同步代码
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' \
  ./ root@你的服务器IP:/var/www/fastapi-backend/
```

### 2. SSH 连接到服务器

```bash
ssh root@你的服务器IP
```

### 3. 安装依赖

```bash
# 更新系统
sudo apt update
sudo apt install -y python3 python3-pip python3-venv nginx

# 进入项目目录
cd /var/www/fastapi-backend

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装 Python 包
pip install -r requirements.txt
pip install gunicorn
```

### 4. 配置环境变量

```bash
# 生成新的密钥
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# 编辑 .env 文件
nano .env

# 修改以下内容：
# SECRET_KEY="刚才生成的密钥"
# DEBUG=False
```

### 5. 测试运行

```bash
# 测试启动（Ctrl+C 停止）
gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### 6. 配置 Systemd 服务

```bash
sudo nano /etc/systemd/system/fastapi-backend.service
```

粘贴以下内容（修改路径为你的实际路径）：

```ini
[Unit]
Description=FastAPI Backend Service
After=network.target

[Service]
Type=notify
User=root
Group=root
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

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start fastapi-backend
sudo systemctl enable fastapi-backend
sudo systemctl status fastapi-backend
```

### 7. 配置 Nginx

```bash
sudo nano /etc/nginx/sites-available/fastapi-backend
```

粘贴以下内容（修改服务器 IP）：

```nginx
server {
    listen 80;
    server_name 你的服务器IP;

    access_log /var/log/nginx/fastapi-access.log;
    error_log /var/log/nginx/fastapi-error.log;

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

启用配置：

```bash
sudo ln -s /etc/nginx/sites-available/fastapi-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 常见问题排查

### 无法访问网站

```bash
# 检查服务状态
sudo systemctl status fastapi-backend
sudo systemctl status nginx

# 检查端口
sudo netstat -tlnp | grep 8000
sudo netstat -tlnp | grep 80

# 查看日志
sudo journalctl -u fastapi-backend -f
tail -f /var/log/nginx/error.log
```

### 阿里云安全组未开放端口

1. 登录阿里云控制台
2. ECS → 实例 → 安全组 → 配置规则
3. 添加入方向规则：TCP 80, 443, 22

### 502 Bad Gateway

```bash
# FastAPI 服务未启动
sudo systemctl start fastapi-backend

# 查看错误日志
tail -f /var/log/fastapi-error.log
```

---

## 更新代码

```bash
# 本地执行
rsync -avz --exclude 'venv' --exclude '__pycache__' \
  ./ root@你的服务器IP:/var/www/fastapi-backend/

# 服务器执行
ssh root@你的服务器IP
sudo systemctl restart fastapi-backend
```

---

## 配置 HTTPS（可选）

```bash
# 安装 Certbot
sudo apt install -y certbot python3-certbot-nginx

# 获取证书（需要先配置域名）
sudo certbot --nginx -d 你的域名.com

# 自动续期已配置，无需手动操作
```

---

🎉 祝部署成功！
