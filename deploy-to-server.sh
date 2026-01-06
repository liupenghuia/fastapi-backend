#!/bin/bash

# ===================================
# FastAPI 部署到阿里云服务器脚本
# ===================================

set -e

echo "🚀 开始部署 FastAPI 项目到阿里云服务器..."
echo ""

# 配置参数（请修改为你的服务器信息）
read -p "请输入服务器 IP 地址: " SERVER_IP
read -p "请输入 SSH 用户名 (默认: root): " SSH_USER
SSH_USER=${SSH_USER:-root}
read -p "请输入服务器部署路径 (默认: /var/www/fastapi-backend): " DEPLOY_PATH
DEPLOY_PATH=${DEPLOY_PATH:-/var/www/fastapi-backend}

echo ""
echo "📋 部署信息："
echo "  服务器 IP: $SERVER_IP"
echo "  SSH 用户: $SSH_USER"
echo "  部署路径: $DEPLOY_PATH"
echo ""
read -p "确认以上信息正确？(y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ 部署已取消"
    exit 1
fi

# 1. 测试 SSH 连接
echo ""
echo "🔍 步骤 1/5: 测试 SSH 连接..."
if ssh -o ConnectTimeout=5 $SSH_USER@$SERVER_IP "echo '连接成功'" > /dev/null 2>&1; then
    echo "✅ SSH 连接正常"
else
    echo "❌ SSH 连接失败，请检查："
    echo "   - 服务器 IP 是否正确"
    echo "   - SSH 密钥是否已配置"
    echo "   - 服务器防火墙是否允许 SSH 连接"
    exit 1
fi

# 2. 创建项目目录
echo ""
echo "📁 步骤 2/5: 在服务器上创建项目目录..."
ssh $SSH_USER@$SERVER_IP "mkdir -p $DEPLOY_PATH"
echo "✅ 目录创建完成"

# 3. 同步代码到服务器
echo ""
echo "📦 步骤 3/5: 同步项目文件到服务器..."

# 检查服务器是否有 rsync
if ssh $SSH_USER@$SERVER_IP "command -v rsync" > /dev/null 2>&1; then
    echo "使用 rsync 同步文件..."
    rsync -avz --progress \
      --exclude 'venv' \
      --exclude '__pycache__' \
      --exclude '*.pyc' \
      --exclude '.git' \
      --exclude 'app.db' \
      --exclude '*.log' \
      ./ $SSH_USER@$SERVER_IP:$DEPLOY_PATH/
else
    echo "⚠️  服务器未安装 rsync，使用 tar + scp 方式上传..."
    
    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    TAR_FILE="$TMP_DIR/fastapi-backend.tar.gz"
    
    # 打包项目文件
    echo "正在打包项目文件..."
    tar -czf "$TAR_FILE" \
      --exclude='venv' \
      --exclude='__pycache__' \
      --exclude='*.pyc' \
      --exclude='.git' \
      --exclude='app.db' \
      --exclude='*.log' \
      .
    
    # 上传到服务器
    echo "正在上传到服务器..."
    scp "$TAR_FILE" "$SSH_USER@$SERVER_IP:$DEPLOY_PATH/fastapi-backend.tar.gz"
    
    # 在服务器上解压
    echo "正在服务器上解压..."
    ssh $SSH_USER@$SERVER_IP "cd $DEPLOY_PATH && tar -xzf fastapi-backend.tar.gz && rm fastapi-backend.tar.gz"
    
    # 清理临时文件
    rm -rf "$TMP_DIR"
fi

echo "✅ 文件同步完成"

# 4. 上传服务器配置脚本
echo ""
echo "📝 步骤 4/5: 上传服务器配置脚本..."
scp server-setup.sh $SSH_USER@$SERVER_IP:$DEPLOY_PATH/
echo "✅ 配置脚本上传完成"

# 5. 提示下一步操作
echo ""
echo "✅ 本地部署步骤已完成！"
echo ""
echo "📌 接下来请执行以下命令连接到服务器并完成配置："
echo ""
echo "   ssh $SSH_USER@$SERVER_IP"
echo "   cd $DEPLOY_PATH"
echo "   chmod +x server-setup.sh"
echo "   ./server-setup.sh"
echo ""
echo "🎉 完成后你的 API 将运行在: http://$SERVER_IP:8000/docs"
