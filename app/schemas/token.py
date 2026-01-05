"""
Token Pydantic Schema
JWT Token 相关的数据模型
"""
from typing import Optional
from pydantic import BaseModel, Field


class Token(BaseModel):
    """Token 响应模式"""
    access_token: str = Field(..., description="JWT Access Token")
    token_type: str = Field(default="bearer", description="Token 类型")


class TokenPayload(BaseModel):
    """Token 载荷模式"""
    sub: Optional[str] = Field(None, description="用户标识（用户名或邮箱）")
    exp: Optional[int] = Field(None, description="过期时间戳")
