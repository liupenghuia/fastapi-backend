"""
用户 Pydantic Schema
用于请求/响应数据验证和序列化
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, ConfigDict


class UserBase(BaseModel):
    """用户基础模式"""
    email: EmailStr = Field(..., description="用户邮箱")
    username: str = Field(
        ..., 
        min_length=3, 
        max_length=50, 
        pattern=r"^[a-zA-Z0-9_-]+$",
        description="用户名（3-50字符，仅支持字母、数字、下划线和连字符）"
    )
    full_name: Optional[str] = Field(
        None, 
        max_length=100,
        description="用户全名"
    )


class UserCreate(UserBase):
    """创建用户请求模式"""
    password: str = Field(
        ..., 
        min_length=8, 
        max_length=100,
        description="密码（8-100字符）"
    )


class UserUpdate(BaseModel):
    """更新用户请求模式（所有字段可选）"""
    email: Optional[EmailStr] = Field(None, description="用户邮箱")
    username: Optional[str] = Field(
        None, 
        min_length=3, 
        max_length=50,
        pattern=r"^[a-zA-Z0-9_-]+$",
        description="用户名"
    )
    full_name: Optional[str] = Field(None, max_length=100, description="用户全名")
    password: Optional[str] = Field(
        None, 
        min_length=8, 
        max_length=100,
        description="新密码"
    )
    is_active: Optional[bool] = Field(None, description="账户是否激活")


class UserResponse(UserBase):
    """用户响应模式"""
    model_config = ConfigDict(from_attributes=True)
    
    id: int = Field(..., description="用户ID")
    is_active: bool = Field(..., description="账户是否激活")
    is_superuser: bool = Field(..., description="是否为超级管理员")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")


class UserInDB(UserResponse):
    """数据库用户模式（包含哈希密码）"""
    hashed_password: str
