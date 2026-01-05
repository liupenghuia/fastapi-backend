"""
FastAPI 应用入口
用户管理 API 系统
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import init_db, close_db
from app.api.v1.router import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    应用生命周期管理
    处理启动和关闭时的资源初始化和清理
    """
    # 启动时初始化数据库
    print("🚀 正在初始化数据库...")
    await init_db()
    print("✅ 数据库初始化完成")
    
    yield
    
    # 关闭时清理资源
    print("👋 正在关闭数据库连接...")
    await close_db()
    print("✅ 数据库连接已关闭")


# 创建 FastAPI 应用实例
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## 🚀 用户管理 API 系统

这是一个基于 FastAPI 构建的现代化用户管理 API 系统，提供以下功能：

### 🔐 认证功能
- 用户注册
- JWT Token 登录
- Token 刷新

### 👤 用户管理
- 获取当前用户信息
- 更新用户资料
- 用户列表查询（管理员）
- 用户 CRUD 操作（管理员）

### 🛡️ 安全特性
- 基于 JWT 的身份认证
- bcrypt 密码哈希
- 基于角色的权限控制
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan
)

# 配置 CORS 中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应该配置具体的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册 API 路由
app.include_router(api_router, prefix="/api/v1")


@app.get("/", tags=["🏠 根路径"])
async def root():
    """
    API 根路径 （还会）
    返回应用基本信息
    """
    return {
        "message": "欢迎使用用户管理 API",
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health", tags=["❤️ 健康检查"])
async def health_check():
    """
    健康检查端点
    用于监控和负载均衡器探测
    """
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "version": settings.APP_VERSION
    }
