# 🎓 宝塔面板数据库实践教程

## 📚 学习目标

通过本教程，你将学会：
- ✅ 在宝塔面板中管理 MySQL 服务
- ✅ 创建和管理数据库
- ✅ 使用 phpMyAdmin 操作数据
- ✅ 执行 SQL 查询
- ✅ 备份和恢复数据库
- ✅ 理解数据库权限和安全

**预计学习时间：30-45 分钟**

---

## 🚀 准备工作

### 1. 访问宝塔面板

打开浏览器访问：
```
https://123.57.5.50:8888
```

看到证书警告时：
- 点击 **"高级"**
- 点击 **"继续前往 123.57.5.50（不安全）"**

### 2. 登录面板

输入你的用户名和密码。

**如果忘记密码**，SSH 到服务器执行：
```bash
ssh root@123.57.5.50
bt default
```

---

## 📖 实践模块一：MySQL 服务管理

### 任务 1.1：查看 MySQL 状态

**步骤：**
1. 登录宝塔面板
2. 点击左侧 **"首页"**
3. 向下滚动找到 **"服务状态"** 区域
4. 找到 **MySQL** 服务

**观察内容：**
- 运行状态：✅ 正在运行
- 端口：3306
- 启动时间

### 任务 1.2：查看 MySQL 详细信息

**步骤：**
1. 点击左侧菜单 **"软件商店"**
2. 在"已安装"标签页找到 **MySQL**
3. 点击 **"设置"** 按钮

**你会看到：**
- MySQL 版本信息
- 运行状态
- 配置文件路径
- root 密码（重要！记下来）
- 端口号
- 数据目录

📝 **记录：** 把 root 密码记录下来，后面会用到。 （01bb04dbd5c81e59）

### 任务 1.3：查看 MySQL 配置

在 MySQL 设置页面：
1. 点击 **"配置修改"** 标签
2. 查看配置文件内容

**重要配置项：**
```ini
[mysqld]
port = 3306                    # 端口号
max_connections = 1000         # 最大连接数
character-set-server = utf8mb4 # 字符集
```

**不要修改**，只是查看了解。

---

## 📊 实践模块二：创建和管理数据库

### 任务 2.1：创建第一个数据库

**步骤：**
1. 点击左侧菜单 **"数据库"**
2. 点击 **"添加数据库"** 按钮
3. 填写信息：
   ```
   数据库名: testdb
   用户名: testuser
   密码: [点击"随机密码"或自己设置]
   访问权限: 本地服务器
   备注: 我的第一个数据库
   ```
4. 点击 **"提交"**

**结果：**
- 数据库列表中会出现新创建的 `testdb`
- 显示数据库名、用户名、大小、创建时间

📝 **记录：** 把用户名和密码记录下来：
```
数据库: testdb
用户: testuser
密码: _______________
```

### 任务 2.2：查看数据库列表

在 **"数据库"** 页面观察：

| 列 | 说明 |
|-----|------|
| 数据库 | 数据库名称 |
| 用户名 | 访问该数据库的用户 |
| 大小 | 当前数据库占用空间 |
| 备注 | 数据库说明 |
| 操作 | 管理按钮 |

**操作按钮：**
- 🔧 **管理** - 修改密码、权限
- 📊 **phpMyAdmin** - 打开数据库管理界面
- 💾 **备份** - 手动备份
- 📥 **导入** - 导入 SQL 文件
- 🗑️ **删除** - 删除数据库

### 任务 2.3：修改数据库权限

**步骤：**
1. 找到 `testdb` 数据库
2. 点击 🔧 **"管理"**
3. 查看当前设置：
   - 用户名
   - 访问权限
   - 密码（隐藏）

**权限选项说明：**
- **本地服务器** - 只允许 127.0.0.1 访问（最安全）
- **所有人** - 允许任何IP访问（不安全，不推荐）
- **指定IP** - 只允许特定IP访问

**实践：** 保持 "本地服务器"，点击 **"取消"** 不修改。

### 任务 2.4：再创建一个数据库

重复任务 2.1，创建：
```
数据库名: practice_db
用户名: practice_user
密码: [自动生成]
访问权限: 本地服务器
备注: 练习用数据库
```

