"""
请求日志中间件
记录每个 API 请求的详细信息
"""
import time
import json
from typing import Callable
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp

from app.core.logging_config import logger


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    请求日志中间件
    记录所有 HTTP 请求的详细信息
    """
    
    def __init__(self, app: ASGIApp):
        super().__init__(app)
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        处理请求并记录日志
        """
        # 请求开始时间
        start_time = time.time()
        
        # 生成请求 ID
        request_id = f"{int(start_time * 1000)}"
        
        # 提取请求信息
        client_ip = request.client.host if request.client else "unknown"
        method = request.method
        path = request.url.path
        query_params = dict(request.query_params)
        
        # 获取用户信息（如果已认证）
        user_info = "anonymous"
        if hasattr(request.state, "user"):
            user = request.state.user
            user_info = getattr(user, "username", "unknown")
        
        # 记录请求开始
        logger.info(
            f"📨 Incoming: {method} {path}",
            extra={
                "request_id": request_id,
                "method": method,
                "path": path,
                "query_params": query_params,
                "client_ip": client_ip,
                "user": user_info,
                "user_agent": request.headers.get("user-agent", ""),
            }
        )
        
        # 处理请求
        try:
            response = await call_next(request)
            
            # 计算处理时间
            process_time = time.time() - start_time
            
            # 记录响应
            log_data = {
                "request_id": request_id,
                "method": method,
                "path": path,
                "status_code": response.status_code,
                "process_time": f"{process_time:.3f}s",
                "client_ip": client_ip,
                "user": user_info,
            }
            
            # 根据状态码选择日志级别
            if response.status_code >= 500:
                logger.error(f"❌ {method} {path} → {response.status_code}", extra=log_data)
            elif response.status_code >= 400:
                logger.warning(f"⚠️  {method} {path} → {response.status_code}", extra=log_data)
            else:
                logger.info(f"✅ {method} {path} → {response.status_code}", extra=log_data)
            
            # 慢查询警告
            if process_time > 1.0:
                logger.warning(
                    f"🐌 Slow request: {method} {path} took {process_time:.3f}s",
                    extra=log_data
                )
            
            # 添加响应头
            response.headers["X-Request-ID"] = request_id
            response.headers["X-Process-Time"] = f"{process_time:.3f}"
            
            return response
            
        except Exception as e:
            # 记录异常
            process_time = time.time() - start_time
            logger.exception(
                f"💥 Error: {method} {path}",
                extra={
                    "request_id": request_id,
                    "method": method,
                    "path": path,
                    "client_ip": client_ip,
                    "user": user_info,
                    "process_time": f"{process_time:.3f}s",
                    "error": str(e),
                }
            )
            raise


class APIAccessLogger:
    """
    API 访问日志记录器（用于业务逻辑）
    """
    
    @staticmethod
    def log_user_action(
        user_id: int,
        username: str,
        action: str,
        resource: str,
        details: dict = None
    ):
        """
        记录用户操作
        
        Args:
            user_id: 用户 ID
            username: 用户名
            action: 操作类型（CREATE, UPDATE, DELETE, VIEW）
            resource: 资源类型（User, Product, Order）
            details: 详细信息
        """
        log_data = {
            "user_id": user_id,
            "username": username,
            "action": action,
            "resource": resource,
            "details": details or {},
            "timestamp": time.time(),
        }
        
        logger.info(
            f"👤 User Action: {username} {action} {resource}",
            extra=log_data
        )
    
    @staticmethod
    def log_security_event(
        event_type: str,
        severity: str,
        details: dict
    ):
        """
        记录安全事件
        
        Args:
            event_type: 事件类型（LOGIN_FAILED, UNAUTHORIZED_ACCESS, etc.）
            severity: 严重程度（LOW, MEDIUM, HIGH, CRITICAL）
            details: 详细信息
        """
        log_data = {
            "event_type": event_type,
            "severity": severity,
            "details": details,
            "timestamp": time.time(),
        }
        
        if severity in ["HIGH", "CRITICAL"]:
            logger.error(f"🚨 Security Event: {event_type}", extra=log_data)
        else:
            logger.warning(f"⚠️  Security Event: {event_type}", extra=log_data)
