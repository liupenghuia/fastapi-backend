# 📚 日志管理和搜索完整指南

## 🎯 解决两个核心问题

### 问题 1：日志文件太大怎么办？
### 问题 2：如何搜索特定用户的日志？

---

## 📦 问题 1：日志文件管理

### ✅ 自动轮转机制（已配置）

你的日志系统已经配置了自动管理，**无需手动干预**！

#### **轮转策略**

```python
# app/core/logging_config.py

# 应用日志
logger.add(
    LOG_DIR / "app.log",
    rotation="00:00",      # 每天午夜轮转
    retention="7 days",    # 保留 7 天
    compression="gz",      # gzip 压缩
)

# 错误日志
logger.add(
    LOG_DIR / "error.log",
    rotation="100 MB",     # 达到 100MB 轮转
    retention="30 days",   # 保留 30 天
    compression="gz",
)
```

#### **工作流程**

```
第 1 天：
/var/log/fastapi/app.log (16 KB)

第 2 天凌晨 00:00：
/var/log/fastapi/app.log (新文件)
/var/log/fastapi/app.log.2026-01-07.gz (16 KB → 4 KB 压缩)

第 3 天凌晨 00:00：
/var/log/fastapi/app.log (新文件)
/var/log/fastapi/app.log.2026-01-08.gz
/var/log/fastapi/app.log.2026-01-07.gz

第 8 天凌晨 00:00：
/var/log/fastapi/app.log (新文件)
/var/log/fastapi/app.log.2026-01-14.gz
/var/log/fastapi/app.log.2026-01-13.gz
...
/var/log/fastapi/app.log.2026-01-08.gz
# app.log.2026-01-07.gz 被自动删除（超过 7 天）
```

---

### 📊 磁盘空间估算

#### **小型项目（1万请求/天）**

```
单条日志: ~500 字节
每天请求: 10,000
每天日志: 5 MB
压缩后: ~1 MB

7 天总计: 7 MB（不压缩）
7 天总计: ~1.5 MB（压缩）
```

#### **中型项目（10万请求/天）**

```
每天日志: 50 MB
压缩后: ~10 MB

7 天总计: 70 MB（压缩）
```

#### **大型项目（100万请求/天）**

```
每天日志: 500 MB
压缩后: ~100 MB

7 天总计: 700 MB（压缩）
```

**结论：即使是大型项目，7天日志也不到 1GB！**

---

### 🔧 手动管理（可选）

#### **查看日志大小**

```bash
# 使用日志搜索工具
ssh root@123.57.5.50 "/root/log_search.sh size"

# 或手动查看
ssh root@123.57.5.50 "du -sh /var/log/fastapi/*"
```

#### **查看归档日志**

```bash
# 列出所有归档
ssh root@123.57.5.50 "ls -lh /var/log/fastapi/*.gz"

# 查看归档内容（解压查看）
ssh root@123.57.5.50 "zcat /var/log/fastapi/app.log.2026-01-06.gz | head -50"

# 搜索归档内容
ssh root@123.57.5.50 "zgrep 'ERROR' /var/log/fastapi/app.log.*.gz"
```

#### **手动清理旧日志**

```bash
# 清理 14 天前的日志
ssh root@123.57.5.50 "/root/log_search.sh clean"

# 或手动删除
ssh root@123.57.5.50 "find /var/log/fastapi -name '*.gz' -mtime +14 -delete"
```

---

### 📈 如果日志真的太大

#### **方案 1：调整保留时间**

```python
# app/core/logging_config.py

# 改为保留 3 天
logger.add(
    LOG_DIR / "app.log",
    rotation="00:00",
    retention="3 days",  # ← 改这里
    compression="gz",
)
```

#### **方案 2：按大小轮转**

```python
# 达到 50MB 就轮转
logger.add(
    LOG_DIR / "app.log",
    rotation="50 MB",  # ← 更小的阈值
    retention="7 days",
    compression="gz",
)
```

#### **方案 3：只记录 WARNING 以上**

```python
# 生产环境只记录警告和错误
logger.add(
    LOG_DIR / "app.log",
    level="WARNING",  # ← 改为 WARNING
    rotation="00:00",
    retention="7 days",
)
```

#### **方案 4：导出到外部存储**

```bash
# 定期上传到云存储（阿里云 OSS）
#!/bin/bash
# /root/backup_logs.sh

DATE=$(date +%Y%m%d)
cd /var/log/fastapi

# 打包所有归档
tar czf logs_$DATE.tar.gz *.gz

# 上传到 OSS（需要配置 ossutil）
ossutil cp logs_$DATE.tar.gz oss://your-bucket/logs/

# 删除本地备份
rm logs_$DATE.tar.gz
```

