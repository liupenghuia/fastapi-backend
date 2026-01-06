# 🔍 Pydantic 完全指南
## 数据验证的超级英雄

> 基于项目实际代码，彻底理解 Pydantic 是什么、为什么需要它、怎么用

---

## 📚 目录

1. [Pydantic 是什么？](#1-pydantic-是什么)
2. [为什么需要 Pydantic？](#2-为什么需要-pydantic)
3. [核心概念：BaseModel](#3-核心概念basemodel)
4. [数据验证](#4-数据验证)
5. [Field 详解](#5-field-详解)
6. [项目中的实际应用](#6-项目中的实际应用)
7. [Pydantic vs 普通类](#7-pydantic-vs-普通类)
8. [高级特性](#8-高级特性)
9. [常见错误示例](#9-常见错误示例)
10. [实战练习](#10-实战练习)

---

## 1. Pydantic 是什么？

### **一句话总结：**
> **Pydantic 是一个 Python 数据验证库，用于确保你的数据格式正确。**

### **类比理解：**

想象你是一个餐厅服务员，顾客点餐时：

```python
# ❌ 没有 Pydantic（无验证）
order = {
    "dish": "pizza",
    "quantity": "abc",  # 错误！应该是数字
    "email": "not-an-email"  # 错误！格式不对
}
# 直到后厨开始做才发现问题！

# ✅ 使用 Pydantic（自动验证）
class Order(BaseModel):
    dish: str
    quantity: int  # 必须是整数
    email: EmailStr  # 必须是邮箱格式

order = Order(
    dish="pizza",
    quantity="abc",  # ❌ 立即报错！
    email="not-an-email"  # ❌ 立即报错！
)
# 在接收订单时就发现问题！
```

**Pydantic = 数据的"质检员"**

---

## 2. 为什么需要 Pydantic？

### **2.1 问题场景**

#### **场景 1：API 接收数据**
```python
# 用户发送注册请求
POST /api/v1/auth/register
{
    "email": "not-an-email",  # 错误格式
    "username": "ab",  # 太短
    "password": "123"  # 太短
}

# ❌ 没有验证，直接存入数据库
# → 数据库数据混乱，系统崩溃

# ✅ 有 Pydantic 验证
# → 立即返回友好错误信息，拒绝错误数据
```

#### **场景 2：配置文件管理**
```python
# ❌ 普通字典（容易出错）
config = {
    "app_name": "My App",
    "debug": "yes",  # 字符串，应该是布尔值
    "port": "abc"  # 字符串，应该是数字
}
# 使用时才发现类型错误

# ✅ Pydantic Settings（自动验证和转换）
class Settings(BaseSettings):
    app_name: str
    debug: bool  # 自动将 "yes" 转换为 True
    port: int  # 自动将 "8000" 转换为 8000
```

### **2.2 Pydantic 的核心价值**

| 功能 | 说明 | ����例 |
|------|------|------|
| **数据验证** | 确保数据类型正确 | `age: int` 拒绝 "abc" |
| **自动转换** | 智能类型转换 | `"123"` → `123` |
| **错误提示** | 清晰的错误信息 | "邮箱格式不正确" |
| **IDE 支持** | 代码补全和类型检查 | 自动提示字段 |
| **文档生成** | 自动生成 API 文档 | FastAPI 的 Swagger UI |

---

## 3. 核心概念：BaseModel

### **3.1 什么是 BaseModel？**

`BaseModel` 是 Pydantic 的**基类**，所有数据模型都要继承它。

```python
from pydantic import BaseModel

# 定义一个数据模型
class User(BaseModel):
    name: str
    age: int
    email: str

# 创建实例（自动验证）
user = User(name="Alice", age=25, email="alice@example.com")
print(user.name)  # "Alice"
print(user.age)   # 25

# ❌ 错误数据会立即报错
user = User(name="Bob", age="abc", email="bob@example.com")
# ValidationError: age 应该是整数，不是字符串
```

### **3.2 项目示例**

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    """用户基础模式"""
    email: EmailStr  # 必须是有效的邮箱格式
    username: str  # 必须是字符串
    full_name: Optional[str] = None  # 可选字段

# 使用
user_data = UserBase(
    email="alice@example.com",
    username="alice"
)
print(user_data.email)  # "alice@example.com"
```

---

## 4. 数据验证

### **4.1 基本类型验证**

```python
from pydantic import BaseModel

class Product(BaseModel):
    name: str  # 必须是字符串
    price: float  # 必须是浮点数
    in_stock: bool  # 必须是布尔值
    quantity: int  # 必须是整数

# ✅ 正确数据
product = Product(
    name="iPhone",
    price=999.99,
    in_stock=True,
    quantity=10
)

# ❌ 错误数据
product = Product(
    name=123,  # ❌ 应该是字符串
    price="abc",  # ❌ 应该是数字
    in_stock="yes",  # ❌ 应该是布尔值
    quantity=10.5  # ❌ 应该是整数
)
# ValidationError: 4 个验证错误
```

### **4.2 自动类型转换**

```python
from pydantic import BaseModel

class User(BaseModel):
    age: int
    is_active: bool

# Pydantic 会尝试自动转换
user = User(age="25", is_active="yes")
print(user.age)  # 25 (int) ← 从 "25" (str) 转换
print(user.is_active)  # True ← 从 "yes" 转换

# 但无法转换的会报错
user = User(age="abc", is_active="yes")
# ValidationError: age 无法转换为 int
```

### **4.3 EmailStr - 邮箱验证**

```python
from pydantic import BaseModel, EmailStr

class User(BaseModel):
    email: EmailStr  # 自动验证邮箱格式

# ✅ 有效邮箱
user = User(email="alice@example.com")

# ❌ 无效邮箱
user = User(email="not-an-email")
# ValidationError: 邮箱格式不正确
user = User(email="missing-at-sign.com")
# ValidationError: 邮箱格式不正确
```

**项目示例：**
```python
# app/schemas/user.py
class UserBase(BaseModel):
    email: EmailStr = Field(..., description="用户邮箱")
    # ^^^^^^^^^ 自动验证邮箱格式
```

---

## 5. Field 详解

### **5.1 什么是 Field？**

`Field` 用于给字段添加**额外的验证规则和元数据**。

```python
from pydantic import BaseModel, Field

class User(BaseModel):
    username: str = Field(
        ...,  # 必填（... 表示必需）
        min_length=3,  # 最小长度 3
        max_length=50,  # 最大长度 50
        pattern=r"^[a-zA-Z0-9_-]+$",  # 正则验证
        description="用户名"  # 描述（用于 API 文档）
    )
    age: int = Field(
        ...,
        ge=0,  # greater than or equal（大于等于 0）
        le=120,  # less than or equal（小于等于 120）
        description="年龄"
    )
    email: str = Field(default="no-reply@example.com")  # 默认值
```

### **5.2 Field 参数详解**

| 参数 | 说明 | 示例 |
|------|------|------|
| `...` | 必填字段 | `Field(...)` |
| `default` | 默认值 | `Field(default="默认值")` |
| `min_length` | 最小长度 | `Field(min_length=3)` |
| `max_length` | 最大长度 | `Field(max_length=50)` |
| `ge` | 大于等于 | `Field(ge=0)` |
| `le` | 小于等于 | `Field(le=100)` |
| `gt` | 大于 | `Field(gt=0)` |
| `lt` | 小于 | `Field(lt=100)` |
| `pattern` | 正则表达式 | `Field(pattern=r"^\d+$")` |
| `description` | 字段描述 | `Field(description="用户名")` |

### **5.3 项目示例**

```python
# app/schemas/user.py
class UserCreate(UserBase):
    """创建用户请求模式"""
    password: str = Field(
        ...,  # 必填
        min_length=8,  # 密码至少 8 位
        max_length=100,  # 密码最多 100 位
        description="密码（8-100字符）"
    )

# 测试
user = UserCreate(
    email="alice@example.com",
    username="alice",
    password="123"  # ❌ 太短！
)
# ValidationError: 密码至少需要 8 个字符
```

---

## 6. 项目中的实际应用

### **6.1 请求验证（UserCreate）**

```python
# app/schemas/user.py
class UserCreate(UserBase):
    """创建用户请求模式"""
    email: EmailStr = Field(..., description="用户邮箱")
    username: str = Field(
        ..., 
        min_length=3, 
        max_length=50, 
        pattern=r"^[a-zA-Z0-9_-]+$",
        description="用户名（3-50字符，仅支持字母、数字、下划线和连字符）"
    )
    password: str = Field(
        ..., 
        min_length=8, 
        max_length=100,
        description="密码（8-100字符）"
    )

# 在路由中使用
@router.post("/register", response_model=UserResponse)
async def register(user_in: UserCreate):
    #                 ^^^^^^^^^^^^^^^
    #                 FastAPI 自动验证！
    # 如果数据不符合 UserCreate 的规则，自动返回 422 错误
    return await user_crud.create(db, user_in)
```

**请求示例：**
```bash
# ❌ 错误请求
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "not-an-email",
    "username": "ab",
    "password": "123"
  }'

# 响应（422 Unprocessable Entity）
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "邮箱格式不正确",
      "type": "value_error.email"
    },
    {
      "loc": ["body", "username"],
      "msg": "用户名至少 3 个字符",
      "type": "value_error.any_str.min_length"
    },
    {
      "loc": ["body", "password"],
      "msg": "密码至少 8 个字符",
      "type": "value_error.any_str.min_length"
    }
  ]
}
```

### **6.2 响应序列化（UserResponse）**

```python
# app/schemas/user.py
class UserResponse(UserBase):
    """用户响应模式"""
    model_config = ConfigDict(from_attributes=True)
    #              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #              允许从 ORM 对象（User）转换
    
    id: int
    is_active: bool
    is_superuser: bool
    created_at: datetime
    updated_at: datetime
    # 注意：没有 password 或 hashed_password！自动隐藏敏感字段

# 在路由中使用
@router.get("/me", response_model=UserResponse)
#                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                  自动将 User 对象转换为 UserResponse
async def get_me(current_user: User):
    return current_user  # User ORM 对象
    # FastAPI 自动转换为 UserResponse（JSON）
```

**工作流程：**
```python
# 1. 从数据库查询用户（User ORM 对象）
user = await user_crud.get_by_id(db, 1)
# user.id = 1
# user.username = "alice"
# user.hashed_password = "$2b$12$..." ← 敏感字段！

# 2. 返回时，FastAPI 自动转换为 UserResponse
return user

# 3. 最终返回的 JSON（自动过滤了 hashed_password）
{
  "id": 1,
  "email": "alice@example.com",
  "username": "alice",
  "full_name": "Alice Smith",
  "is_active": true,
  "is_superuser": false,
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z"
}
# ✅ 密码字段被自动隐藏！
```

### **6.3 配置管理（Settings）**

```python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """应用配置类"""
    APP_NAME: str = "用户管理 API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    SECRET_KEY: str = "your-secret-key"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DATABASE_URL: str = "sqlite+aiosqlite:///./app.db"
    
    class Config:
        env_file = ".env"  # 从 .env 文件读取
        case_sensitive = True

# 使用
settings = Settings()  # 自动从环境变量和 .env 加载
print(settings.APP_NAME)  # "用户管理 API"
print(settings.DEBUG)  # False（自动转换为布尔值）
```

**.env 文件：**
```bash
APP_NAME="My Custom App"
DEBUG=true
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

**加载过程：**
```python
settings = Settings()
# 1. 从 .env 读取 APP_NAME="My Custom App"
# 2. 从 .env 读取 DEBUG=true（字符串 "true"）
# 3. Pydantic 自动将 "true" 转换为 True（布尔值）
# 4. ACCESS_TOKEN_EXPIRE_MINUTES="60"（字符串）→ 60（整数）
```

---

## 7. Pydantic vs 普通类

### **7.1 普通 Python 类（无验证）**

```python
# ❌ 普通类（危险！）
class User:
    def __init__(self, name, age, email):
        self.name = name
        self.age = age  # 没有类型检查
        self.email = email  # 没有格式验证

# 创建时不会报错，但数据可能是错的
user = User(name=123, age="abc", email="not-an-email")
# ✅ 创建成功，但数据全是错的！
print(user.age)  # "abc"（字符串，应该是整数）
# 使用时才会发现问题（可能已经存入数据库了！）
```

### **7.2 Pydantic 模型（自动验证）**

```python
# ✅ Pydantic 模型（安全！）
from pydantic import BaseModel, EmailStr

class User(BaseModel):
    name: str
    age: int
    email: EmailStr

# 创建时立即验证
user = User(name=123, age="abc", email="not-an-email")
# ❌ ValidationError: 立即报错
# - name: 应该是字符串
# - age: 应该是整数
# - email: 邮箱格式不正确
```

### **7.3 对比表**

| 特性 | 普通类 | Pydantic 类 |
|------|--------|------------|
| 类型验证 | ❌ 无 | ✅ 自动验证 |
| 数据转换 | ❌ 无 | ✅ 智能转换 |
| 错误提示 | ❌ 运行时才发现 | ✅ 创建时立即发现 |
| IDE 支持 | ⚠️ 有限 | ✅ 完整支持 |
| JSON 序列化 | ❌ 需要手动实现 | ✅ 自动支持 |
| API 文档 | ❌ 无 | ✅ 自动生成 |

---

## 8. 高级特性

### **8.1 继承**

```python
# 基类
class UserBase(BaseModel):
    email: EmailStr
    username: str

# 创建时继承并添加字段
class UserCreate(UserBase):
    password: str  # 新增字段

# 响应时继承并添加字段
class UserResponse(UserBase):
    id: int
    created_at: datetime
    # 没有 password！

# 项目示例
user_in = UserCreate(
    email="alice@example.com",
    username="alice",
    password="secret123"
)
```

### **8.2 Optional 字段**

```python
from typing import Optional

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None  # 可选字段
    username: Optional[str] = None
    password: Optional[str] = None

# 所有字段都可以不传
update = UserUpdate()  # ✅ 所有字段都是 None

# 只更新部分字段
update = UserUpdate(email="new@example.com")
# email = "new@example.com"
# username = None
# password = None
```

### **8.3 model_dump（）**

```python
user = UserCreate(
    email="alice@example.com",
    username="alice",
    password="secret123"
)

# 转换为字典
user_dict = user.model_dump()
# {"email": "alice@example.com", "username": "alice", "password": "secret123"}

# 排除某些字段
user_dict = user.model_dump(exclude={"password"})
# {"email": "alice@example.com", "username": "alice"}

# 只包含已设置的字段
update = UserUpdate(email="new@example.com")
update_dict = update.model_dump(exclude_unset=True)
# {"email": "new@example.com"}  ← 只有 email，username 和 password 被排除
```

**项目示例：**
```python
# app/crud/user.py
async def update(self, db: AsyncSession, db_user: User, user_in: UserUpdate) -> User:
    update_data = user_in.model_dump(exclude_unset=True)
    #                     ^^^^^^^^^^^^^^^^^^^^^^^^^^
    #                     只获取用户实际设置的字段
    
    for field, value in update_data.items():
        setattr(db_user, field, value)
    
    return db_user
```

### **8.4 from_attributes（从 ORM 对象创建）**

```python
class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    #              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #              允许从对象属性创建
    
    id: int
    username: str
    email: str

# 从 ORM 对象创建
from app.models.user import User

db_user = User(id=1, username="alice", email="alice@example.com")
user_response = UserResponse.model_validate(db_user)
#                           ^^^^^^^^^^^^^^^
#                           从对象转换
print(user_response.username)  # "alice"
```

---

## 9. 常见错误示例

### **9.1 缺少必填字段**

```python
class User(BaseModel):
    name: str
    age: int

# ❌ 缺少 age
user = User(name="Alice")
# ValidationError: field required (type=value_error.missing)
```

### **9.2 类型错误**

```python
class User(BaseModel):
    age: int

# ❌ 传入字符串（无法转换）
user = User(age="abc")
# ValidationError: value is not a valid integer
```

### **9.3 邮箱格式错误**

```python
class User(BaseModel):
    email: EmailStr

# ❌ 无效邮箱
user = User(email="not-an-email")
# ValidationError: value is not a valid email address
```

### **9.4 字符串长度不符**

```python
class User(BaseModel):
    username: str = Field(min_length=3, max_length=10)

# ❌ 太短
user = User(username="ab")
# ValidationError: ensure this value has at least 3 characters

# ❌ 太长
user = User(username="this-is-too-long")
# ValidationError: ensure this value has at most 10 characters
```

---

## 10. 实战练习

### **练习 1：创建商品模型**

```python
from pydantic import BaseModel, Field

class Product(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    price: float = Field(..., gt=0)  # 价格必须大于 0
    quantity: int = Field(..., ge=0)  # 库存必须大于等于 0
    is_available: bool = True

# 测试
product = Product(
    name="iPhone 15",
    price=999.99,
    quantity=10
)
print(product.model_dump())
```

### **练习 2：创建文章模型**

```python
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ArticleCreate(BaseModel):
    title: str = Field(..., min_length=5, max_length=200)
    content: str = Field(..., min_length=10)
    author: str
    tags: list[str] = []

class ArticleResponse(ArticleCreate):
    id: int
    created_at: datetime
    views: int = 0

# 测试
article = ArticleCreate(
    title="Pydantic 入门教程",
    content="这是一篇关于 Pydantic 的文章...",
    author="Alice",
    tags=["Python", "FastAPI"]
)
```

---

## 🎯 总结

### **Pydantic 的核心作用：**

1. **数据验证** ← 最重要！
   ```python
   email: EmailStr  # 自动验证邮箱格式
   age: int = Field(ge=0, le=120)  # 年龄范围验证
   ```

2. **自动类型转换**
   ```python
   age: int
   user = User(age="25")  # "25" → 25
   ```

3. **API 文档生成**
   ```python
   @router.post("/register", response_model=UserResponse)
   # FastAPI 自动生成 API 文档
   ```

4. **安全的数据序列化**
   ```python
   class UserResponse(BaseModel):
       username: str
       # 没有 password！自动隐藏敏感字段
   ```

### **记忆公式：**

```python
class MyModel(BaseModel):  # 1. 继承 BaseModel
    field_name: type = Field(验证规则)  # 2. 定义字段和验证规则

# 3. 使用
obj = MyModel(field_name=value)  # 自动验证！
```

### **项目中的使用场景：**

| 文件 | 用途 | Pydantic 模型 |
|------|------|--------------|
| `schemas/user.py` | 请求/响应验证 | UserCreate, UserResponse, UserUpdate |
| `schemas/token.py` | Token 验证 | Token, TokenPayload |
| `core/config.py` | 配置管理 | Settings (BaseSettings) |

---

## 📚 延伸阅读

- **Pydantic 官方文档**: https://docs.pydantic.dev/
- **FastAPI 数据验证**: https://fastapi.tiangolo.com/tutorial/body/
- **Field 验证**: https://docs.pydantic.dev/latest/concepts/fields/

---

🎉 **现在你应该完全理解 Pydantic 了！**

**一句话总结：Pydantic = 数据的"保镖"，确保数据格式正确、类型安全！**