现在你有 2 个数据库了！

---

## 🌐 实践模块三：使用 phpMyAdmin

### 任务 3.1：安装 phpMyAdmin

**检查是否已安装：**
1. 点击左侧 **"软件商店"**
2. 在搜索框输入 **"phpMyAdmin"**
3. 如果显示 **"已安装"**，跳到任务 3.2
4. 如果显示 **"安装"**，点击安装（需要几分钟）

### 任务 3.2：访问 phpMyAdmin

**方式 1：通过数据库列表**
1. **"数据库"** → 找到 `testdb`
2. 点击 📊 **"phpMyAdmin"** 图标
3. 自动登录到 phpMyAdmin

**方式 2：直接访问**
1. 浏览器新标签页访问：`http://123.57.5.50:888/phpmyadmin`
2. 输入：
   - 用户名：`testuser`
   - 密码：[你记录的密码]
   - 服务器：`127.0.0.1`
3. 登录

### 任务 3.3：熟悉 phpMyAdmin 界面

**左侧导航：**
- 显示所有数据库列表
- 点击数据库名展开表列表

**顶部菜单：**
- 🏠 主页
- 📊 SQL - 执行SQL语句
- 📤 导出 - 导出数据
- 📥 导入 - 导入数据
- ⚙️ 设置

**主区域：**
- 显示数据库结构和数据

### 任务 3.4：创建第一张表

**步骤：**
1. 在左侧点击 `testdb` 数据库
2. 点击顶部 **"结构"** 标签
3. 在 "创建表" 区域：
   ```
   名字: users
   字段数: 4
   ```
4. 点击 **"执行"**

**设计表结构：**

| 名称 | 类型 | 长度 | 默认值 | 属性 | NULL | 索引 | AUTO_INCREMENT |
|------|------|------|---------|------|------|------|----------------|
| id | INT | - | - | UNSIGNED | 否 | PRIMARY | ✅ |
| username | VARCHAR | 50 | - | - | 否 | - | - |
| email | VARCHAR | 100 | - | - | 否 | UNIQUE | - |
| created_at | TIMESTAMP | - | CURRENT_TIMESTAMP | - | 否 | - | - |

**填写说明：**
1. 第一行：
   - 名称：`id`
   - 类型：选择 `INT`
   - 勾选 `A_I`（AUTO_INCREMENT）
   - 索引：选择 `PRIMARY`

2. 第二行：
   - 名称：`username`
   - 类型：`VARCHAR`
   - 长度：`50`

3. 第三行：
   - 名称：`email`
   - 类型：`VARCHAR`
   - 长度：`100`
   - 索引：`UNIQUE`

4. 第四行：
   - 名称：`created_at`
   - 类型：`TIMESTAMP`
   - 默认值：`CURRENT_TIMESTAMP`

5. 点击 **"保存"**

🎉 **恭喜！你创建了第一张表！**

### 任务 3.5：插入数据

**方式 1：使用界面**

1. 点击表 `users`
2. 点击顶部 **"插入"** 标签
3. 填写数据：
   ```
   id: [留空，自动生成]
   username: zhangsan
   email: zhangsan@example.com
   created_at: [留空，自动生成]
   ```
4. 点击 **"执行"**

**方式 2：使用 SQL**

1. 点击顶部 **"SQL"** 标签
2. 输入以下 SQL：
   ```sql
   INSERT INTO users (username, email) VALUES 
   ('lisi', 'lisi@example.com'),
   ('wangwu', 'wangwu@example.com'),
   ('zhaoliu', 'zhaoliu@example.com');
   ```
3. 点击 **"执行"**

### 任务 3.6：查询数据

**简单查询：**

1. 点击顶部 **"SQL"** 标签
2. 输入：
   ```sql
   SELECT * FROM users;
   ```
3. 点击 **"执行"**

**条件查询：**
```sql
-- 查询特定用户
SELECT * FROM users WHERE username = 'zhangsan';

-- 查询最近创建的用户
SELECT * FROM users ORDER BY created_at DESC LIMIT 3;

-- 统计用户数量
SELECT COUNT(*) as total FROM users;
```

