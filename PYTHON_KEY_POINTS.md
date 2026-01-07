# 🎯 Python 语法重难点速查手册
> 基于 FastAPI 项目的关键知识点总结

## 📊 重难点排名

### ⭐⭐⭐⭐⭐ 最重要（必须掌握）

#### 1. 异步编程 (async/await)
这是 FastAPI 项目的核心！

```python
# ✅ 正确：异步函数
async def get_user(db: AsyncSession, user_id: int):
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# ❌ 错误：在异步函数中忘记 await
async def get_user(db: AsyncSession, user_id: int):
    result = db.execute(select(User).where(User.id == user_id))  # 返回协程对象，不是结果！
    return result.scalar_one_or_none()
```

**关键点：**
- `async def` 定义异步函数
- `await` 等待异步操作完成
- 异步函数必须在异步环境中调用

**常见错误：**
```python
# ❌ 忘记 await
user = async_function()  # 返回协程对象，不是结果

# ✅ 正确
user = await async_function()  # 返回实际结果
```

---

#### 2. 类型提示 (Type Hints)
让代码更清晰，IDE 更智能

```python
from typing import Optional, List

# 基础类型
def greet(name: str) -> str:
    return f"Hello, {name}"

# Optional: 可以是某类型或 None
def find_user(user_id: int) -> Optional[User]:
    return user or None

# List: 列表类型
def get_users() -> List[User]:
    return [user1, user2, user3]

# 项目实例
async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
    #                       ↑ 参数类型      ↑ 参数类型    ↑ 返回值类型
    ...
```

**为什么重要：**
- IDE 自动补全
- 类型检查
- 代码可读性
- 文档自动生成

---

#### 3. 依赖注入 (Depends)
FastAPI 的灵魂

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

# 定义依赖
async def get_db() -> AsyncSession:
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except:
            await session.rollback()
            raise

# 使用依赖
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)  # ← 依赖注入
):
    return await user_crud.get_by_id(db, user_id)
```

**依赖链示例：**
```python
# 依赖层级： 
# get_current_superuser 
#   → Depends(get_current_active_user)
#       → Depends(get_current_user)
#           → Depends(get_db)

@router.get("/admin")
async def admin_only(
    current_user: User = Depends(get_current_superuser)  # 自动执行整个依赖链
):
    return {"message": f"Welcome admin {current_user.username}"}
```

---

#### 4. 装饰器 (@decorator)
修改函数行为的魔法

```python
# FastAPI 路由装饰器
@router.post(
    "/register",              # 路径
    response_model=UserResponse,  # 响应模型
    status_code=201,          # 状态码
    summary="用户注册",        # API 文档标题
    description="创建新用户"   # API 文档描述
)
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    return await user_crud.create(db, user_in)

# 等价于：
async def register(user_in, db):
    ...
register = router.post(...)(register)  # 装饰器就是这样工作的
```

**常用装饰器：**
```python
# 1. 路由装饰器
@router.get("/users")
@router.post("/users")
@router.put("/users/{id}")
@router.delete("/users/{id}")

# 2. 缓存装饰器
from functools import lru_cache

@lru_cache()
def get_settings():
    return Settings()  # 只执行一次，后续返回缓存

# 3. 属性装饰器
class User:
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"

user.full_name  # 像属性一样访问
```

---

### ⭐⭐⭐⭐ 很重要（需要理解）

#### 5. 上下文管理器 (with / async with)

```python
# 同步上下文管理器
with open("file.txt") as f:
    content = f.read()
# 自动关闭文件

# 异步上下文管理器
async def get_db():
    async with async_session_maker() as session:  # 进入上下文
        try:
            yield session
            await session.commit()
        except:
            await session.rollback()
        finally:
            await session.close()  # 自动关闭会话
```

**生命周期管理：**
```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时
    print("🚀 初始化数据库")
    await init_db()
    
    yield  # 应用运行中
    
    # 关闭时
    print("👋 关闭数据库")
    await close_db()

app = FastAPI(lifespan=lifespan)
```

---

#### 6. Pydantic 数据验证

```python
from pydantic import BaseModel, Field, EmailStr

