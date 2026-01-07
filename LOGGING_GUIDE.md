# 📊 API 访问日志系统文档

## 🎯 功能概述

项目现在配置了完整的日志系统，包括：
- ✅ 结构化日志（Loguru）
- ✅ 请求/响应日志
- ✅ 错误追踪
- ✅ 性能监控
- ✅ 用户行为记录
- ✅ 安全事件记录

---

## 📁 日志文件

### 生产环境（服务器）

```
/var/log/fastapi/
├── app.log            # 应用日志（INFO 级别）
├── error.log          # 错误日志（ERROR 级别）
├── access.json        # 访问日志（JSON 格式）
└── app.log.2024-01-06.gz  # 自动归档的旧日志
```

### 开发环境（本地）

```
logs/
├── app.log
├── error.log
└── access.json
```

---

## 📊 日志格式

### 标准日志格式

```
2026-01-07 12:00:00.123 | INFO     | app.main:root:78 | 📨 Incoming: GET /api/v1/users
```

**格式说明：**
- 时间戳：`2026-01-07 12:00:00.123`
- 级别：`INFO | DEBUG | WARNING | ERROR | CRITICAL`
- 位置：`app.main:root:78` (文件:函数:行号)
- 消息：日志内容

### JSON 日志格式

```json
{
  "text": "✅ GET /api/v1/users → 200",
  "record": {
    "elapsed": {"repr": "0:00:00.123456", "seconds": 0.123456},
    "exception": null,
    "extra": {
      "request_id": "1704614400000",
      "method": "GET",
      "path": "/api/v1/users",
      "status_code": 200,
      "process_time": "0.045s",
      "client_ip": "183.242.40.65",
      "user": "test_user"
    },
    "file": {"name": "logging.py", "path": "app/middleware/logging.py"},
    "function": "dispatch",
    "level": {"icon": "ℹ️", "name": "INFO", "no": 20},
    "line": 78,
    "message": "✅ GET /api/v1/users → 200",
    "module": "logging",
    "name": "app.middleware.logging",
    "process": {"id": 12345, "name": "MainProcess"},
    "thread": {"id": 139876543210000, "name": "MainThread"},
    "time": {"repr": "2026-01-07 12:00:00.123456+00:00", "timestamp": 1704614400.123456}
  }
}
```

---

## 🔍 日志查看

### 命令行查看

```bash
# 查看访问日志
ssh root@123.57.5.50 "tail -50 /var/log/fastapi/app.log"

# 查看错误日志
ssh root@123.57.5.50 "tail -50 /var/log/fastapi/error.log"

# 实时查看日志
ssh root@123.57.5.50 "tail -f /var/log/fastapi/app.log"

# 搜索特定内容
ssh root@123.57.5.50 "grep 'ERROR' /var/log/fastapi/app.log"
```

### 使用日志查看工具

```bash
# 上传到服务器
scp view_logs.sh root@123.57.5.50:/root/
ssh root@123.57.5.50 "chmod +x /root/view_logs.sh"

# 查看访问日志
ssh root@123.57.5.50 "/root/view_logs.sh access"

# 查看错误日志
ssh root@123.57.5.50 "/root/view_logs.sh error"

# 查看统计信息
ssh root@123.57.5.50 "/root/view_logs.sh stats"

# 实时查看
ssh root@123.57.5.50 "/root/view_logs.sh live"

# 搜索关键词
ssh root@123.57.5.50 "/root/view_logs.sh search '用户登录'"
```

---

## 📝 日志级别

| 级别 | 图标 | 用途 | 示例 |
|------|------|------|------|
| **DEBUG** | 🔍 | 调试信息 | 变量值、函数调用 |
| **INFO** | ℹ️ | 一般信息 | 请求处理、操作记录 |
| **SUCCESS** | ✅ | 成功操作 | 数据库连接成功 |
| **WARNING** | ⚠️ | 警告信息 | 慢查询、4xx 错误 |
| **ERROR** | ❌ | 错误信息 | 5xx 错误、异常 |
| **CRITICAL** | 🚨 | 严重错误 | 系统崩溃、安全事件 |

---

## 🎨 日志特性

### 1. 请求日志

自动记录所有 HTTP 请求：

```
2026-01-07 12:00:00.123 | INFO | 📨 Incoming: POST /api/v1/auth/login
  request_id: 1704614400000
  method: POST
  path: /api/v1/auth/login
  client_ip: 183.242.40.65
  user: anonymous

2026-01-07 12:00:00.456 | INFO | ✅ POST /api/v1/auth/login → 200
  request_id: 1704614400000
  status_code: 200
  process_time: 0.333s
  user: test_user
```

### 2. 慢查询警告

自动检测响应时间超过 1 秒的请求：

```
2026-01-07 12:00:01.789 | WARNING | 🐌 Slow request: GET /api/v1/users?limit=1000 took 1.234s
```

### 3. 错误追踪

记录完整的堆栈信息：

