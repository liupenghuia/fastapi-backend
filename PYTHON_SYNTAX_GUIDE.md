# 🐍 Python 语法完全指南
## 基于 FastAPI 用户管理项目的实战教程

> 这份教程将结合项目中的真实代码，从零开始讲解 Python 语法

---

## 📚 目录

1. [基础语法](#1-基础语法)
2. [数据类型](#2-数据类型)
3. [函数定义](#3-函数定义)
4. [类和面向对象](#4-类和面向对象)
5. [导入模块](#5-导入模块)
6. [异步编程](#6-异步编程)
7. [类型提示](#7-类型提示)
8. [装饰器](#8-装饰器)
9. [上下文管理器](#9-上下文管理器)
10. [高级特性](#10-高级特性)

---

## 1. 基础语法

### 1.1 注释

```python
# 这是单行注释

"""
这是多行注释（文档字符串）
通常用于函数、类或模块的文档
"""

# 项目示例：app/main.py
"""
FastAPI 应用入口
用户管理 API 系统
"""
```

### 1.2 变量赋值

```python
# 基本赋值
app_name = "用户管理 API"
version = "1.0.0"
port = 8000

# 多重赋值
x, y, z = 1, 2, 3

# 项目示例：app/core/config.py
APP_NAME: str = "用户管理 API"
APP_VERSION: str = "1.0.0"
DEBUG: bool = False
```

**关键知识点：**
- Python 是**动态类型**语言（不需要声明变量类型）
- 但可以使用**类型提示**（`: str`, `: int`）提高可读性
- 变量名使用**下划线命名法**（snake_case）

### 1.3 字符串

```python
# 单引号和双引号等价
name = 'Alice'
email = "alice@example.com"

# 三引号用于多行字符串
description = """
这是一个多行
字符串
"""

# f-string 格式化（Python 3.6+）
username = "admin"
message = f"欢迎, {username}!"  # 结果："欢迎, admin!"

# 项目示例：app/models/user.py
def __repr__(self) -> str:
    return f"<User(id={self.id}, username={self.username}, email={self.email})>"
```

**字符串操作：**
```python
# 拼接
full_name = first_name + " " + last_name

# 长度
length = len(email)  # 17

# 切片
first_three = email[:3]  # "ali"
```

---

## 2. 数据类型

### 2.1 基本类型

```python
# 整数
age = 25
user_id = 12345

# 浮点数
price = 99.99

# 布尔值
is_active = True
is_superuser = False

# None（空值）
full_name = None

# 项目示例：app/models/user.py
is_active: Mapped[bool] = mapped_column(
    Boolean, 
    default=True,  # 默认值为 True
    nullable=False  # 不允许为空
)
```

### 2.2 列表（List）

```python
# 创建列表
users = ["Alice", "Bob", "Charlie"]
numbers = [1, 2, 3, 4, 5]

# 访问元素
first_user = users[0]  # "Alice"
last_user = users[-1]  # "Charlie"（负索引从末尾开始）

# 添加元素
users.append("David")  # ["Alice", "Bob", "Charlie", "David"]

# 列表推导式
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]

# 项目示例：app/crud/user.py
async def get_list(self, db: AsyncSession, skip: int = 0, limit: int = 100) -> List[User]:
    result = await db.execute(
        select(User).offset(skip).limit(limit).order_by(User.id)
    )
    return list(result.scalars().all())  # 转换为列表
```

### 2.3 字典（Dictionary）

```python
# 创建字典
user_dict = {
    "id": 1,
    "username": "alice",
    "email": "alice@example.com"
}

# 访问值
username = user_dict["username"]  # "alice"
email = user_dict.get("email")  # 安全访问，不存在返回 None

# 添加/修改
user_dict["age"] = 25

# 遍历
for key, value in user_dict.items():
    print(f"{key}: {value}")

# 项目示例：app/core/security.py
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()  # 复制字典
    to_encode.update({"exp": expire})  # 更新字典
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
```

### 2.4 元组（Tuple）

```python
# 不可变的序列
coordinates = (10, 20)
user_info = ("alice", "alice@example.com", 25)

# 解包
x, y = coordinates
username, email, age = user_info

# 项目示例：返回多个值
def get_user_info():
    return "alice", "alice@example.com"  # 自动打包为元组

username, email = get_user_info()  # 解包
```

---

## 3. 函数定义

### 3.1 基本函数

```python
# 定义函数
def greet(name):
    return f"Hello, {name}!"

# 调用函数
message = greet("Alice")  # "Hello, Alice!"

# 带类型提示的函数
def add(a: int, b: int) -> int:
    return a + b

# 项目示例：app/core/security.py
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    验证明文密码与哈希密码是否匹配
    
    Args:
        plain_password: 用户输入的明文密码
        hashed_password: 数据库中存储的哈希密码
    
    Returns:
        bool: 密码是否匹配
    """
    password_bytes = plain_password.encode('utf-8')
    hashed_bytes = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password_bytes, hashed_bytes)
```

**关键知识点：**
- 使用 `def` 定义函数
- `: 类型` 表示参数类型提示
- `-> 类型` 表示返回值类型提示
- `"""..."""` 是函数文档字符串（docstring）

### 3.2 默认参数

```python
# 带默认值的参数
def create_user(username: str, is_active: bool = True):
    return {"username": username, "is_active": is_active}

# 调用
user1 = create_user("alice")  # is_active 使用默认值 True
user2 = create_user("bob", False)  # 覆盖默认值

# 项目示例：app/crud/user.py
async def get_list(
    self, 
    db: AsyncSession, 
    skip: int = 0,      # 默认值 0
    limit: int = 100    # 默认值 100
) -> List[User]:
    ...
```

### 3.3 可选参数（Optional）

```python
from typing import Optional

# 参数可以是指定类型或 None
def find_user(user_id: Optional[int] = None) -> Optional[str]:
    if user_id is None:
        return None
    return f"User {user_id}"

# 项目示例：app/core/security.py
def create_access_token(
    data: dict, 
    expires_delta: Optional[timedelta] = None  # 可以传 timedelta 或 None
) -> str:
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=30)
    ...
```

**`Optional[类型]` 等价于 `类型 | None`**

---

## 4. 类和面向对象

### 4.1 定义类

```python
# 基本类定义
class User:
    # 构造函数
    def __init__(self, username: str, email: str):
        self.username = username  # 实例属性
        self.email = email
    
    # 实例方法
    def greet(self):
        return f"Hello, I'm {self.username}"

# 创建实例
user = User("alice", "alice@example.com")
print(user.greet())  # "Hello, I'm alice"

# 项目示例：app/crud/user.py
class UserCRUD:
    """用户 CRUD 操作类"""
    
    async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()
    
    async def create(self, db: AsyncSession, user_in: UserCreate) -> User:
        hashed_password = get_password_hash(user_in.password)
        db_user = User(
            email=user_in.email,
            username=user_in.username,
            hashed_password=hashed_password
        )
        db.add(db_user)
        await db.flush()
        return db_user
```

**关键知识点：**
- `class` 关键字定义类
- `__init__` 是构造函数（初始化方法）
- `self` 代表实例本身（类似其他语言的 `this`）
- 方法的第一个参数必须是 `self`

### 4.2 继承

```python
# 基类
from pydantic import BaseModel

class UserBase(BaseModel):
    """用户基础模式"""
    email: str
    username: str

# 派生类（继承 UserBase）
class UserCreate(UserBase):
    """创建用户请求模式"""
    password: str  # 额外添加的字段

class UserResponse(UserBase):
    """用户响应模式"""
    id: int
    is_active: bool
    created_at: datetime

# 项目示例：app/schemas/user.py
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None

class UserCreate(UserBase):  # 继承 UserBase
    password: str  # 新增字段

class UserResponse(UserBase):  # 继承 UserBase
    id: int
    is_active: bool
    created_at: datetime
```

### 4.3 特殊方法（魔术方法）

```python
class User:
    def __init__(self, username: str):
        self.username = username
    
    # 字符串表示
    def __repr__(self) -> str:
        return f"<User(username={self.username})>"
    
    # 打印时调用
    def __str__(self) -> str:
        return self.username

# 项目示例：app/models/user.py
class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    username: Mapped[str] = mapped_column(String(50))
    
    def __repr__(self) -> str:
        return f"<User(id={self.id}, username={self.username}, email={self.email})>"
```

**常用魔术方法：**
- `__init__`: 构造函数
- `__repr__`: 开发者看的字符串表示
- `__str__`: 用户看的字符串表示
- `__eq__`: 定义 `==` 行为
- `__len__`: 定义 `len()` 行为

---

## 5. 导入模块

### 5.1 基本导入

```python
# 导入整个模块
import datetime
now = datetime.datetime.now()

# 从模块导入特定内容
from datetime import datetime, timedelta
now = datetime.now()

# 使用别名
from datetime import datetime as dt
now = dt.now()

# 导入所有（不推荐）
from datetime import *

# 项目示例：app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import init_db, close_db
from app.api.v1.router import api_router
```

### 5.2 相对导入

```python
# 从当前包导入
from .config import settings  # 同级目录
from ..models.user import User  # 上级目录的 models

# 项目示例：app/api/v1/router.py
from fastapi import APIRouter
from app.api.v1.endpoints import auth, users  # 绝对导入
```

**导入规则：**
- `.` 表示当前目录
- `..` 表示上级目录
- 包内部推荐使用相对导入
- 跨包推荐使用绝对导入

---

## 6. 异步编程

### 6.1 async/await 基础

```python
# 普通函数
def sync_function():
    return "同步结果"

# 异步函数（协程）
async def async_function():
    return "异步结果"

# 调用异步函数
result = await async_function()  # 必须在 async 函数中使用 await

# 项目示例：app/core/database.py
async def get_db() -> AsyncSession:
    """数据库会话依赖注入"""
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()  # await 等待异步操作完成
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

**关键知识点：**
- `async def` 定义异步函数（协程）
- `await` 等待异步操作完成
- `await` 只能在 `async` 函数中使用
- 异步函数返回 `Coroutine` 对象，需要 `await` 才能获取结果

### 6.2 异步数据库操作

```python
# 项目示例：app/crud/user.py
class UserCRUD:
    async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
        # 异步执行 SQL 查询
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()
    
    async def create(self, db: AsyncSession, user_in: UserCreate) -> User:
        db_user = User(...)
        db.add(db_user)
        await db.flush()  # 异步刷新
        await db.refresh(db_user)  # 异步刷新对象
        return db_user
```

### 6.3 为什么使用异步？

```python
# ❌ 同步代码（阻塞）
def slow_operation():
    time.sleep(5)  # 阻塞 5 秒，期间什么都做不了
    return "完成"

# ✅ 异步代码（非阻塞）
async def fast_operation():
    await asyncio.sleep(5)  # 等待期间可以处理其他请求
    return "完成"
```

**异步的优势：**
- 高并发：单线程处理成千上万请求
- I/O 密集型任务（数据库、网络请求）性能大幅提升
- FastAPI 原生支持异步

---

## 7. 类型提示

### 7.1 基本类型提示

```python
# 变量类型提示
name: str = "Alice"
age: int = 25
is_active: bool = True
score: float = 95.5

# 函数类型提示
def greet(name: str) -> str:
    return f"Hello, {name}!"

# 项目示例：app/core/config.py
class Settings(BaseSettings):
    APP_NAME: str = "用户管理 API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DATABASE_URL: str = "sqlite+aiosqlite:///./app.db"
```

### 7.2 复杂类型提示

```python
from typing import Optional, List, Dict, Union

# Optional: 可以是指定类型或 None
def find_user(user_id: int) -> Optional[User]:
    return user or None

# List: 列表类型
def get_users() -> List[User]:
    return [user1, user2, user3]

# Dict: 字典类型
def get_config() -> Dict[str, str]:
    return {"key": "value"}

# Union: 多个类型之一
def process(value: Union[int, str]) -> str:
    return str(value)

# 项目示例：app/crud/user.py
async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
    ...

async def get_list(self, db: AsyncSession, skip: int = 0, limit: int = 100) -> List[User]:
    ...
```

### 7.3 泛型类型

```python
from typing import TypeVar, Generic

# 项目示例：SQLAlchemy 的 Mapped 类型
from sqlalchemy.orm import Mapped

class User(Base):
    id: Mapped[int]  # 表示该字段映射到数据库的 int 类型
    username: Mapped[str]
    is_active: Mapped[bool]
```

---

## 8. 装饰器

### 8.1 什么是装饰器？

装饰器是**修改函数行为的函数**，使用 `@` 语法。

```python
# 简单装饰器示例
def my_decorator(func):
    def wrapper():
        print("函数执行前")
        func()
        print("函数执行后")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

# 调用
say_hello()
# 输出：
# 函数执行前
# Hello!
# 函数执行后
```

### 8.2 FastAPI 路由装饰器

```python
from fastapi import APIRouter

router = APIRouter()

# @router.post 是装饰器
@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    ...

# 等价于：
async def login(form_data):
    ...
login = router.post("/login", response_model=Token)(login)

# 项目示例：app/api/v1/endpoints/auth.py
@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="用户注册",
    description="创建新用户账户。用户名和邮箱必须唯一。"
)
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    ...
```

### 8.3 常用装饰器

```python
# 1. @staticmethod（静态方法）
class MathUtils:
    @staticmethod
    def add(a: int, b: int) -> int:
        return a + b

result = MathUtils.add(1, 2)  # 不需要实例化

# 2. @classmethod（类方法）
class User:
    @classmethod
    def from_dict(cls, data: dict):
        return cls(**data)

# 3. @property（属性装饰器）
class User:
    def __init__(self, first_name: str, last_name: str):
        self._first_name = first_name
        self._last_name = last_name
    
    @property
    def full_name(self) -> str:
        return f"{self._first_name} {self._last_name}"

user = User("Alice", "Smith")
print(user.full_name)  # 像访问属性一样调用方法

# 4. @lru_cache（缓存装饰器）
from functools import lru_cache

@lru_cache()
def get_settings() -> Settings:
    return Settings()  # 只执行一次，后续调用返回缓存

# 项目示例：app/core/config.py
@lru_cache()
def get_settings() -> Settings:
    """获取应用配置（带缓存）"""
    return Settings()

settings = get_settings()  # 第一次调用，创建对象
settings2 = get_settings()  # 返回缓存的对象（settings 和 settings2 是同一个对象）
```

---

## 9. 上下文管理器

### 9.1 with 语句

```python
# 文件操作
with open("file.txt", "r") as f:
    content = f.read()
# 退出 with 块后，文件自动关闭

# 等价于：
f = open("file.txt", "r")
try:
    content = f.read()
finally:
    f.close()
```

### 9.2 异步上下文管理器

```python
# 项目示例：app/core/database.py
async def get_db() -> AsyncSession:
    async with async_session_maker() as session:  # 进入上下文
        try:
            yield session
            await session.commit()  # 成功时提交
        except Exception:
            await session.rollback()  # 失败时回滚
            raise
        finally:
            await session.close()  # 无论如何都关闭
```

### 9.3 @asynccontextmanager

```python
from contextlib import asynccontextmanager

# 项目示例：app/main.py
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时执行
    print("🚀 正在初始化数据库...")
    await init_db()
    print("✅ 数据库初始化完成")
    
    yield  # 应用运行期间
    
    # 关闭时执行
    print("👋 正在关闭数据库连接...")
    await close_db()
    print("✅ 数据库连接已关闭")

app = FastAPI(lifespan=lifespan)
```

**工作流程：**
```
应用启动 → yield 之前的代码 → 应用运行 → 应用关闭 → yield 之后的代码
```

---

## 10. 高级特性

### 10.1 依赖注入（Depends）

```python
from fastapi import Depends

# 定义依赖
async def get_db():
    db = Database()
    try:
        yield db
    finally:
        await db.close()

# 使用依赖
@app.get("/users")
async def get_users(db: Database = Depends(get_db)):
    return await db.query(User).all()

# 项目示例：app/api/deps.py
async def get_current_user(
    db: AsyncSession = Depends(get_db),  # 依赖 1
    token: str = Depends(oauth2_scheme)  # 依赖 2
) -> User:
    payload = decode_access_token(token)
    user = await user_crud.get_by_username(db, payload["sub"])
    return user

# 使用
@router.get("/me")
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user
```

**依赖链：**
```
get_current_superuser
    ↓ Depends
get_current_active_user
    ↓ Depends
get_current_user
    ↓ Depends (get_db, oauth2_scheme)
```

### 10.2 Pydantic 模型

```python
from pydantic import BaseModel, Field, EmailStr

class UserCreate(BaseModel):
    email: EmailStr  # 自动验证邮箱格式
    username: str = Field(
        ...,  # 必填（...表示必需）
        min_length=3,  # 最小长度
        max_length=50,  # 最大长度
        pattern=r"^[a-zA-Z0-9_-]+$"  # 正则验证
    )
    password: str = Field(..., min_length=8)

# 使用
try:
    user = UserCreate(
        email="invalid-email",  # ❌ 格式错误
        username="ab",  # ❌ 太短
        password="123"  # ❌ 太短
    )
except ValidationError as e:
    print(e.errors())

# 项目示例：app/schemas/user.py
class UserBase(BaseModel):
    email: EmailStr = Field(..., description="用户邮箱")
    username: str = Field(
        ..., 
        min_length=3, 
        max_length=50, 
        pattern=r"^[a-zA-Z0-9_-]+$",
        description="用户名（3-50字符，仅支持字母、数字、下划线和连字符）"
    )
```

### 10.3 SQLAlchemy ORM

```python
from sqlalchemy.orm import Mapped, mapped_column

class User(Base):
    __tablename__ = "users"  # 表名
    
    # 列定义
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,  # 唯一约束
        index=True,   # 创建索引
        nullable=False,  # 不允许为空
        comment="用户邮箱"
    )

# 查询示例
result = await db.execute(select(User).where(User.id == user_id))
user = result.scalar_one_or_none()

# 项目示例：app/models/user.py
class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
```

### 10.4 异常处理

```python
# try-except-finally
try:
    result = await db.execute(query)
    await db.commit()
except SQLAlchemyError as e:
    await db.rollback()
    raise HTTPException(status_code=500, detail=str(e))
finally:
    await db.close()

# 抛出 HTTP 异常
from fastapi import HTTPException, status

if not user:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="用户不存在"
    )

# 项目示例：app/api/v1/endpoints/auth.py
existing_user = await user_crud.get_by_email(db, user_in.email)
if existing_user:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="该邮箱已被注册"
    )
```

### 10.5 生成器和 yield

```python
# 生成器函数
def count_up_to(n):
    i = 1
    while i <= n:
        yield i  # 暂停并返回值
        i += 1

for num in count_up_to(5):
    print(num)  # 1, 2, 3, 4, 5

# 异步生成器
async def get_db():
    db = create_session()
    try:
        yield db  # 返回数据库会话
    finally:
        await db.close()

# 项目示例：app/core/database.py
async def get_db() -> AsyncSession:
    async with async_session_maker() as session:
        try:
            yield session  # FastAPI 会将 session 注入到路由函数
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### 10.6 字典解包

```python
# ** 解包字典
user_data = {"email": "alice@example.com", "username": "alice"}
user = User(**user_data)  # 等价于 User(email="alice@example.com", username="alice")

# model_dump
user_in = UserUpdate(email="new@example.com", username="newuser")
update_data = user_in.model_dump(exclude_unset=True)  # 只包含实际设置的字段

# 项目示例：app/crud/user.py
async def update(self, db: AsyncSession, db_user: User, user_in: UserUpdate) -> User:
    update_data = user_in.model_dump(exclude_unset=True)  # 获取更新数据
    
    if "password" in update_data:
        update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
    
    for field, value in update_data.items():
        setattr(db_user, field, value)  # 动态设置属性
    
    return db_user
```

---

## 📝 总结：项目中的关键语法模式

### 1️⃣ 异步路由函数
```python
@router.post("/login", response_model=Token)
async def login(
    db: AsyncSession = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Token:
    user = await user_crud.authenticate(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    return create_access_token(data={"sub": user.username})
```

### 2️⃣ CRUD 操作
```python
class UserCRUD:
    async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()
    
    async def create(self, db: AsyncSession, user_in: UserCreate) -> User:
        db_user = User(**user_in.model_dump(exclude={"password"}))
        db.add(db_user)
        await db.flush()
        return db_user
```

### 3️⃣ Pydantic 数据验证
```python
class UserCreate(BaseModel):
    email: EmailStr = Field(..., description="用户邮箱")
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=8)
```

### 4️⃣ 依赖注入链
```python
async def get_current_superuser(
    current_user: User = Depends(get_current_active_user)
) -> User:
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足")
    return current_user
```

---

## 🎯 学习建议

1. **从基础开始**：先理解变量、函数、类
2. **理解异步**：FastAPI 的核心是异步编程
3. **掌握类型提示**：提高代码可读性和 IDE 支持
4. **学习装饰器**：理解 `@router.get`、`@lru_cache` 等
5. **实践依赖注入**：FastAPI 的精髓
6. **阅读代码**：多看项目中的实际代码

---

## 📚 推荐资源

- **Python 官方教程**: https://docs.python.org/zh-cn/3/tutorial/
- **FastAPI 文档**: https://fastapi.tiangolo.com/zh/
- **SQLAlchemy 文档**: https://docs.sqlalchemy.org/
- **Pydantic 文档**: https://docs.pydantic.dev/

---

🎉 **恭喜！你已经掌握了这个项目所需的所有 Python 语法知识！**
