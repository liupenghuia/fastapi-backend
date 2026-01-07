#!/bin/bash
# FastAPI 安全状态检查脚本

echo "🔍 FastAPI 项目安全检查"
echo "====================================="
echo ""

# 检查文件权限
echo "📁 1. 文件权限检查"
echo "-----------------------------------"
DB_PERM=$(stat -c "%a" /var/www/fastapi-backend/app.db 2>/dev/null)
ENV_PERM=$(stat -c "%a" /var/www/fastapi-backend/.env 2>/dev/null)

if [ "$DB_PERM" = "600" ]; then
    echo "✅ 数据库文件权限: $DB_PERM (安全)"
else
    echo "⚠️  数据库文件权限: $DB_PERM (建议: 600)"
fi

if [ "$ENV_PERM" = "600" ]; then
    echo "✅ .env 文件权限: $ENV_PERM (安全)"
else
    echo "⚠️  .env 文件权限: $ENV_PERM (建议: 600)"
fi

echo ""

# 检查 SECRET_KEY
echo "🔐 2. SECRET_KEY 检查"
echo "-----------------------------------"
if grep -q "your-super-secret-key" /var/www/fastapi-backend/.env 2>/dev/null; then
    echo "⚠️  使用默认 SECRET_KEY（不安全！）"
else
    echo "✅ SECRET_KEY 已自定义"
fi

echo ""

# 检查 DEBUG 模式
echo "🐛 3. DEBUG 模式检查"
echo "-----------------------------------"
if grep -q "^DEBUG=False" /var/www/fastapi-backend/.env 2>/dev/null; then
    echo "✅ DEBUG=False (生产模式)"
else
    echo "⚠️  DEBUG 未设置为 False"
fi

echo ""

# 检查服务状态
echo "🚀 4. 服务状态检查"
echo "-----------------------------------"
if systemctl is-active --quiet fastapi-backend; then
    echo "✅ FastAPI 服务运行中"
else
    echo "❌ FastAPI 服务未运行"
fi

if systemctl is-active --quiet nginx; then
    echo "✅ Nginx 服务运行中"
else
    echo "❌ Nginx 服务未运行"
fi

echo ""

# 检查备份
echo "💾 5. 备份检查"
echo "-----------------------------------"
BACKUP_COUNT=$(ls -1 /var/backups/fastapi/*.gz 2>/dev/null | wc -l)
echo "📦 备份文件数量: $BACKUP_COUNT"

if [ "$BACKUP_COUNT" -gt 0 ]; then
    LATEST_BACKUP=$(ls -t /var/backups/fastapi/*.gz 2>/dev/null | head -1)
    BACKUP_TIME=$(stat -c "%y" "$LATEST_BACKUP" 2>/dev/null | cut -d. -f1)
    echo "📅 最新备份时间: $BACKUP_TIME"
    echo "✅ 备份正常"
else
    echo "⚠️  没有找到备份文件"
fi

echo ""

# 检查定时任务
echo "⏰ 6. 定时任务检查"
echo "-----------------------------------"
if crontab -l 2>/dev/null | grep -q "backup_db.sh"; then
    echo "✅ 备份定时任务已配置"
    CRON_TIME=$(crontab -l | grep backup_db.sh | awk '{print $1, $2, $3, $4, $5}')
    echo "📅 执行时间: $CRON_TIME (cron 格式)"
else
    echo "⚠️  备份定时任务未配置"
fi

echo ""

# 检查防火墙
echo "🔥 7. 防火墙检查"
echo "-----------------------------------"
if firewall-cmd --list-ports 2>/dev/null | grep -q "3306"; then
    echo "⚠️  MySQL 端口 3306 对外开放（建议关闭）"
else
    echo "✅ MySQL 端口未对外开放"
fi

if firewall-cmd --list-ports 2>/dev/null | grep -q "80"; then
    echo "✅ HTTP 端口 80 已开放"
fi

if firewall-cmd --list-ports 2>/dev/null | grep -q "443"; then
    echo "✅ HTTPS 端口 443 已开放"
fi

echo ""

# 检查登录失败记录
echo "🚨 8. 安全事件检查"
echo "-----------------------------------"
FAILED_LOGINS=$(grep "Failed password" /var/log/secure 2>/dev/null | tail -5 | wc -l)
if [ "$FAILED_LOGINS" -gt 0 ]; then
    echo "⚠️  检测到 $FAILED_LOGINS 次最近的登录失败"
    echo "最近的失败登录："
    grep "Failed password" /var/log/secure 2>/dev/null | tail -3 | awk '{print "   ", $1, $2, $3, $11}'
else
    echo "✅ 没有检测到最近的登录失败"
fi

echo ""
echo "====================================="
echo "✅ 安全检查完成"
echo ""
