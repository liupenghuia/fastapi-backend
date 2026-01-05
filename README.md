# 🚀 FastAPI 用户管理 API

一个基于 FastAPI 构建的现代化用户管理 API 系统，提供完整的用户认证和管理功能。

## ✨ 功能特性

- 🔐 **JWT 用户认证** - 基于 JSON Web Token 的安全认证机制
- 👤 **用户 CRUD 操作** - 完整的用户增删改查功能
- 📦 **SQLite 数据库** - 使用 SQLAlchemy 异步 ORM
- 📖 **自动 API 文档** - Swagger UI 和 ReDoc 自动生成
- ✅ **数据验证** - 基于 Pydantic 的强类型数据验证
- 🛡️ **权限控制** - 基于角色的访问控制

## 📁 项目结构

```
fastapi-backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # 应用入口
│   ├── core/                 # 核心模块
│   │   ├── config.py        # 配置管理
│   │   ├── database.py      # 数据库连接
│   │   └── security.py      # 安全工具
│   ├── models/              # 数据库模型
│   │   └── user.py
│   ├── schemas/             # Pydantic 模式
│   │   ├── user.py
│   │   └── token.py
│   ├── crud/                # CRUD 操作
│   │   └── user.py
│   └── api/                 # API 路由
│       ├── deps.py          # 依赖注入
│       └── v1/
│           ├── router.py
│           └── endpoints/
│               ├── auth.py  # 认证接口
│               └── users.py # 用户管理接口
├── .env                     # 环境变量
├── .gitignore
├── requirements.txt
└── README.md
```

## 🛠️ 安装和运行

### 1. 创建虚拟环境

```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 或
venv\Scripts\activate  # Windows
```

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 配置环境变量

编辑 `.env` 文件，修改以下配置（特别是生产环境）：

```env
SECRET_KEY="your-super-secret-key-change-in-production-min-32-chars"
```

### 4. 运行应用

```bash
# 开发模式（热重载）
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 生产模式
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

## 📚 API 文档

启动应用后，访问以下地址查看 API 文档：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔗 API 端点

### 认证接口

| 方法 | 端点 | 描述 |
|------|------|------|
| POST | `/api/v1/auth/register` | 用户注册 |
| POST | `/api/v1/auth/login` | 用户登录 |

### 用户管理接口

| 方法 | 端点 | 描述 | 权限 |
|------|------|------|------|
| GET | `/api/v1/users/me` | 获取当前用户 | 登录用户 |
| PUT | `/api/v1/users/me` | 更新当前用户 | 登录用户 |
| GET | `/api/v1/users` | 获取用户列表 | 超级管理员 |
| GET | `/api/v1/users/{id}` | 获取指定用户 | 超级管理员 |
| PUT | `/api/v1/users/{id}` | 更新指定用户 | 超级管理员 |
| DELETE | `/api/v1/users/{id}` | 删除用户 | 超级管理员 |

## 🔒 认证流程

1. **注册**: POST `/api/v1/auth/register` 创建账户
2. **登录**: POST `/api/v1/auth/login` 获取 JWT Token
3. **访问 API**: 在请求头中添加 `Authorization: Bearer <token>`

## 🧪 测试 API

使用 cURL 测试：

```bash
# 注册用户
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "username": "testuser", "password": "password123"}'

# 登录
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=password123"

# 获取当前用户（需要 Token）
curl -X GET "http://localhost:8000/api/v1/users/me" \
  -H "Authorization: Bearer <your-token>"
```

## 📝 许可证

MIT License
