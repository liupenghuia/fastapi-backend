"""
认证相关 API 端点
处理用户登录、注册等认证操作
"""
from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.config import settings
from app.core.security import create_access_token
from app.crud.user import user_crud
from app.schemas.user import UserCreate, UserResponse
# from app.schemas import UserCreate, UserResponse  # 使用聚合导入
from app.schemas.token import Token

router = APIRouter()


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="用户注册",
    description="创建新用户账户。用户名和邮箱必须唯一。"
)
async def register(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db)
) -> UserResponse:
    """
    用户注册
    
    - **email**: 有效的邮箱地址（唯一）
    - **username**: 用户名，3-50字符，仅支持字母、数字、下划线和连字符（唯一）
    - **password**: 密码，8-100字符
    - **full_name**: 可选，用户全名
    """
    # 检查邮箱是否已存在
    existing_user = await user_crud.get_by_email(db, user_in.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该邮箱已被注册"
        )
    
    # 检查用户名是否已存在
    existing_user = await user_crud.get_by_username(db, user_in.username)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该用户名已被使用"
        )
    
    # 创建用户
    user = await user_crud.create(db, user_in)
    return user


@router.post(
    "/login",
    response_model=Token,
    summary="用户登录",
    description="使用用户名或邮箱登录，获取 JWT Access Token。"
)
async def login(
    db: AsyncSession = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Token:
    """
    用户登录
    
    使用 OAuth2 密码模式登录：
    - **username**: 用户名或邮箱
    - **password**: 密码
    
    返回 JWT Access Token，用于后续 API 调用认证。
    """
    user = await user_crud.authenticate(db, form_data.username, form_data.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户名或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户账户已被禁用"
        )
    
    # 创建 Access Token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )
    
    return Token(access_token=access_token, token_type="bearer")