### 任务 3.7：修改数据

**使用 SQL：**
```sql
-- 更新用户邮箱
UPDATE users SET email = 'new_email@example.com' WHERE username = 'zhangsan';

-- 查看修改结果
SELECT * FROM users WHERE username = 'zhangsan';
```

**使用界面：**
1. 点击表 `users` → **"浏览"**
2. 找到要修改的行，点击 ✏️ **"编辑"**
3. 修改数据
4. 点击 **"执行"**

### 任务 3.8：删除数据

**谨慎操作！删除后无法恢复（除非有备份）**

```sql
-- 删除特定用户
DELETE FROM users WHERE username = 'wangwu';

-- 查看剩余数据
SELECT * FROM users;
```

### 任务 3.9：创建更多表

**练习：创建一个 products 表**

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入测试数据
INSERT INTO products (name, price, stock) VALUES
('笔记本电脑', 5999.00, 10),
('鼠标', 99.00, 50),
('键盘', 299.00, 30);

-- 查询
SELECT * FROM products;
```

---

## 💾 实践模块四：数据库备份

### 任务 4.1：手动备份数据库

**在宝塔面板：**
1. **"数据库"** → 找到 `testdb`
2. 点击 💾 **"备份"**
3. 等待完成（几秒钟）

**查看备份文件：**
1. 点击左侧 **"文件"**
2. 导航到：`/www/backup/database/`
3. 找到备份文件：`testdb_日期时间.sql.gz`

### 任务 4.2：下载备份文件

**步骤：**
1. 在文件管理器找到备份文件
2. 右键点击文件
3. 选择 **"下载"**
4. 保存到本地电脑

**双重保险！**

### 任务 4.3：导出数据（phpMyAdmin）

**步骤：**
1. phpMyAdmin → 选择 `testdb` 数据库
2. 点击顶部 **"导出"**
3. 选择：
   - 导出方法：**快速**
   - 格式：**SQL**
4. 点击 **"执行"**
5. 下载 `.sql` 文件

### 任务 4.4：设置自动备份

**步骤：**
1. 左侧菜单 → **"计划任务"**
2. 点击 **"添加任务"**
3. 选择：
   ```
   任务类型: 备份数据库
   任务名称: 每日备份testdb
   执行周期: 每天
   执行时间: 02:00
   备份数据库: testdb
   保留最新: 7 份
   ```
4. 点击 **"添加"**

**查看任务：**
- 任务列表会显示新创建的任务
- 可以点击 **"执行"** 立即测试
- 可以查看执行日志

---

## 📥 实践模块五：数据库恢复

### 任务 5.1：删除数据（模拟数据丢失）

**在 phpMyAdmin：**
```sql
-- 删除 users 表中的所有数据
DELETE FROM users;

-- 确认数据已删除
SELECT * FROM users;
```

结果：表是空的！

### 任务 5.2：恢复数据

**方式 1：从宝塔备份恢复**

1. **"数据库"** → 找到 `testdb`
2. 点击 📥 **"导入"**
3. 选择之前的备份文件
4. 点击 **"导入"**

**方式 2：从 SQL 文件恢复**

1. phpMyAdmin → 选择 `testdb`
2. 点击顶部 **"导入"**
3. 选择文件：之前导出的 `.sql` 文件
4. 点击 **"执行"**

**验证恢复：**
```sql
SELECT * FROM users;
```

数据回来了！🎉

---

## 🔐 实践模块六：数据库安全

### 任务 6.1：查看数据库用户权限

**在 phpMyAdmin（使用 root 登录）：**

```sql
-- 查看所有用户
SELECT User, Host FROM mysql.user;