---

## 🔍 问题 2：搜索特定用户的日志

### ✅ 使用日志搜索工具

#### **搜索特定用户**

```bash
# 搜索用户 alice 的所有日志
ssh root@123.57.5.50 "/root/log_search.sh user alice"

# 输出示例：
# 🔍 搜索用户: alice
# ================================
# 
# 📝 当前日志：
# 123:2026-01-07 12:00:00.123 | INFO | 📨 Incoming: POST /api/v1/users
#     user: alice
# 456:2026-01-07 12:00:01.234 | INFO | 👤 User Action: alice CREATE Order
#     user_id: 1
#     username: alice
```

#### **搜索特定 IP**

```bash
# 搜索来自某个 IP 的所有请求
ssh root@123.57.5.50 "/root/log_search.sh ip 183.242.40.65"

# 输出示例：
# 🔍 搜索 IP: 183.242.40.65
# ================================
# 
# 📝 当前日志：
# ...
# 
# 📊 请求统计：
# 总请求数: 45
# 错误请求: 3
```

#### **搜索错误日志**

```bash
# 搜索所有错误
ssh root@123.57.5.50 "/root/log_search.sh error"
```

#### **搜索慢查询**

```bash
# 搜索所有慢查询（>1秒）
ssh root@123.57.5.50 "/root/log_search.sh slow"
```

#### **搜索今天的日志**

```bash
# 只看今天的
ssh root@123.57.5.50 "/root/log_search.sh today"
```

#### **搜索时间范围**

```bash
# 搜索特定时间范围
ssh root@123.57.5.50 "/root/log_search.sh range 2026-01-01 2026-01-07"
```

---

### 📝 直接使用 grep/jq 搜索

#### **搜索用户（文本日志）**

```bash
# 搜索当前日志
ssh root@123.57.5.50 "grep 'user.*alice' /var/log/fastapi/app.log"

# 搜索归档日志
ssh root@123.57.5.50 "zgrep 'user.*alice' /var/log/fastapi/app.log.*.gz"

# 统计该用户的请求数
ssh root@123.57.5.50 "grep 'user.*alice' /var/log/fastapi/app.log | wc -l"
```

#### **搜索用户（JSON 日志）**

```bash
# 使用 jq 搜索（更精确）
ssh root@123.57.5.50 "cat /var/log/fastapi/access.json | jq 'select(.record.extra.user == \"alice\")'"

# 只显示关键信息
ssh root@123.57.5.50 "cat /var/log/fastapi/access.json | jq -r 'select(.record.extra.user == \"alice\") | \"\(.time) \(.message)\"'"

# 统计该用户的请求
ssh root@123.57.5.50 "cat /var/log/fastapi/access.json | jq -r 'select(.record.extra.user == \"alice\")' | jq -s 'length'"
```

---

### 🎨 高级搜索示例

#### **1. 搜索用户的所有失败请求**

```bash
ssh root@123.57.5.50 "grep 'user.*alice' /var/log/fastapi/app.log | grep -E '❌|⚠️'"
```

#### **2. 搜索用户的慢查询**

```bash
ssh root@123.57.5.50 "grep 'user.*alice' /var/log/fastapi/app.log | grep 'Slow request'"
```

#### **3. 搜索用户的登录记录**

```bash
ssh root@123.57.5.50 "grep 'user.*alice' /var/log/fastapi/app.log | grep 'login'"
```

#### **4. 统计用户的 API 调用**

```bash
ssh root@123.57.5.50 << 'EOF'
cat /var/log/fastapi/access.json | \
jq -r 'select(.record.extra.user == "alice") | .record.extra.path' | \
sort | uniq -c | sort -rn
EOF

# 输出示例：
#   45 /api/v1/users/me
#   23 /api/v1/orders
#   12 /api/v1/products
```

#### **5. 分析用户的响应时间**

```bash
ssh root@123.57.5.50 << 'EOF'
cat /var/log/fastapi/access.json | \
jq -r 'select(.record.extra.user == "alice") | .record.extra.process_time' | \
awk '{sum+=$1; count++; if($1>max) max=$1; if(min=="" || $1<min) min=$1} 
     END {print "平均:", sum/count "s"; print "最快:", min "s"; print "最慢:", max "s"}'
EOF
```