```
2026-01-07 12:00:00.000 | ERROR | 💥 Error: POST /api/v1/users
Traceback (most recent call last):
  File "app/api/v1/endpoints/users.py", line 45, in create_user
    user = await user_crud.create(db, user_in)
  File "app/crud/user.py", line 23, in create
    db.add(db_user)
sqlalchemy.exc.IntegrityError: UNIQUE constraint failed: users.email
```

### 4. 用户行为记录

记录用户的关键操作：

```python
# 在业务代码中使用
from app.middleware import APIAccessLogger

# 记录用户操作
APIAccessLogger.log_user_action(
    user_id=user.id,
    username=user.username,
    action="CREATE",
    resource="Order",
    details={"order_id": order.id, "amount": 100.00}
)

# 生成日志：
# 👤 User Action: alice CREATE Order
#   user_id: 1
#   username: alice
#   action: CREATE
#   resource: Order
#   details: {"order_id": 123, "amount": 100.00}
```

### 5. 安全事件记录

记录安全相关事件：

```python
# 记录登录失败
APIAccessLogger.log_security_event(
    event_type="LOGIN_FAILED",
    severity="MEDIUM",
    details={
        "username": "admin",
        "ip": "192.168.1.100",
        "reason": "Invalid password"
    }
)

# 记录未授权访问
APIAccessLogger.log_security_event(
    event_type="UNAUTHORIZED_ACCESS",
    severity="HIGH",
    details={
        "user": "guest",
        "resource": "/api/v1/admin/users",
        "action": "DELETE"
    }
)
```

---

## 📈 日志分析

### 统计今日请求

```bash
TODAY=$(date +%Y-%m-%d)
grep "$TODAY" /var/log/fastapi/app.log | grep "Incoming" | wc -l
```

### 统计状态码分布

```bash
grep "→" /var/log/fastapi/app.log | \
  grep -oE "→ [0-9]{3}" | \
  sort | uniq -c | sort -rn
```

### 查找慢查询

```bash
grep "Slow request" /var/log/fastapi/app.log | tail -20
```

### 查找错误请求

```bash
grep "ERROR\|CRITICAL" /var/log/fastapi/error.log | tail -20
```

### TOP 10 访问 IP

```bash
grep "client_ip" /var/log/fastapi/app.log | \
  grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
  sort | uniq -c | sort -rn | head -10
```

---

## 🔧 配置说明

### 日志配置文件

`app/core/logging_config.py`

**关键配置：**

```python
# 日志轮转：每天午夜
rotation="00:00"

# 保留时间：7 天
retention="7 days"

# 压缩：使用 gzip
compression="gz"

# 慢查询阈值：1 秒
if process_time > 1.0:
    logger.warning(f"🐌 Slow request: ...")
```

### 修改日志级别

```python
# app/core/logging_config.py

# 开发环境：DEBUG
logger.add(sys.stdout, level="DEBUG")

# 生产环境：INFO
logger.add(LOG_DIR / "app.log", level="INFO")
```

---

## 🚀 生产环境部署

### 1. 创建日志目录

```bash
ssh root@123.57.5.50 "mkdir -p /var/log/fastapi && chmod 755 /var/log/fastapi"
```

### 2. 安装依赖

```bash
ssh root@123.57.5.50 "cd /var/www/fastapi-backend && source venv/bin/activate && pip install loguru"
```

### 3. 重启服务

```bash
ssh root@123.57.5.50 "systemctl restart fastapi-backend"
```

### 4. 验证日志

```bash
ssh root@123.57.5.50 "tail -f /var/log/fastapi/app.log"
```

---

## 📊 日志监控告警

### 配置日志监控（可选）

```bash
# 每小时检查错误日志
crontab -e
```

```cron
0 * * * * /root/check_errors.sh >> /var/log/error-alert.log 2>&1
```

**check_errors.sh：**
```bash
#!/bin/bash
ERROR_COUNT=$(grep "ERROR\|CRITICAL" /var/log/fastapi/error.log | grep "$(date +%Y-%m-%d)" | wc -l)

if [ $ERROR_COUNT -gt 10 ]; then
    echo "[$(date)] ⚠️ 发现 $ERROR_COUNT 个错误！"
    # 可以发送邮件或调用告警 API
fi
```

---

## 🎯 总结

### 已实现功能

- ✅ 结构化日志（Loguru）
- ✅ 自动请求日志
- ✅ 性能监控（慢查询）
- ✅ 错误追踪（完整堆栈）
- ✅ 日志轮转和压缩
- ✅ JSON 格式导出
- ✅ 用户行为记录
- ✅ 安全事件记录

### 日志优势

- 📊 **详细**：记录所有请求细节
- 🎨 **美观**：彩色图标，易于阅读
- 🔍 **可搜索**：支持关键词搜索
- 📈 **可分析**：JSON 格式便于分析
- 💾 **节省空间**：自动压缩归档
- ⚡ **高性能**：异步日志，不影响性能

---

*最后更新：2026-01-07*
