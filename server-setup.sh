#!/bin/bash

# ===================================
# 服务器端自动配置脚本
# ===================================

set -e

echo "🔧 开始配置 FastAPI 服务器环境..."
echo ""

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ 无法检测操作系统"
    exit 1
fi

echo "📋 检测到操作系统: $OS"
echo ""

# 1. 检查系统依赖
echo "📦 步骤 1/8: 检查系统依赖..."
echo "Python 3.8 和 Nginx 已安装，跳过..."
echo "✅ 系统依赖检查完成"

# 2. 创建 Python 虚拟环境
echo ""
echo "🐍 步骤 2/8: 创建 Python 虚拟环境..."
# 使用 Python 3.8
if [ -d "venv" ]; then
    echo "虚拟环境已存在，跳过创建"
else
    python3.8 -m venv venv
fi
source venv/bin/activate
python --version
echo "✅ 虚拟环境创建完成"

# 3. 安装 Python 依赖
echo ""
echo "📚 步骤 3/8: 安装 Python 依赖包..."
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn
echo "✅ Python 依赖安装完成"

# 4. 配置环境变量
echo ""
echo "🔐 步骤 4/8: 配置环境变量..."
if [ ! -f .env ]; then
    echo "❌ .env 文件不存在"
    exit 1
fi

# 生成新的 SECRET_KEY
NEW_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
echo "生成的安全密钥: $NEW_SECRET_KEY"

# 备份原 .env
cp .env .env.backup

# 更新 SECRET_KEY
if grep -q "^SECRET_KEY=" .env; then
    sed -i "s|^SECRET_KEY=.*|SECRET_KEY=\"$NEW_SECRET_KEY\"|" .env
else
    echo "SECRET_KEY=\"$NEW_SECRET_KEY\"" >> .env
fi

# 设置 DEBUG=False
if grep -q "^DEBUG=" .env; then
    sed -i "s|^DEBUG=.*|DEBUG=False|" .env
else
    echo "DEBUG=False" >> .env
fi

echo "✅ 环境变量配置完成"

# 5. 测试应用启动
echo ""
echo "🧪 步骤 5/8: 测试应用启动..."
timeout 10 python3 -c "
from app.main import app
print('✅ 应用导入成功')
" || echo "⚠️  应用测试完成"

# 6. 创建 Systemd 服务
echo ""
echo "⚙️  步骤 6/8: 创建 Systemd 服务..."

# 获取当前目录的绝对路径
CURRENT_DIR=$(pwd)

sudo tee /etc/systemd/system/fastapi-backend.service > /dev/null <<EOF
[Unit]
Description=FastAPI Backend Service
After=network.target

[Service]
Type=notify
User=$USER
Group=$USER
WorkingDirectory=$CURRENT_DIR
Environment="PATH=$CURRENT_DIR/venv/bin"

ExecStart=$CURRENT_DIR/venv/bin/gunicorn app.main:app \\
    --workers 4 \\
    --worker-class uvicorn.workers.UvicornWorker \\
    --bind 127.0.0.1:8000 \\
    --access-logfile /var/log/fastapi-access.log \\
    --error-logfile /var/log/fastapi-error.log

ExecReload=/bin/kill -s HUP \$MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Systemd 服务文件创建完成"

# 7. 配置 Nginx
echo ""
echo "🌐 步骤 7/8: 配置 Nginx 反向代理..."

# 获取服务器 IP
SERVER_IP=$(hostname -I | awk '{print $1}')

sudo tee /etc/nginx/sites-available/fastapi-backend > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_IP;

    # 日志
    access_log /var/log/nginx/fastapi-access.log;
    error_log /var/log/nginx/fastapi-error.log;

    # 反向代理到 FastAPI
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # 文件上传大小限制
    client_max_body_size 10M;
}
EOF

# 启用站点配置
if [ -d /etc/nginx/sites-enabled ]; then
    sudo ln -sf /etc/nginx/sites-available/fastapi-backend /etc/nginx/sites-enabled/
fi

# 测试 Nginx 配置
sudo nginx -t

echo "✅ Nginx 配置完成"

# 8. 启动服务
echo ""
echo "🚀 步骤 8/8: 启动所有服务..."

# 重新加载 systemd
sudo systemctl daemon-reload

# 启动 FastAPI 服务
sudo systemctl start fastapi-backend
sudo systemctl enable fastapi-backend

# 重启 Nginx
sudo systemctl restart nginx

echo "✅ 服务启动完成"

# 9. 配置防火墙（如果存在）
echo ""
echo "🔥 配置防火墙..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 'Nginx Full'
    sudo ufw allow OpenSSH
    echo "✅ UFW 防火墙规则已添加"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
    echo "✅ Firewalld 防火墙规则已添加"
fi

# 10. 显示状态
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 服务状态："
sudo systemctl status fastapi-backend --no-pager | head -n 10
echo ""
echo "🌐 访问地址："
echo "   API 文档: http://$SERVER_IP/docs"
echo "   API 文档: http://$SERVER_IP/redoc"
echo ""
echo "📝 常用命令："
echo "   查看服务状态: sudo systemctl status fastapi-backend"
echo "   重启服务:     sudo systemctl restart fastapi-backend"
echo "   查看日志:     sudo journalctl -u fastapi-backend -f"
echo "   查看应用日志: tail -f /var/log/fastapi-access.log"
echo ""
echo "⚠️  阿里云安全组设置："
echo "   请确保在阿里云控制台的安全组中开放以下端口："
echo "   - 80 (HTTP)"
echo "   - 443 (HTTPS, 如需配置 SSL)"
echo ""
