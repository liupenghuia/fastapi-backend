"""
用户管理 API 端点
处理用户 CRUD 操作
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.deps import get_current_active_user, get_current_superuser
from app.crud.user import user_crud
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate

router = APIRouter()


@router.get(
    "/me",
    response_model=UserResponse,
    summary="获取当前用户信息",
    description="获取当前登录用户的详细信息。"
)
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
) -> UserResponse:
    """
    获取当前用户信息
    
    需要认证。返回当前登录用户的详细信息。
    """
    return current_user


@router.put(
    "/me",
    response_model=UserResponse,
    summary="更新当前用户信息",
    description="更新当前登录用户的信息。"
)
async def update_current_user(
    user_in: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> UserResponse:
    """
    更新当前用户信息
    
    需要认证。可更新的字段：
    - **email**: 邮箱
    - **username**: 用户名
    - **full_name**: 全名
    - **password**: 密码
    """
    # 检查邮箱是否被其他用户使用
    if user_in.email and user_in.email != current_user.email:
        existing = await user_crud.get_by_email(db, user_in.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="该邮箱已被其他用户使用"
            )
    
    # 检查用户名是否被其他用户使用
    if user_in.username and user_in.username != current_user.username:
        existing = await user_crud.get_by_username(db, user_in.username)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="该用户名已被其他用户使用"
            )
    
    # 普通用户不能更改 is_active 状态
    if user_in.is_active is not None and not current_user.is_superuser:
        user_in.is_active = None
    
    user = await user_crud.update(db, current_user, user_in)
    return user


@router.get(
    "",
    response_model=List[UserResponse],
    summary="获取用户列表",
    description="获取所有用户列表（需要超级管理员权限）。支持分页。"
)
async def get_users(
    skip: int = Query(0, ge=0, description="跳过的记录数"),
    limit: int = Query(100, ge=1, le=100, description="返回的最大记录数"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_superuser)
) -> List[UserResponse]:
    """
    获取用户列表（管理员）
    
    需要超级管理员权限。支持分页查询。
    """
    users = await user_crud.get_list(db, skip=skip, limit=limit)
    return users


@router.get(
    "/{user_id}",
    response_model=UserResponse,
    summary="获取指定用户信息",
    description="根据用户 ID 获取用户信息（需要超级管理员权限）。"
)
async def get_user_by_id(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_superuser)
) -> UserResponse:
    """
    获取指定用户信息（管理员）
    
    需要超级管理员权限。
    """
    user = await user_crud.get_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在"
        )
    return user


@router.put(
    "/{user_id}",
    response_model=UserResponse,
    summary="更新指定用户信息",
    description="更新指定用户的信息（需要超级管理员权限）。"
)
async def update_user(
    user_id: int,
    user_in: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_superuser)
) -> UserResponse:
    """
    更新指定用户信息（管理员）
    
    需要超级管理员权限。可更新所有字段，包括 is_active。
    """
    db_user = await user_crud.get_by_id(db, user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在"
        )
    
    # 检查邮箱是否被其他用户使用
    if user_in.email and user_in.email != db_user.email:
        existing = await user_crud.get_by_email(db, user_in.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="该邮箱已被其他用户使用"
            )
    
    # 检查用户名是否被其他用户使用
    if user_in.username and user_in.username != db_user.username:
        existing = await user_crud.get_by_username(db, user_in.username)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="该用户名已被其他用户使用"
            )
    
    user = await user_crud.update(db, db_user, user_in)
    return user


@router.delete(
    "/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="删除用户",
    description="删除指定用户（需要超级管理员权限）。"
)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_superuser)
):
    """
    删除用户（管理员）
    
    需要超级管理员权限。注意：此操作不可逆。
    """
    db_user = await user_crud.get_by_id(db, user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在"
        )
    
    # 防止删除自己
    if db_user.id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="不能删除自己的账户"
        )
    
    await user_crud.delete(db, db_user)
    return None