-- 查看testuser的权限
SHOW GRANTS FOR 'testuser'@'127.0.0.1';
```

### 任务 6.2：修改数据库密码

**在宝塔面板：**
1. **"数据库"** → 找到 `testdb`
2. 点击 🔧 **"管理"**
3. 点击 **"修改密码"**
4. 输入新密码
5. 点击 **"提交"**

**测试新密码：**
- 用新密码登录 phpMyAdmin
- 确认可以访问

### 任务 6.3：理解访问权限

**实验：尝试远程连接**

当前设置：访问权限 = 本地服务器

**含义：**
- ✅ 从服务器本身可以连接（127.0.0.1）
- ❌ 从其他IP无法连接

**如何改为允许远程：**
1. **"数据库"** → **"管理"**
2. 访问权限改为 **"所有人"** 或 **"指定IP"**

**⚠️ 安全建议：** 生产环境永远不要开放到所有人！

---

## 📈 实践模块七：性能优化

### 任务 7.1：查看数据库大小

**在 phpMyAdmin：**
```sql
SELECT 
    table_name AS '表名',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS '大小(MB)'
FROM information_schema.tables
WHERE table_schema = 'testdb'
ORDER BY (data_length + index_length) DESC;
```

### 任务 7.2：创建索引

**为什么需要索引？** 加快查询速度！

```sql
-- 查看当前索引
SHOW INDEX FROM users;

-- 为 username 创建索引
CREATE INDEX idx_username ON users(username);

-- 再次查看索引
SHOW INDEX FROM users;
```

### 任务 7.3：分析查询性能

```sql
-- 使用 EXPLAIN 分析查询
EXPLAIN SELECT * FROM users WHERE username = 'zhangsan';

-- 对比有无索引的差异
```

---

## 🎓 进阶练习

### 练习 1：创建博客数据库

创建一个简单的博客系统数据库：

```sql
-- 1. 用户表（已存在）

-- 2. 文章表
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 3. 评论表
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 插入测试数据
INSERT INTO posts (user_id, title, content) VALUES
(1, '我的第一篇博客', '这是我的第一篇博客内容'),
(1, 'MySQL学习笔记', 'MySQL是一个强大的数据库系统');

INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, '写得不错！'),
(1, 3, '期待更新');
```

### 练习 2：复杂查询

```sql
-- 查询每个用户的文章数量
SELECT 
    u.username,
    COUNT(p.id) as article_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.username;

-- 查询最受欢迎的文章（评论最多）
SELECT 
    p.title,
    COUNT(c.id) as comment_count
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
GROUP BY p.id, p.title
ORDER BY comment_count DESC
LIMIT 5;
```

---

## ✅ 学习成果检查

完成本教程后，你应该能够：

- [ ] 启动和管理 MySQL 服务
- [ ] 在宝塔面板创建数据库和用户
- [ ] 使用 phpMyAdmin 管理数据库
- [ ] 创建表和设计表结构
- [ ] 执行基本的 SQL 查询（SELECT, INSERT, UPDATE, DELETE）
- [ ] 备份和恢复数据库
- [ ] 设置自动备份任务
- [ ] 理解数据库权限和安全
- [ ] 创建索引优化查询
- [ ] 使用外键建立表关系

---

## 📚 下一步学习

### 继续深入学习：

1. **SQL 进阶**
   - JOIN 查询
   - 子查询
   - 存储过程
   - 触发器
   - 视图

2. **性能优化**
   - 查询优化
   - 索引策略
   - SQL 执行计划分析
   - 慢查询优化

3. **FastAPI 集成**
   - 连接 MySQL
   - ORM 使用（SQLAlchemy）
   - 数据库迁移
   - API 数据持久化

### 推荐资源：

- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [SQL 教程 - 菜鸟教程](https://www.runoob.com/sql/sql-tutorial.html)
- [SQLAlchemy 文档](https://docs.sqlalchemy.org/)

---

## 🎯 总结

恭喜你完成了宝塔面板数据库实践教程！

**今天你学会了：**
- ✅ 宝塔面板数据库管理基础
- ✅ phpMyAdmin 的使用
- ✅ SQL 基本操作
- ✅ 数据备份和恢复
- ✅ 数据库安全最佳实践

**继续练习：**
- 创建更多数据库
- 设计更复杂的表结构
- 编写更多SQL查询
- 备份重要数据

**记住：**
- 🔒 始终保护好数据库密码
- 💾 定期备份数据
- 📊 使用索引优化性能
- 🔐 限制数据库访问权限

---

**祝你学习愉快！🚀**

有任何问题欢迎随时提问！