class UserCreate(BaseModel):
    email: EmailStr  # 自动验证邮箱格式
    username: str = Field(
        ...,  # 必填
        min_length=3,
        max_length=50,
        pattern=r"^[a-zA-Z0-9_-]+$"  # 正则验证
    )
    password: str = Field(..., min_length=8)

# 自动验证
try:
    user = UserCreate(
        email="invalid",  # ❌ 格式错误
        username="ab",    # ❌ 太短
        password="123"    # ❌ 太短
    )
except ValidationError as e:
    print(e.errors())
```

**常用方法：**
```python
# model_dump: 转为字典
user_dict = user_in.model_dump()

# exclude_unset: 只包含实际设置的字段
update_data = user_in.model_dump(exclude_unset=True)

# exclude: 排除某些字段
data = user_in.model_dump(exclude={"password"})
```

---

#### 7. SQLAlchemy ORM

```python
from sqlalchemy.orm import Mapped, mapped_column

class User(Base):
    __tablename__ = "users"
    
    # Mapped[类型] - 映射到数据库的字段
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,    # 唯一
        index=True,     # 索引
        nullable=False  # 非空
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
```

**CRUD 操作：**
```python
# 查询
result = await db.execute(select(User).where(User.id == user_id))
user = result.scalar_one_or_none()

# 创建
db_user = User(email="test@example.com", username="test")
db.add(db_user)
await db.flush()  # 刷新获取ID

# 更新
user.username = "new_name"
# 会话会自动追踪变化

# 删除
await db.delete(user)
await db.commit()
```

---

### ⭐⭐⭐ 重要（经常使用）

#### 8. 字典和列表操作

```python
# 字典解包
user_data = {"email": "test@example.com", "username": "test"}
user = User(**user_data)  # 等价于 User(email="...", username="...")

# 列表推导式
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]

# 字典推导式
name_lengths = {name: len(name) for name in ["Alice", "Bob"]}
# {"Alice": 5, "Bob": 3}

# 过滤
active_users = [u for u in users if u.is_active]
```

---

#### 9. 异常处理

```python
from fastapi import HTTPException, status

# 抛出 HTTP 异常
if not user:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="用户不存在"
    )

# try-except-finally
try:
    result = await db.execute(query)
    await db.commit()
except SQLAlchemyError as e:
    await db.rollback()
    raise HTTPException(status_code=500, detail=str(e))
finally:
    await db.close()
```

---

#### 10. f-string 格式化

```python
# 基础用法
name = "Alice"
age = 25
message = f"Hello, {name}! You are {age} years old."

# 表达式
result = f"2 + 2 = {2 + 2}"  # "2 + 2 = 4"

# 在项目中的应用
def __repr__(self):
    return f"<User(id={self.id}, username={self.username})>"

# 调试技巧（Python 3.8+）
x = 10
print(f"{x=}")  # x=10
```

---

## 🔥 最容易出错的地方

### 1. 忘记 await

```python
# ❌ 错误
user = get_user_async(user_id)  # 返回 coroutine 对象

# ✅ 正确
user = await get_user_async(user_id)  # 返回实际结果
```

### 2. 在非异步函数中使用 await

```python
# ❌ 错误
def my_function():
    user = await get_user(1)  # SyntaxError

# ✅ 正确
async def my_function():
    user = await get_user(1)
```

### 3. 类型提示中忘记 Optional

```python
# ❌ 可能有问题
def find_user(user_id: int) -> User:
    user = db.query(User).filter(User.id == user_id).first()
    return user  # 可能返回 None！

# ✅ 正确
def find_user(user_id: int) -> Optional[User]:
    user = db.query(User).filter(User.id == user_id).first()
    return user  # 明确可能返回 None
```

### 4. 字典解包时字段名不匹配

```python
# ❌ 错误
user_data = {"mail": "test@example.com"}  # 字段名错误
user = User(**user_data)  # TypeError: unexpected keyword argument 'mail'

# ✅ 正确
user_data = {"email": "test@example.com"}
user = User(**user_data)
```

### 5. 依赖注入的顺序

```python
# ❌ 错误：Depends 必须是默认参数
@router.get("/users/{user_id}")
async def get_user(
    db: AsyncSession = Depends(get_db),
    user_id: int  # 位置参数不能在默认参数后面
):
    ...