#### **6. 查看用户的请求时间分布**

```bash
ssh root@123.57.5.50 << 'EOF'
cat /var/log/fastapi/access.json | \
jq -r 'select(.record.extra.user == "alice") | .time' | \
cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c

# 输出示例：
#   15 09  # 上午 9 点
#   23 10  # 上午 10 点
#   18 14  # 下午 2 点
EOF
```

---

## 🛠️ 实用工具命令

### 快速命令速查表

```bash
# ===== 用户相关 =====
# 搜索用户 alice
/root/log_search.sh user alice

# 统计用户请求数
grep 'user.*alice' /var/log/fastapi/app.log | wc -l

# 用户的最后 10 次操作
grep 'user.*alice' /var/log/fastapi/app.log | tail -10

# ===== IP 相关 =====
# 搜索 IP
/root/log_search.sh ip 1.2.3.4

# TOP 10 活跃 IP
cat /var/log/fastapi/app.log | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq -c | sort -rn | head -10

# ===== 错误相关 =====
# 所有错误
/root/log_search.sh error

# 最近 10 个错误
grep -E 'ERROR|CRITICAL' /var/log/fastapi/error.log | tail -10

# ===== 性能相关 =====
# 慢查询
/root/log_search.sh slow

# 平均响应时间
cat /var/log/fastapi/access.json | jq -r '.record.extra.process_time' | awk '{sum+=$1; count++} END {print sum/count "s"}'

# ===== 时间相关 =====
# 今天的日志
/root/log_search.sh today

# 特定时间段
/root/log_search.sh range 2026-01-01 2026-01-07

# ===== 管理相关 =====
# 查看大小
/root/log_search.sh size

# 清理旧日志
/root/log_search.sh clean
```

---

## 📊 日志分析最佳实践

### 1. 定期检查日志大小

```bash
# 添加到 crontab
0 0 * * * /root/log_search.sh size >> /var/log/log-size-report.log
```

### 2. 监控特定用户

```bash
# 创建用户监控脚本
cat > /root/monitor_user.sh << 'EOF'
#!/bin/bash
USER="admin"
COUNT=$(grep "user.*$USER" /var/log/fastapi/app.log | wc -l)
ERRORS=$(grep "user.*$USER" /var/log/fastapi/app.log | grep -E "❌|ERROR" | wc -l)

echo "用户 $USER 今日统计："
echo "总请求: $COUNT"
echo "错误请求: $ERRORS"

if [ $ERRORS -gt 10 ]; then
    echo "⚠️ 警告：错误过多！"
fi
EOF
```

### 3. 导出用户报告

```bash
ssh root@123.57.5.50 << 'EOF'
# 生成用户 alice 的完整报告
{
  echo "用户报告: alice"
  echo "日期: $(date)"
  echo "================================"
  echo ""
  echo "请求统计:"
  grep 'user.*alice' /var/log/fastapi/app.log | wc -l
  echo ""
  echo "错误记录:"
  grep 'user.*alice' /var/log/fastapi/app.log | grep -E '❌|ERROR'
} > /tmp/alice_report.txt

cat /tmp/alice_report.txt
EOF
```

---

## 🎯 总结

### 日志文件太大？

✅ **不用担心！系统已自动管理：**
- 每天自动轮转
- 自动 gzip 压缩（节省 75% 空间）
- 自动删除 7 天前的日志
- 错误日志达到 100MB 自动轮转

**即使每天 10 万请求，7 天日志也只有约 70MB！**

### 如何搜索特定用户？

✅ **多种方式：**

1. **简单搜索**
   ```bash
   /root/log_search.sh user alice
   ```

2. **grep 搜索**
   ```bash
   grep 'user.*alice' /var/log/fastapi/app.log
   ```

3. **jq JSON 搜索**
   ```bash
   cat /var/log/fastapi/access.json | jq 'select(.record.extra.user == "alice")'
   ```

4. **搜索归档**
   ```bash
   zgrep 'user.*alice' /var/log/fastapi/app.log.*.gz
   ```

---

## 📚 工具清单

| 工具 | 位置 | 用途 |
|------|------|------|
| `view_logs.sh` | `/root/` | 查看日志 |
| `log_search.sh` | `/root/` | 搜索和管理日志 |
| `grep/zgrep` | 系统自带 | 文本搜索 |
| `jq` | 需安装 | JSON 搜索 |

**安装 jq（如需要）：**
```bash
ssh root@123.57.5.50 "yum install -y jq"
```

---

*最后更新：2026-01-07*
