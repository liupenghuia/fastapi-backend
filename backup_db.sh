#!/bin/bash
# FastAPI 数据库自动备份脚本

# 配置
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/fastapi"
DB_FILE="/var/www/fastapi-backend/app.db"
LOG_FILE="/var/log/fastapi-backup.log"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========== 开始备份 =========="

# 检查数据库文件是否存在
if [ ! -f "$DB_FILE" ]; then
    log "❌ 错误：数据库文件不存在: $DB_FILE"
    exit 1
fi

# 备份数据库
BACKUP_FILE="$BACKUP_DIR/app_$DATE.db"
log "📦 备份文件: $BACKUP_FILE"

cp "$DB_FILE" "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    log "✅ 数据库复制成功"
else
    log "❌ 数据库复制失败"
    exit 1
fi

# 压缩备份
log "🗜️  压缩备份文件..."
gzip "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    log "✅ 压缩成功: ${BACKUP_FILE}.gz"
else
    log "❌ 压缩失败"
    exit 1
fi

# 计算备份文件大小
BACKUP_SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
log "📊 备份大小: $BACKUP_SIZE"

# 清理旧备份（保留最近 7 天）
log "🧹 清理 7 天前的旧备份..."
DELETED=$(find "$BACKUP_DIR" -name "app_*.db.gz" -mtime +7 -delete -print | wc -l)
log "🗑️  删除了 $DELETED 个旧备份文件"

# 列出当前所有备份
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/app_*.db.gz 2>/dev/null | wc -l)
log "📁 当前备份文件数: $BACKUP_COUNT"

log "========== 备份完成 =========="
log ""

# 返回成功
exit 0
