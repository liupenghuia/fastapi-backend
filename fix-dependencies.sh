#!/bin/bash

# ===================================
# 修复服务器依赖安装问题
# ===================================

set -e

echo "🔧 开始修复 Python 依赖安装问题..."
echo ""

# 检查是否在虚拟环境中
if [ -z "$VIRTUAL_ENV" ]; then
    echo "⚠️  未检测到虚拟环境，正在激活..."
    source venv/bin/activate
fi

echo "📦 当前 Python 版本:"
python3 --version

echo ""
echo "📦 当前 pip 版本:"
pip --version

# 1. 升级 pip
echo ""
echo "⬆️  步骤 1/3: 升级 pip 到最新版本..."
pip install --upgrade pip -i https://pypi.org/simple

echo ""
echo "✅ pip 升级完成，新版本:"
pip --version

# 2. 尝试使用多个镜像源安装依赖
echo ""
echo "📚 步骤 2/3: 安装 Python 依赖包..."

# 镜像源列表
MIRRORS=(
    "https://pypi.org/simple"
    "https://mirrors.aliyun.com/pypi/simple/"
    "https://pypi.tuna.tsinghua.edu.cn/simple"
)

SUCCESS=false

for MIRROR in "${MIRRORS[@]}"; do
    echo ""
    echo "尝试使用镜像源: $MIRROR"
    if pip install -r requirements.txt -i "$MIRROR"; then
        echo "✅ 依赖安装成功！"
        SUCCESS=true
        break
    else
        echo "⚠️  该镜像源安装失败，尝试下一个..."
    fi
done

if [ "$SUCCESS" = false ]; then
    echo ""
    echo "❌ 所有镜像源都失败了。请检查网络连接或手动安装依赖。"
    exit 1
fi

# 3. 安装 Gunicorn
echo ""
echo "📚 步骤 3/3: 安装 Gunicorn..."
pip install gunicorn -i https://pypi.org/simple

# 4. 验证安装
echo ""
echo "🧪 验证安装..."
python3 -c "
import fastapi
import uvicorn
import sqlalchemy
import gunicorn
print('✅ FastAPI 版本:', fastapi.__version__)
print('✅ Uvicorn 版本:', uvicorn.__version__)
print('✅ SQLAlchemy 版本:', sqlalchemy.__version__)
print('✅ Gunicorn 版本:', gunicorn.__version__)
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 依赖安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 接下来请继续运行部署脚本的剩余步骤："
echo "   ./server-setup.sh"
echo ""
