"""
API v1 路由聚合
"""
from fastapi import APIRouter

from app.api.v1.endpoints import auth, users

# 创建 v1 路由器
api_router = APIRouter()

# 注册子路由
api_router.include_router(
    auth.router, 
    prefix="/auth", 
    tags=["🔐 认证"]
)

api_router.include_router(
    users.router, 
    prefix="/users", 
    tags=["👤 用户管理"]
)
