#!/bin/bash

echo "🔍 检查服务器 Python 环境..."
echo ""

echo "📦 Python 版本:"
python3 --version

echo ""
echo "📦 pip 版本:"
pip3 --version 2>/dev/null || pip --version

echo ""
echo "📦 系统信息:"
cat /etc/os-release | grep -E "^(NAME|VERSION)="

echo ""
echo "📦 可用的 Python 版本:"
ls -la /usr/bin/python* 2>/dev/null || echo "无法列出 Python 版本"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 建议："
echo ""
echo "如果 Python 版本 < 3.8:"
echo "   使用 requirements-legacy.txt（已上传）"
echo "   pip install -r requirements-legacy.txt"
echo ""
echo "如果 Python 版本 >= 3.8:"
echo "   可以使用官方源安装最新版本"
echo "   pip install -r requirements.txt -i https://pypi.org/simple"
echo ""
