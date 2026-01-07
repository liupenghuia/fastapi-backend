# 🛣️ FastAPI 路由装饰器完全指南
## @app.get() 和 @router.get() 详解

> 基于项目实际代码，从零开始理解 FastAPI 路由系统

---

## 📚 目录

1. [装饰器基础回顾](#1-装饰器基础回顾)
2. [什么是路由？](#2-什么是路由)
3. [@app.get() 详解](#3-appget-详解)
4. [@router.get() 详解](#4-routerget-详解)
5. [app vs router 的区别](#5-app-vs-router-的区别)
6. [HTTP 方法详解](#6-http-方法详解)
7. [路径参数详解](#7-路径参数详解)
8. [装饰器参数详解](#8-装饰器参数详解)
9. [完整请求流程](#9-完整请求流程)
10. [实战示例](#10-实战示例)

---

## 1. 装饰器基础回顾

### **什么是装饰器？**

装饰器是**修改函数行为的函数**，使用 `@` 符号。

```python
# 最简单的装饰器
def my_decorator(func):
    def wrapper():
        print("Before")
        func()
        print("After")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

# 调用
say_hello()
# 输出：
# Before
# Hello!
# After
```

**关键点：**
- `@my_decorator` 相当于 `say_hello = my_decorator(say_hello)`
- 装饰器会"包装"原函数，添加额外功能

---

## 2. 什么是路由？

### **路由 = URL 到函数的映射**

```
用户请求 URL → FastAPI 找到对应的函数 → 执行函数 → 返回结果

例如：
GET http://localhost:8000/users/me
     ↓
FastAPI 找到带 @router.get("/me") 的函数
     ↓
执行 get_current_user_info() 函数
     ↓
返回用户信息
```

**简单理解：路由告诉 FastAPI "当用户访问这个 URL 时，执行这个函数"**

---

## 3. @app.get() 详解

### **3.1 基本用法**

```python
# main.py
from fastapi import FastAPI

app = FastAPI()  # 创建应用实例

@app.get("/")  # 装饰器：注册路由
#   ^^^  ^^^
#    |    └─ 路径（URL）
#    └─ HTTP 方法（GET）
async def root():
    """当用户访问 / 时，执行这个函数"""
    return {"message": "Hello World"}
```

**解释：**
- `app`: FastAPI 应用实例
- `.get()`: HTTP GET 方法
- `"/"`: URL 路径
- `root()`: 路由处理函数（当访问 `/` 时执行）

### **3.2 项目示例**

```python
# app/main.py
@app.get("/", tags=["🏠 根路径"])
async def root():
    """
    API 根路径
    返回应用基本信息
    """
    return {
        "message": "欢迎使用用户管理 API",
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "redoc": "/redoc"
    }
```

**当你访问 `http://localhost:8000/` 时：**
1. FastAPI 看到请求方法是 GET
2. FastAPI 看到路径是 `/`
3. FastAPI 找到 `@app.get("/")` 装饰的函数
4. 执行 `root()` 函数
5. 返回 JSON 响应

### **3.3 实际请求示例**

```bash
# 终端执行
curl http://localhost:8000/

# 响应
{
  "message": "欢迎使用用户管理 API",
  "version": "1.0.0",
  "docs": "/docs",
  "redoc": "/redoc"
}
```

---

## 4. @router.get() 详解

### **4.1 什么是 APIRouter？**

`APIRouter` 是**路由分组工具**，用于组织和管理路由。

```python
# endpoints/users.py
from fastapi import APIRouter

router = APIRouter()  # 创建路由器实例

@router.get("/me")  # 注册到 router，不是 app
async def get_current_user_info():
    return {"username": "alice"}
```

**为什么要用 router？**
- ✅ **代码组织**：将相关路由放在一起（如：用户相关、认证相关）
- ✅ **模块化**：每个模块独立管理自己的路由
- ✅ **可重用**：router 可以包含到不同的 app 中

### **4.2 项目示例**

```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter

router = APIRouter()  # 创建路由器

@router.get(
    "/me",  # 路径
    response_model=UserResponse,  # 响应模型
    summary="获取当前用户信息",  # 简短描述
    description="获取当前登录用户的详细信息。"  # 详细描述
)
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
) -> UserResponse:
    """
    获取当前用户信息
    需要认证。返回当前登录用户的详细信息。
    """
    return current_user
```

**但是！这个路由还没生效！**

### **4.3 Router 需要注册到 App**

```python
# app/api/v1/router.py
from fastapi import APIRouter
from app.api.v1.endpoints import auth, users

api_router = APIRouter()

# 注册子路由
api_router.include_router(
    users.router,  # 把 users.py 的 router 包含进来
    prefix="/users",  # 添加前缀
    tags=["👤 用户管理"]  # 分组标签
)
```

```python
# app/main.py
app = FastAPI()

# 将 api_router 注册到 app
app.include_router(api_router, prefix="/api/v1")
```

**最终路径计算：**
```
/api/v1  (main.py 注册时的 prefix)
  + /users  (router.py 包含时的 prefix)
  + /me  (users.py 中定义的路径)
  = /api/v1/users/me  ← 最终完整路径
```

---

## 5. app vs router 的区别

### **5.1 核心区别**

| 特性 | @app.get() | @router.get() |
|------|-----------|--------------|
| **作用对象** | FastAPI 应用实例 | APIRouter 路由器 |
| **直接可用** | ✅ 是 | ❌ 否（需要注册到 app） |
| **使用场景** | 应用级全局路由 | 模块化的子路由 |
| **代码位置** | 通常在 main.py | 通常在独立模块 |

### **5.2 类比理解**

```
FastAPI App (app)
├── 全局路由 (@app.get)
│   ├── GET /
│   └── GET /health
│
└── 包含的路由器 (app.include_router)
    ├── Router 1: /api/v1/auth
    │   ├── POST /api/v1/auth/register (@router.post)
    │   └── POST /api/v1/auth/login (@router.post)
    │
    └── Router 2: /api/v1/users
        ├── GET /api/v1/users/me (@router.get)
        └── PUT /api/v1/users/me (@router.put)
```

### **5.3 项目结构**

```python
# ===== main.py =====
app = FastAPI()

# 直接在 app 上定义路由（全局路由）
@app.get("/")
async def root():
    return {"message": "Welcome"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

# 包含子路由
app.include_router(api_router, prefix="/api/v1")


# ===== api/v1/router.py =====
api_router = APIRouter()

# 包含更多子路由
api_router.include_router(auth.router, prefix="/auth")
api_router.include_router(users.router, prefix="/users")


# ===== api/v1/endpoints/users.py =====
router = APIRouter()

# 在 router 上定义路由
@router.get("/me")
async def get_me():
    return {"user": "info"}
```

---

## 6. HTTP 方法详解

### **6.1 常用 HTTP 方法**

| 方法 | 装饰器 | 用途 | 示例 |
|------|--------|------|------|
| **GET** | `@router.get()` | 获取资源 | 查询用户列表 |
| **POST** | `@router.post()` | 创建资源 | 注册新用户 |
| **PUT** | `@router.put()` | 更新资源（完整） | 更新用户信息 |
| **PATCH** | `@router.patch()` | 更新资源（部分） | 修改用户昵称 |
| **DELETE** | `@router.delete()` | 删除资源 | 删除用户 |

### **6.2 项目中的使用**

```python
# ===== GET - 获取资源 =====
@router.get("/me")
async def get_current_user_info():
    """获取当前用户信息"""
    return current_user

# ===== POST - 创建资源 =====
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user_in: UserCreate):
    """用户注册（创建新用户）"""
    return await user_crud.create(db, user_in)

# ===== PUT - 更新资源 =====
@router.put("/me")
async def update_current_user(user_in: UserUpdate):
    """更新当前用户信息"""
    return await user_crud.update(db, current_user, user_in)

# ===== DELETE - 删除资源 =====
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int):
    """删除用户"""
    await user_crud.delete(db, user_id)
    return None
```

### **6.3 REST API 设计约定**

```python
# 用户资源的标准 REST API 设计
GET    /users        # 获取用户列表
GET    /users/{id}   # 获取指定用户
POST   /users        # 创建新用户
PUT    /users/{id}   # 更新指定用户
DELETE /users/{id}   # 删除指定用户
```

---

## 7. 路径参数详解

### **7.1 固定路径**

```python
@router.get("/me")
#           ^^^^
#           固定路径，必须完全匹配
async def get_me():
    return {"user": "current"}

# 访问：GET /api/v1/users/me
```

### **7.2 路径参数（动态路径）**

```python
@router.get("/{user_id}")
#           ^^^^^^^^^^
#           路径参数，可以是任意值
async def get_user_by_id(user_id: int):
    #                    ^^^^^^^^
    #                    函数参数名必须匹配
    return {"user_id": user_id}

# 访问：
# GET /api/v1/users/1    → user_id = 1
# GET /api/v1/users/123  → user_id = 123
```

**项目示例：**
```python
# app/api/v1/endpoints/users.py
@router.get("/{user_id}", response_model=UserResponse)
async def get_user_by_id(
    user_id: int,  # 路径参数
    db: AsyncSession = Depends(get_db)
) -> UserResponse:
    """获取指定用户信息（管理员）"""
    user = await user_crud.get_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return user
```

### **7.3 多个路径参数**

```python
@router.get("/posts/{post_id}/comments/{comment_id}")
async def get_comment(post_id: int, comment_id: int):
    return {
        "post_id": post_id,
        "comment_id": comment_id
    }

# 访问：GET /posts/10/comments/5
# → post_id = 10, comment_id = 5
```

---

## 8. 装饰器参数详解

### **8.1 完整装饰器示例**

```python
@router.post(
    "/register",                        # 1. 路径
    response_model=UserResponse,        # 2. 响应模型
    status_code=status.HTTP_201_CREATED,# 3. 状态码
    summary="用户注册",                  # 4. 简短描述
    description="创建新用户账户...",     # 5. 详细描述
    tags=["认证"],                       # 6. 分组标签
    responses={                         # 7. 可能的响应
        400: {"description": "邮箱已存在"}
    }
)
async def register(user_in: UserCreate):
    ...
```

### **8.2 参数详解**

#### **① 路径（path）**
```python
@router.get("/users")  # 第一个参数，必填
```

#### **② response_model（响应模型）**
```python
@router.get("/users/me", response_model=UserResponse)
async def get_me() -> UserResponse:
    return current_user
```
**作用：**
- ✅ 自动验证返回数据格式
- ✅ 自动生成 API 文档
- ✅ 自动过滤敏感字段（如密码）

#### **③ status_code（HTTP 状态码）**
```python
@router.post("/register", status_code=status.HTTP_201_CREATED)  # 201
async def register():
    ...

@router.delete("/users/{id}", status_code=status.HTTP_204_NO_CONTENT)  # 204
async def delete_user():
    ...
```

**常用状态码：**
- `200 OK` - 成功（默认）
- `201 Created` - 创建成功
- `204 No Content` - 删除成功，无返回内容
- `400 Bad Request` - 请求参数错误
- `401 Unauthorized` - 未认证
- `403 Forbidden` - 无权限
- `404 Not Found` - 资源不存在

#### **④ summary 和 description**
```python
@router.get(
    "/me",
    summary="获取当前用户信息",  # 显示在 Swagger UI 的标题
    description="获取当前登录用户的详细信息。"  # 显示在详情中
)
```

#### **⑤ tags（分组标签）**
```python
# 方式 1：在路由定义时添加
@router.get("/me", tags=["用户管理"])

# 方式 2：在包含路由时添加
api_router.include_router(
    users.router,
    prefix="/users",
    tags=["👤 用户管理"]  # 影响该 router 下的所有路由
)
```

---

## 9. 完整请求流程

### **9.1 用户请求流程**

```
用户浏览器
    ↓  发送请求：GET /api/v1/users/me
    ↓            Header: Authorization: Bearer <token>
FastAPI 应用
    ↓  1. 路径匹配：找到 @router.get("/me") 的函数
    ↓  2. 依赖注入：执行 Depends()
    ↓     - get_db() → 创建数据库会话
    ↓     - oauth2_scheme() → 提取 Token
    ↓     - get_current_user() → 验证 Token，查询用户
    ↓     - get_current_active_user() → 检查用户是否激活
    ↓  3. 执行路由函数：get_current_user_info(current_user)
    ↓  4. 返回结果：UserResponse 模型
    ↓  5. 自动序列化为 JSON
    ↓
用户浏览器
    ← 收到响应：{"id": 1, "username": "alice", ...}
```

### **9.2 代码追踪**

```python
# ===== 1. 用户请求 =====
GET /api/v1/users/me
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJ...


# ===== 2. main.py - 路由注册 =====
app = FastAPI()
app.include_router(api_router, prefix="/api/v1")
#                               ^^^^^^^^^^^^
#                               路径前缀


# ===== 3. api/v1/router.py - 子路由注册 =====
api_router.include_router(
    users.router,
    prefix="/users",  # /api/v1 + /users = /api/v1/users
    tags=["👤 用户管理"]
)


# ===== 4. api/v1/endpoints/users.py - 路由定义 =====
@router.get("/me")  # /api/v1/users + /me = /api/v1/users/me
#           ^^^^
#           路径匹配！
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
    #                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #                    依赖注入：获取当前用户
) -> UserResponse:
    return current_user  # 返回用户对象


# ===== 5. api/deps.py - 依赖注入链 =====
async def get_current_active_user(
    current_user: User = Depends(get_current_user)
):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="用户账户已被禁用")
    return current_user

async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
    payload = decode_access_token(token)
    user = await user_crud.get_by_username(db, payload["sub"])
    return user


# ===== 6. FastAPI 自动处理 =====
# - 将 User 对象转换为 UserResponse 模型
# - 序列化为 JSON
# - 返回 HTTP 响应
```

---

## 10. 数据库层详解

### **10.1 数据库架构总览**

FastAPI 项目的数据库层采用**分层架构**，每一层负责不同的职责：

```
📊 数据库层次架构：

┌─────────────────────────────────────────┐
│  ① 配置层 (.env)                        │
│  DATABASE_URL, SECRET_KEY               │
└────────────┬────────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│  ② 连接层 (app/core/database.py)       │
│  Engine, SessionMaker, get_db()         │
└────────────┬────────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│  ③ 模型层 (app/models/)                 │
│  User (ORM 数据库表映射)                │
└────────────┬────────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│  ④ 数据验证层 (app/schemas/)            │
│  UserCreate, UserResponse (Pydantic)    │
└────────────┬────────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│  ⑤ 操作层 (app/crud/)                   │
│  UserCRUD (业务逻辑)                    │
└────────────┬───────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│  ⑥ 路由层 (app/api/v1/endpoints/)      │
│  auth.py, users.py (API 端点)          │
└─────────────────────────────────────────┘
```

---

### **10.2 各层详解**

#### **① 配置层 - `.env`**

**作用：** 存储数据库连接配置

```env
# .env 文件
DATABASE_URL="sqlite+aiosqlite:///./app.db"
SECRET_KEY="your-secret-key"
DEBUG=true
```

**说明：**
- `sqlite` - 数据库类型
- `aiosqlite` - 异步驱动
- `///./app.db` - 数据库文件路径

**如何切换到 MySQL：**
```env
DATABASE_URL="mysql+aiomysql://user:password@localhost:3306/dbname"
```

---

#### **② 连接层 - `app/core/database.py`**

**核心职责：**
- ✅ 创建数据库引擎
- ✅ 提供会话工厂
- ✅ 依赖注入函数
- ✅ 初始化数据库

**关键代码：**

```python
# 1. 创建异步引擎
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG  # 调试时打印 SQL
)

# 2. 创建会话工厂
async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# 3. ORM 基类
class Base(DeclarativeBase):
    pass

# 4. 依赖注入函数（重要！）
async def get_db() -> AsyncSession:
    async with async_session_maker() as session:
        try:
            yield session          # 提供会话
            await session.commit() # 成功则提交
        except Exception:
            await session.rollback() # 失败则回滚
            raise
        finally:
            await session.close()    # 确保关闭
```

**工作流程：**
```
API 请求 
  → Depends(get_db) 
  → 创建 session 
  → yield session (给路由函数使用)
  → 路由函数执行数据库操作
  → commit() 或 rollback()
  → close() 关闭会话
```

---

#### **③ 模型层 - `app/models/user.py`**

**作用：** ORM 模型，定义数据库表结构

```python
class User(Base):
    __tablename__ = "users"  # 数据库表名
    
    # 字段映射（Python ↔ 数据库）
    id: Mapped[int] = mapped_column(
        Integer, 
        primary_key=True, 
        autoincrement=True
    )
    email: Mapped[str] = mapped_column(
        String(255), 
        unique=True,      # 唯一约束
        index=True,       # 创建索引
        nullable=False    # 非空
    )
    username: Mapped[str] = mapped_column(
        String(50), 
        unique=True, 
        index=True
    )
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
```

**映射关系：**
```
Python 类 User  ←→  数据库表 users
   ├── id: Mapped[int]        ←→  id INT PRIMARY KEY
   ├── email: Mapped[str]     ←→  email VARCHAR(255) UNIQUE
   ├── username: Mapped[str]  ←→  username VARCHAR(50) UNIQUE
   └── hashed_password        ←→  hashed_password VARCHAR(255)
```

**特殊方法：**
```python
def __repr__(self):
    return f"<User(id={self.id}, username={self.username})>"

# 使用
user = User(...)
print(user)  # <User(id=1, username=alice)>
```

---

#### **④ 数据验证层 - `app/schemas/user.py`**

**作用：** Pydantic 模型，验证 API 输入/输出

```python
# 基础类（共享字段）
class UserBase(BaseModel):
    email: EmailStr                    # 自动验证邮箱格式
    username: str
    full_name: Optional[str] = None

# 创建请求（客户端 → 服务端）
class UserCreate(UserBase):
    password: str  # 明文密码（仅在创建时）

# 更新请求
class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    password: Optional[str] = None
    full_name: Optional[str] = None

# 响应模型（服务端 → 客户端）
class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True  # 允许从 ORM 对象创建
```

**Schema vs Model 对比：**

| 对比项 | Model (ORM) | Schema (Pydantic) |
|-------|-------------|-------------------|
| **位置** | `app/models/` | `app/schemas/` |
| **继承** | `Base` (SQLAlchemy) | `BaseModel` (Pydantic) |
| **用途** | 数据库映射 | 数据验证 |
| **字段** | 数据库列 | API 输入/输出 |
| **密码字段** | `hashed_password` (加密) | `password` (明文) |
| **使用场景** | CRUD 操作 | 请求/响应 |

---

#### **⑤ 操作层 - `app/crud/user.py`**

**作用：** 封装数据库操作的业务逻辑

```python
class UserCRUD:
    # === 查询 ===
    async def get_by_id(
        self, 
        db: AsyncSession, 
        user_id: int
    ) -> Optional[User]:
        """根据 ID 查询用户"""
        result = await db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_by_email(
        self, 
        db: AsyncSession, 
        email: str
    ) -> Optional[User]:
        """根据邮箱查询用户"""
        result = await db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def get_list(
        self, 
        db: AsyncSession, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[User]:
        """获取用户列表（分页）"""
        result = await db.execute(
            select(User)
            .offset(skip)
            .limit(limit)
            .order_by(User.id)
        )
        return list(result.scalars().all())
    
    # === 创建 ===
    async def create(
        self, 
        db: AsyncSession, 
        user_in: UserCreate  # ← Schema
    ) -> User:  # → Model
        """创建新用户"""
        # 1. 密码加密
        hashed_password = get_password_hash(user_in.password)
        
        # 2. 创建 ORM 对象
        db_user = User(
            email=user_in.email,
            username=user_in.username,
            hashed_password=hashed_password,
            full_name=user_in.full_name
        )
        
        # 3. 添加到会话
        db.add(db_user)
        await db.flush()  # 刷新获取自动生成的 ID
        await db.refresh(db_user)  # 刷新对象状态
        
        return db_user
    
    # === 更新 ===
    async def update(
        self, 
        db: AsyncSession, 
        db_user: User,  # 现有用户对象
        user_in: UserUpdate  # 更新数据
    ) -> User:
        """更新用户信息"""
        # 只获取实际设置的字段
        update_data = user_in.model_dump(exclude_unset=True)
        
        # 如果更新密码，需要加密
        if "password" in update_data:
            hashed = get_password_hash(update_data.pop("password"))
            update_data["hashed_password"] = hashed
        
        # 更新字段
        for field, value in update_data.items():
            setattr(db_user, field, value)
        
        await db.flush()
        await db.refresh(db_user)
        return db_user
    
    # === 删除 ===
    async def delete(
        self, 
        db: AsyncSession, 
        user_id: int
    ) -> User:
        """删除用户"""
        user = await self.get_by_id(db, user_id)
        if user:
            await db.delete(user)
            await db.flush()
        return user
```

**关键点：**
- 接收 `Schema` 对象（UserCreate, UserUpdate）
- 返回 `Model` 对象（User）
- 使用 `AsyncSession` 操作数据库
- `flush()` 刷新会话，`refresh()` 刷新对象

---

#### **⑥ 路由层 - `app/api/v1/endpoints/users.py`**

**作用：** 处理 HTTP 请求，调用 CRUD

```python
@router.post(
    "/",
    response_model=UserResponse,  # ← 返回 Schema
    status_code=status.HTTP_201_CREATED
)
async def create_user(
    user_in: UserCreate,  # ← 请求体（Schema）
    db: AsyncSession = Depends(get_db)  # ← 注入数据库会话
):
    """创建新用户（仅管理员）"""
    # 1. 检查邮箱是否已存在
    existing = await user_crud.get_by_email(db, user_in.email)
    if existing:
        raise HTTPException(
            status_code=400, 
            detail="该邮箱已被注册"
        )
    
    # 2. 创建用户
    user = await user_crud.create(db, user_in)  # ← 调用 CRUD
    
    # 3. 返回结果（ORM Model 自动转换为 Schema）
    return user
```

---

### **10.3 完整数据流向**

#### **场景：用户注册 POST /api/v1/auth/register**

```
① 客户端发送请求
   POST /api/v1/auth/register
   Body: {
     "email": "alice@example.com",
     "username": "alice",
     "password": "secret123"
   }
        ↓
② FastAPI 路由匹配
   找到 @router.post("/register") 的函数
        ↓
③ Pydantic 验证（Schema）
   user_in: UserCreate ← 自动验证格式
   - email 格式是否正确？
   - username 长度是否符合？
   - password 是否足够强？
        ↓
④ 依赖注入（Database Session）
   db: AsyncSession = Depends(get_db)
   - 创建数据库会话
   - 准备事务
        ↓
⑤ CRUD 业务逻辑
   user_crud.create(db, user_in)
   - 检查邮箱是否存在
   - 密码加密：bcrypt.hashpw()
   - 创建 User 对象（ORM Model）
        ↓
⑥ 数据库操作（SQLAlchemy）
   db.add(db_user)
   await db.flush()
   ↓ 生成 SQL
   INSERT INTO users (email, username, hashed_password, ...)
   VALUES ('alice@example.com', 'alice', '$2b$12$...', ...)
        ↓
⑦ 提交事务
   await session.commit()
   - 确保数据持久化
        ↓
⑧ 返回结果
   return user  # ORM Model
   ↓ FastAPI 自动转换
   User (ORM) → UserResponse (Schema)
   ↓ 序列化为 JSON
   {
     "id": 1,
     "email": "alice@example.com",
     "username": "alice",
     "is_active": true,
     "created_at": "2024-01-01T10:00:00Z"
   }
        ↓
⑨ 响应客户端
   HTTP/1.1 201 Created
   Content-Type: application/json
```

---

### **10.4 数据转换流程**

```
请求 JSON → Schema → ORM Model → Database → ORM Model → Schema → 响应 JSON

详细说明：

1. 请求 JSON {"email": "...", "password": "..."}
   ↓
2. Pydantic Schema 验证
   UserCreate(email="...", password="...")
   ↓
3. CRUD 处理
   创建 User(email="...", hashed_password="...")
   ↓
4. SQLAlchemy 生成 SQL
   INSERT INTO users ...
   ↓
5. 数据库返回
   User(id=1, email="...", ...)
   ↓
6. FastAPI 转换为 Schema
   UserResponse(id=1, email="...", ...)
   ↓
7. 序列化为 JSON
   {"id": 1, "email": "...", ...}
```

---

### **10.5 关键概念对比**

#### **Session（会话） vs Connection（连接）**

```python
# Connection - 底层数据库连接
# 通常不直接使用

# Session - 工作单元，管理事务
async with async_session_maker() as session:
    # 所有操作都在这个会话中
    user = await session.get(User, user_id)
    session.add(new_user)
    await session.commit()
```

#### **flush() vs commit()**

```python
# flush() - 发送 SQL 到数据库，但不提交事务
db.add(user)
await db.flush()  # 执行 INSERT，但可以回滚
user.id  # 现在有 ID 了

# commit() - 提交事务，数据持久化
await db.commit()  # 数据真正保存到数据库
```

#### **scalar_one_or_none() vs scalars().all()**

```python
# scalar_one_or_none() - 返回单个对象或 None
result = await db.execute(select(User).where(User.id == 1))
user = result.scalar_one_or_none()  # User 对象 或 None

# scalars().all() - 返回列表
result = await db.execute(select(User))
users = result.scalars().all()  # [User, User, User, ...]
```

---

### **10.6 常见操作示例**

#### **查询**

```python
# 1. 根据 ID 查询
user = await db.get(User, user_id)

# 2. 条件查询
result = await db.execute(
    select(User).where(User.email == "alice@example.com")
)
user = result.scalar_one_or_none()

# 3. 多条件查询
result = await db.execute(
    select(User)
    .where(User.is_active == True)
    .where(User.created_at > some_date)
)

# 4. 分页查询
result = await db.execute(
    select(User)
    .order_by(User.id)
    .offset(skip)
    .limit(limit)
)
users = result.scalars().all()
```

#### **创建**

```python
# 创建单个对象
user = User(
    email="alice@example.com",
    username="alice",
    hashed_password="..."
)
db.add(user)
await db.flush()  # 获取自动生成的 ID
await db.refresh(user)  # 刷新对象
```

#### **更新**

```python
# 方式 1：直接修改属性
user.username = "new_name"
await db.flush()

# 方式 2：批量更新
for field, value in update_data.items():
    setattr(user, field, value)
await db.flush()
```

#### **删除**

```python
await db.delete(user)
await db.flush()
```

---

### **10.7 最佳实践**

#### **✅ 使用依赖注入管理会话**

```python
# 推荐
@router.get("/users")
async def get_users(db: AsyncSession = Depends(get_db)):
    users = await user_crud.get_list(db)
    return users

# 不推荐：手动管理会话
async def get_users():
    async with async_session_maker() as db:
        # ...
    # 容易忘记关闭或提交
```

#### **✅ 在 CRUD 层处理业务逻辑**

```python
# 推荐：CRUD 层
class UserCRUD:
    async def create(self, db, user_in):
        # 业务逻辑在这里
        hashed_password = get_password_hash(user_in.password)
        db_user = User(...)
        db.add(db_user)
        return db_user

# 路由层保持简洁
@router.post("/users")
async def create_user(user_in, db):
    return await user_crud.create(db, user_in)
```

#### **✅ 使用 Schema 验证数据**

```python
# 推荐：Schema 验证
@router.post("/users", response_model=UserResponse)
async def create_user(user_in: UserCreate, db):
    return await user_crud.create(db, user_in)

# 不推荐：直接使用字典
async def create_user(data: dict):
    user = User(**data)  # 没有验证！
```

#### **✅ 总是使用 try-except-finally**

```python
# get_db() 已经帮你处理了
async def get_db():
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()  # 出错回滚
            raise
        finally:
            await session.close()  # 确保关闭
```

---

### **10.8 数据库迁移**

**从 SQLite 切换到 MySQL：**

1. 修改 `.env`：
```env
# 旧
DATABASE_URL="sqlite+aiosqlite:///./app.db"

# 新
DATABASE_URL="mysql+aiomysql://user:password@localhost:3306/dbname"
```

2. 安装依赖：
```bash
pip install aiomysql pymysql
```

3. 重启应用 - 自动创建表！

---

## 11. 实战示例

### **示例 1：简单的 GET 路由**

```python
# 定义
@app.get("/hello")
async def say_hello():
    return {"message": "Hello, World!"}

# 请求
curl http://localhost:8000/hello

# 响应
{"message": "Hello, World!"}
```

### **示例 2：带路径参数的 GET 路由**

```python
# 定义
@router.get("/users/{user_id}")
async def get_user(user_id: int):
    return {"user_id": user_id, "name": f"User {user_id}"}

# 请求
curl http://localhost:8000/api/v1/users/123

# 响应
{"user_id": 123, "name": "User 123"}
```

### **示例 3：带查询参数的 GET 路由**

```python
# 定义
@router.get("/users")
async def get_users(skip: int = 0, limit: int = 10):
    #                ^^^^^^^^^^  ^^^^^^^^^^^
    #                查询参数（URL 中的 ?skip=0&limit=10）
    return {"skip": skip, "limit": limit}

# 请求
curl "http://localhost:8000/api/v1/users?skip=10&limit=20"

# 响应
{"skip": 10, "limit": 20}
```

### **示例 4：POST 路由（创建资源）**

```python
# 定义
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(user_in: UserCreate):
    #                   ^^^^^^^^^^^^^^^^^
    #                   请求体（JSON），自动验证
    return await user_crud.create(db, user_in)

# 请求
curl -X POST http://localhost:8000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com", "username": "alice", "password": "secret123"}'

# 响应（201 Created）
{
  "id": 1,
  "email": "alice@example.com",
  "username": "alice",
  "is_active": true,
  "created_at": "2024-01-01T10:00:00Z"
}
```

### **示例 5：带依赖注入的路由**

```python
# 定义
@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_active_user)
    #                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #                    依赖注入：自动获取当前用户
):
    return current_user

# 请求
curl http://localhost:8000/api/v1/users/me \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJ..."

# 响应
{
  "id": 1,
  "email": "alice@example.com",
  "username": "alice",
  ...
}
```

### **示例 6：DELETE 路由**

```python
# 定义
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int):
    await user_crud.delete(db, user_id)
    return None  # 204 响应没有 body

# 请求
curl -X DELETE http://localhost:8000/api/v1/users/5 \
  -H "Authorization: Bearer ..."

# 响应（204 No Content，无响应体）
```

---

## 🎯 总结

### **核心概念**

| 概念 | 解释 |
|------|------|
| **@app.get()** | 在 FastAPI 应用上直接注册路由 |
| **@router.get()** | 在 APIRouter 上注册路由（需要 include 到 app） |
| **路径** | URL 的路径部分，如 `/users/me` |
| **HTTP 方法** | GET、POST、PUT、DELETE 等 |
| **路径参数** | `{user_id}` 动态匹配路径中的值 |
| **查询参数** | `?skip=0&limit=10` URL 中的参数 |

### **项目中的路由结构**

```
FastAPI App (main.py)
├── @app.get("/")                       → 根路径
├── @app.get("/health")                 → 健康检查
└── app.include_router(api_router, prefix="/api/v1")
    │
    ├── /api/v1/auth (auth.router)
    │   ├── POST /register              → 用户注册
    │   └── POST /login                 → 用户登录
    │
    └── /api/v1/users (users.router)
        ├── GET /me                     → 获取当前用户
        ├── PUT /me                     → 更新当前用户
        ├── GET /                       → 获取用户列表
        ├── GET /{user_id}              → 获取指定用户
        ├── PUT /{user_id}              → 更新指定用户
        └── DELETE /{user_id}           → 删除用户
```

### **记忆口诀**

```python
@router.方法("/路径", 参数...)
async def 函数名(参数):
    return 结果

# 例如：
@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user
```

---

## 📚 延伸阅读

- **FastAPI 路由文档**: https://fastapi.tiangolo.com/tutorial/first-steps/
- **HTTP 方法详解**: https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Methods
- **REST API 设计**: https://restfulapi.net/

---

🎉 **现在你应该完全理解 `@app.get()` 和 `@router.get()` 了！**

记住：**路由装饰器就是告诉 FastAPI "当用户访问某个 URL 时，执行这个函数"**
