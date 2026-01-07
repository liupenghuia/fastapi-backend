# 🗄️ 宝塔数据库完全使用指南

## 📋 目录

1. [MySQL 服务管理](#mysql-服务管理)
2. [创建和管理数据库](#创建和管理数据库)
3. [phpMyAdmin 使用](#phpmyadmin-使用)
4. [数据库备份与恢复](#数据库备份与恢复)
5. [性能优化](#性能优化)
6. [FastAPI 连接 MySQL](#fastapi-连接-mysql)
7. [常见问题](#常见问题)

---

## 🚀 MySQL 服务管理

### 1. 启动 MySQL

在宝塔面板中：

**方式 1：通过软件商店**
1. 左侧菜单 → **"软件商店"**
2. 找到 **"MySQL"** → 点击 **"设置"**
3. 点击 **"启动"** 按钮

**方式 2：通过首页**
1. **"首页"** → 服务状态
2. 找到 **MySQL** → 点击 **"启动"**

**方式 3：SSH 命令行**
```bash
# 启动 MySQL
systemctl start mysqld

# 设置开机自启
systemctl enable mysqld

# 查看状态
systemctl status mysqld
```

### 2. 查看 MySQL 信息

**软件商店** → **MySQL** → **"设置"**：

显示信息：
- 运行状态
- 端口（默认 3306）
- root 密码
- 配置文件路径
- 日志文件路径

### 3. 修改 root 密码

**软件商店** → **MySQL** → **"设置"** → **"修改密码"**

或通过命令行：
```bash
bt
# 选择 7 - 强制修改MySQL管理员密码
```

---

## 📦 创建和管理数据库

### 1. 创建数据库

**左侧菜单** → **"数据库"** → **"添加数据库"**

填写信息：
```
数据库名: fastapi_db
用户名: fastapi_user
密码: [自动生成] 或 [自定义强密码]
访问权限: 本地服务器 (127.0.0.1)
备注: FastAPI 项目数据库
```

点击 **"提交"** 完成创建。

### 2. 管理数据库

数据库列表操作：

| 操作 | 说明 |
|------|------|
| 🔧 **管理** | 修改密码、访问权限 |
| 📊 **phpMyAdmin** | 打开 Web 管理界面 |
| 💾 **备份** | 手动备份数据库 |
| 📥 **导入** | 导入 .sql 文件 |
| 🗑️ **删除** | 删除数据库（危险操作）|

### 3. 修改数据库权限

点击数据库 → **"管理"**：

**访问权限选项：**
- `本地服务器` - 只允许 127.0.0.1 访问（推荐）
- `所有人` - 允许任何IP访问（不安全）
- `指定IP` - 只允许特定IP访问

**生产环境建议：** 使用"本地服务器"，FastAPI 和 MySQL 在同一台服务器。

### 4. 查看数据库信息

数据库列表显示：
- 数据库名
- 用户名
- 大小
- 创建时间
- 备注

---

## 🌐 phpMyAdmin 使用

### 1. 安装 phpMyAdmin

**软件商店** → 搜索 **"phpMyAdmin"** → **"安装"**

选择版本：推荐最新稳定版

### 2. 访问 phpMyAdmin

**方式 1：通过宝塔**
- **"数据库"** → 点击数据库的 **"phpMyAdmin"** 图标
- 自动使用该数据库账号登录

**方式 2：直接访问**
- 浏览器访问：`http://你的IP:888/phpmyadmin`
- 输入数据库用户名和密码

### 3. phpMyAdmin 常用功能

#### **浏览数据**
1. 左侧选择数据库
2. 点击表名
3. 查看/编辑数据

#### **执行 SQL 语句**
1. 顶部菜单 → **"SQL"**
2. 输入 SQL 语句
3. 点击 **"执行"**

示例：
```sql
-- 查询所有用户
SELECT * FROM users;

-- 创建表
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2)
);

-- 插入数据
INSERT INTO items (name, price) VALUES ('商品1', 99.99);
```

#### **导入数据**
1. 选择数据库
2. 顶部 → **"导入"**
3. 选择 .sql 文件
4. 点击 **"执行"**

#### **导出数据**
1. 选择数据库/表
2. 顶部 → **"导出"**
3. 选择格式（SQL、CSV 等）
4. 点击 **"执行"**

### 4. phpMyAdmin 安全设置

**软件商店** → **phpMyAdmin** → **"设置"**：

- 修改访问端口（默认 888）
- 禁用外网访问（推荐）
- 设置访问密码

---

## 💾 数据库备份与恢复

### 1. 手动备份

**方式 1：宝塔面板**
1. **"数据库"** → 点击数据库
2. 点击 **"备份"**
3. 备份文件保存在：`/www/backup/database/`

**方式 2：phpMyAdmin**
1. 选择数据库 → **"导出"**
2. 下载 .sql 文件

**方式 3：命令行**
```bash
# 备份单个数据库
mysqldump -u root -p fastapi_db > fastapi_db_backup.sql

# 备份所有数据库
mysqldump -u root -p --all-databases > all_databases_backup.sql

# 压缩备份
mysqldump -u root -p fastapi_db | gzip > fastapi_db_backup.sql.gz
```

### 2. 自动备份（推荐）

**左侧菜单** → **"计划任务"** → **"添加任务"**

配置：
```
任务类型: 备份数据库
任务名称: 自动备份FastAPI数据库
执行周期: 每天 2:00
备份到: 服务器磁盘
备份数据库: fastapi_db
保留最新: 7 份
```

**高级选项：**
- 备份到云存储（阿里云OSS、腾讯云COS）
- 备份后通知（邮件、钉钉、微信）

### 3. 数据恢复

**方式 1：宝塔面板**
1. **"数据库"** → 点击数据库 → **"导入"**
2. 选择备份文件
3. 点击 **"导入"**

**方式 2：命令行**
```bash
# 恢复数据库
mysql -u root -p fastapi_db < fastapi_db_backup.sql

# 从压缩文件恢复
gunzip < fastapi_db_backup.sql.gz | mysql -u root -p fastapi_db
```

### 4. 备份文件管理

**文件** → `/www/backup/database/`

操作：
- 下载备份到本地（双重保险）
- 删除旧备份（节省空间）
- 上传备份文件

---

## ⚡ 性能优化

### 1. 查看 MySQL 配置

**软件商店** → **MySQL** → **"设置"** → **"配置修改"**

或编辑文件：
```bash
# MySQL 5.7 配置文件
/etc/my.cnf
```

### 2. 常用优化参数

```ini
[mysqld]
# 连接数
max_connections = 500

# 查询缓存（MySQL 5.7）
query_cache_size = 64M
query_cache_type = 1

# InnoDB 缓存池大小（建议物理内存的 50-80%）
innodb_buffer_pool_size = 1G

# 日志文件大小
innodb_log_file_size = 256M

# 字符集
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# 慢查询日志
slow_query_log = 1
slow_query_log_file = /www/server/data/slow.log
long_query_time = 2
```

修改后重启 MySQL：
```bash
systemctl restart mysqld
```

### 3. 性能监控

**软件商店** → **MySQL** → **"性能调整"**

查看：
- QPS（每秒查询数）
- 缓存命中率
- 活动连接数
- 慢查询数量

### 4. 慢查询优化

**查看慢查询日志：**
```bash
tail -f /www/server/data/slow.log
```

**分析和优化：**
1. 找出慢查询 SQL
2. 添加索引
3. 优化查询语句
4. 使用 EXPLAIN 分析执行计划

---

## 🔌 FastAPI 连接 MySQL

### 1. 更新依赖

修改 `requirements.txt`：
```txt
# 移除 SQLite
# aiosqlite>=0.19.0

# 添加 MySQL
aiomysql>=0.2.0
pymysql>=1.1.0
```

安装：
```bash
source venv/bin/activate
pip install aiomysql pymysql
```

### 2. 修改数据库配置

编辑 `.env` 文件：
```env
# 旧配置（SQLite）
# DATABASE_URL="sqlite+aiosqlite:///./app.db"

# 新配置（MySQL）
DATABASE_URL="mysql+aiomysql://fastapi_user:密码@127.0.0.1:3306/fastapi_db?charset=utf8mb4"
```

**参数说明：**
- `fastapi_user` - 数据库用户名
- `密码` - 数据库密码（在宝塔创建时生成）
- `127.0.0.1` - 数据库地址（本地）
- `3306` - 端口
- `fastapi_db` - 数据库名

### 3. 修改数据库引擎配置

编辑 `app/core/database.py`：

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# 创建异步引擎
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=True,
    pool_size=10,           # 连接池大小
    max_overflow=20,        # 最大溢出连接数
    pool_pre_ping=True,     # 连接前检查是否可用
    pool_recycle=3600       # 连接回收时间（秒）
)

# 创建会话工厂
async_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)
```

### 4. 初始化数据库

```bash
# 重启 FastAPI 服务
systemctl restart fastapi-backend

# 查看日志，确认连接成功
tail -f /var/log/fastapi-access.log
tail -f /var/log/fastapi-error.log
```

### 5. 迁移现有数据（可选）

如果需要从 SQLite 迁移到 MySQL：

```bash
# 1. 导出 SQLite 数据
sqlite3 app.db .dump > dump.sql

# 2. 转换为 MySQL 格式（需要手动调整）
# 3. 导入到 MySQL
mysql -u fastapi_user -p fastapi_db < dump_mysql.sql
```

### 6. 连接池监控

在 FastAPI 中查看连接池状态：

```python
# app/main.py
@app.get("/health/db")
async def db_health():
    from app.core.database import engine
    
    return {
        "pool_size": engine.pool.size(),
        "checked_out": engine.pool.checkedout(),
        "overflow": engine.pool.overflow(),
        "status": "healthy"
    }
```

---

## ❗ 常见问题

### 1. MySQL 启动失败

**原因：** 内存不足、端口被占用

**解决：**
```bash
# 查看错误日志
tail -f /www/server/data/mysql-error.log

# 检查端口占用
netstat -tlnp | grep 3306

# 释放内存
systemctl restart mysqld
```

### 2. 连接被拒绝

**错误：** `ERROR 1045 (28000): Access denied`

**解决：**
1. 检查用户名密码是否正确
2. 确认访问权限设置
3. 重置密码：宝塔 → 数据库 → 修改密码

### 3. 无法远程连接

**原因：** 防火墙未开放端口、MySQL 权限设置

**解决：**
```bash
# 1. 开放防火墙端口
# 宝塔 → 安全 → 放行端口 3306

# 2. 修改数据库权限
# 宝塔 → 数据库 → 管理 → 访问权限改为"所有人"

# 3. 或者添加特定IP
GRANT ALL PRIVILEGES ON fastapi_db.* TO 'fastapi_user'@'你的IP' IDENTIFIED BY '密码';
FLUSH PRIVILEGES;
```

**安全建议：** 生产环境不要开放 3306 端口到外网！

### 4. 数据库占用空间过大

**查看表大小：**
```sql
SELECT 
    table_name,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'fastapi_db'
ORDER BY (data_length + index_length) DESC;
```

**优化：**
```sql
-- 优化表
OPTIMIZE TABLE table_name;

-- 清理日志
PURGE BINARY LOGS BEFORE '2026-01-01 00:00:00';
```

### 5. Too many connections

**错误：** `ERROR 1040 (HY000): Too many connections`

**解决：**
```bash
# 临时增加连接数
mysql -u root -p
SET GLOBAL max_connections = 500;

# 永久修改
# 编辑 /etc/my.cnf
max_connections = 500

# 重启 MySQL
systemctl restart mysqld
```

---

## 🎯 最佳实践

### 1. 安全建议

- ✅ 使用强密码
- ✅ 不要开放 3306 到外网
- ✅ 定期备份数据
- ✅ 使用 `127.0.0.1` 而不是 `所有人`
- ✅ 定期更新 MySQL 版本

### 2. 性能建议

- ✅ 合理设置 `innodb_buffer_pool_size`
- ✅ 使用索引优化查询
- ✅ 启用慢查询日志，找出慢查询
- ✅ 使用连接池
- ✅ 定期清理日志文件

### 3. 备份策略

- ✅ 每天自动备份
- ✅ 保留7天备份
- ✅ 重要数据备份到云存储
- ✅ 定期测试备份恢复

### 4. 监控告警

- ✅ 监控磁盘空间
- ✅ 监控慢查询数量
- ✅ 监控连接数
- ✅ 设置告警通知

---

## 📊 MySQL vs SQLite 对比

| 特性 | SQLite | MySQL |
|------|--------|-------|
| 性能 | 中等 | 高 |
| 并发 | 低（写锁定）| 高 |
| 扩展性 | 差 | 好 |
| 备份 | 文件复制 | 专业工具 |
| 适用场景 | 开发/小型应用 | 生产环境 |

**建议：**
- 开发环境：SQLite（简单）
- 生产环境：MySQL（性能好）

---

## 🔧 快速命令参考

```bash
# 启动/停止/重启 MySQL
systemctl start mysqld
systemctl stop mysqld
systemctl restart mysqld

# 查看状态
systemctl status mysqld

# 查看进程
ps aux | grep mysql

# 查看端口
netstat -tlnp | grep 3306

# 登录 MySQL
mysql -u root -p

# 查看数据库列表
mysql -u root -p -e "SHOW DATABASES;"

# 备份
mysqldump -u root -p fastapi_db > backup.sql

# 恢复
mysql -u root -p fastapi_db < backup.sql

# 查看错误日志
tail -f /www/server/data/mysql-error.log

# 查看慢查询日志
tail -f /www/server/data/slow.log
```

---

## 📚 参考资源

- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [SQLAlchemy 异步文档](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)
- [宝塔 MySQL 优化](https://www.bt.cn/bbs/forum-39-1.html)

---

**祝你使用愉快！🚀**