# ✅ 正确
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,  # 位置参数在前
    db: AsyncSession = Depends(get_db)  # 默认参数在后
):
    ...
```

---

## 📚 最常用的代码模式

### 模式 1: FastAPI 路由函数

```python
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    user_in: UserCreate,                      # 请求体
    db: AsyncSession = Depends(get_db)        # 依赖注入
):
    # 业务逻辑
    user = await user_crud.create(db, user_in)
    return user
```

### 模式 2: CRUD 查询

```python
async def get_by_id(self, db: AsyncSession, id: int) -> Optional[Model]:
    result = await db.execute(select(Model).where(Model.id == id))
    return result.scalar_one_or_none()
```

### 模式 3: 数据验证

```python
class ModelCreate(BaseModel):
    field: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
```

### 模式 4: 异常处理

```python
if not instance:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="资源不存在"
    )
```

### 模式 5: 数据更新

```python
update_data = model_in.model_dump(exclude_unset=True)
for field, value in update_data.items():
    setattr(db_model, field, value)
await db.commit()
```

---

## 🎯 学习路线建议

### 第 1 阶段：基础语法 (1-2天)
- ✅ 变量、字符串、列表、字典
- ✅ 函数定义
- ✅ 基本类定义

### 第 2 阶段：核心概念 (3-5天)
- ✅ **异步编程** ⭐⭐⭐⭐⭐
- ✅ **类型提示** ⭐⭐⭐⭐⭐
- ✅ **装饰器** ⭐⭐⭐⭐

### 第 3 阶段：框架特性 (5-7天)
- ✅ **依赖注入** ⭐⭐⭐⭐⭐
- ✅ **Pydantic 验证** ⭐⭐⭐⭐
- ✅ **SQLAlchemy ORM** ⭐⭐⭐⭐

### 第 4 阶段：实战练习 (持续)
- ✅ 阅读项目代码
- ✅ 修改功能
- ✅ 添加新功能

---

## 🔍 快速查找技巧

**看到这个 → 查这个章节**

| 代码特征 | 对应知识点 | 重要度 |
|---------|----------|--------|
| `async def` | 异步编程 | ⭐⭐⭐⭐⭐ |
| `await` | 异步编程 | ⭐⭐⭐⭐⭐ |
| `Depends(...)` | 依赖注入 | ⭐⭐⭐⭐⭐ |
| `@router.get` | 装饰器 | ⭐⭐⭐⭐⭐ |
| `-> Optional[User]` | 类型提示 | ⭐⭐⭐⭐⭐ |
| `async with` | 上下文管理器 | ⭐⭐⭐⭐ |
| `BaseModel` | Pydantic | ⭐⭐⭐⭐ |
| `Mapped[int]` | SQLAlchemy ORM | ⭐⭐⭐⭐ |
| `f"{var}"` | f-string | ⭐⭐⭐ |
| `**dict` | 字典解包 | ⭐⭐⭐ |

---

## 💡 记忆口诀

**异步三件套：**
```
async 定义函数
await 等待结果
Depends 注入依赖
```

**类型提示三剑客：**
```
Optional - 可能为 None
List - 列表类型
Mapped - ORM 映射
```

**Pydantic 三要素：**
```
BaseModel - 继承基类
Field - 字段约束
model_dump - 转字典
```

---

## 📖 推荐阅读顺序

在 `PYTHON_SYNTAX_GUIDE.md` 中：

1. **第 6 节：异步编程** ← 最重要！
2. **第 7 节：类型提示** ← IDE 智能提示的基础
3. **第 8 节：装饰器** ← 理解 FastAPI 路由
4. **第 10.1 节：依赖注入** ← FastAPI 核心
5. **第 10.2 节：Pydantic** ← 数据验证
6. **第 10.3 节：SQLAlchemy** ← 数据库操作

其他章节可以需要时再查阅。

---

**总结：掌握这份速查手册，你就能读懂和修改 90% 的项目代码！** 🎉
