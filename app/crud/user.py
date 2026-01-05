"""
用户 CRUD 操作
封装所有用户相关的数据库操作
"""
from typing import Optional, List
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash, verify_password


class UserCRUD:
    """用户 CRUD 操作类"""
    
    async def get_by_id(self, db: AsyncSession, user_id: int) -> Optional[User]:
        """
        根据 ID 获取用户
        
        Args:
            db: 数据库会话
            user_id: 用户 ID
        
        Returns:
            User | None: 用户对象或 None
        """
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()
    
    async def get_by_email(self, db: AsyncSession, email: str) -> Optional[User]:
        """
        根据邮箱获取用户
        
        Args:
            db: 数据库会话
            email: 用户邮箱
        
        Returns:
            User | None: 用户对象或 None
        """
        result = await db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()
    
    async def get_by_username(self, db: AsyncSession, username: str) -> Optional[User]:
        """
        根据用户名获取用户
        
        Args:
            db: 数据库会话
            username: 用户名
        
        Returns:
            User | None: 用户对象或 None
        """
        result = await db.execute(select(User).where(User.username == username))
        return result.scalar_one_or_none()
    
    async def get_list(
        self, 
        db: AsyncSession, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[User]:
        """
        获取用户列表（分页）
        
        Args:
            db: 数据库会话
            skip: 跳过数量
            limit: 返回数量限制
        
        Returns:
            List[User]: 用户列表
        """
        result = await db.execute(
            select(User)
            .offset(skip)
            .limit(limit)
            .order_by(User.id)
        )
        return list(result.scalars().all())
    
    async def get_count(self, db: AsyncSession) -> int:
        """
        获取用户总数
        
        Args:
            db: 数据库会话
        
        Returns:
            int: 用户总数
        """
        result = await db.execute(select(func.count(User.id)))
        return result.scalar_one()
    
    async def create(self, db: AsyncSession, user_in: UserCreate) -> User:
        """
        创建新用户
        
        Args:
            db: 数据库会话
            user_in: 用户创建数据
        
        Returns:
            User: 创建的用户对象
        """
        hashed_password = get_password_hash(user_in.password)
        
        db_user = User(
            email=user_in.email,
            username=user_in.username,
            hashed_password=hashed_password,
            full_name=user_in.full_name
        )
        
        db.add(db_user)
        await db.flush()
        await db.refresh(db_user)
        
        return db_user
    
    async def update(
        self, 
        db: AsyncSession, 
        db_user: User, 
        user_in: UserUpdate
    ) -> User:
        """
        更新用户信息
        
        Args:
            db: 数据库会话
            db_user: 要更新的用户对象
            user_in: 更新数据
        
        Returns:
            User: 更新后的用户对象
        """
        update_data = user_in.model_dump(exclude_unset=True)
        
        # 如果更新密码，需要哈希处理
        if "password" in update_data:
            update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
        
        for field, value in update_data.items():
            setattr(db_user, field, value)
        
        await db.flush()
        await db.refresh(db_user)
        
        return db_user
    
    async def delete(self, db: AsyncSession, db_user: User) -> bool:
        """
        删除用户
        
        Args:
            db: 数据库会话
            db_user: 要删除的用户对象
        
        Returns:
            bool: 删除是否成功
        """
        await db.delete(db_user)
        await db.flush()
        return True
    
    async def authenticate(
        self, 
        db: AsyncSession, 
        username: str, 
        password: str
    ) -> Optional[User]:
        """
        验证用户身份
        
        Args:
            db: 数据库会话
            username: 用户名或邮箱
            password: 密码
        
        Returns:
            User | None: 验证成功返回用户对象，失败返回 None
        """
        # 尝试通过用户名查找
        user = await self.get_by_username(db, username)
        
        # 如果用户名找不到，尝试通过邮箱查找
        if not user:
            user = await self.get_by_email(db, username)
        
        if not user:
            return None
        
        if not verify_password(password, user.hashed_password):
            return None
        
        return user


# 全局用户 CRUD 实例
user_crud = UserCRUD()
