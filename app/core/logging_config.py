"""
日志配置模块
提供结构化、详细的日志记录
"""
import logging
import sys
from pathlib import Path
from loguru import logger
from app.core.config import settings

# 移除默认的 logger 处理器
logger.remove()

# 日志目录
LOG_DIR = Path("/var/log/fastapi") if not settings.DEBUG else Path("logs")
LOG_DIR.mkdir(parents=True, exist_ok=True)

# 日志格式
LOG_FORMAT = (
    "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
    "<level>{level: <8}</level> | "
    "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | "
    "<level>{message}</level>"
)

# 控制台输出（开发环境）
if settings.DEBUG:
    logger.add(
        sys.stdout,
        format=LOG_FORMAT,
        level="DEBUG",
        colorize=True,
    )

# 通用日志文件
logger.add(
    LOG_DIR / "app.log",
    format=LOG_FORMAT,
    level="INFO",
    rotation="00:00",  # 每天午夜轮转
    retention="7 days",  # 保留 7 天
    compression="gz",  # 压缩旧日志
    encoding="utf-8",
)

# 错误日志文件
logger.add(
    LOG_DIR / "error.log",
    format=LOG_FORMAT,
    level="ERROR",
    rotation="100 MB",  # 100MB 轮转
    retention="30 days",  # 保留 30 天
    compression="gz",
    encoding="utf-8",
    backtrace=True,  # 显示完整堆栈
    diagnose=True,  # 显示变量值
)

# JSON 格式日志（便于分析）
logger.add(
    LOG_DIR / "access.json",
    format="{message}",
    level="INFO",
    rotation="00:00",
    retention="7 days",
    compression="gz",
    encoding="utf-8",
    serialize=True,  # JSON 序列化
)


def get_logger(name: str = None):
    """
    获取 logger 实例
    
    Args:
        name: logger 名称
        
    Returns:
        logger 实例
    """
    if name:
        return logger.bind(name=name)
    return logger


# 拦截标准库的 logging
class InterceptHandler(logging.Handler):
    """
    拦截标准库的 logging，转发到 loguru
    """
    def emit(self, record):
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(
            level, record.getMessage()
        )


# 配置标准库 logging
logging.basicConfig(handlers=[InterceptHandler()], level=0)

# 配置 uvicorn 日志
for _log in ["uvicorn", "uvicorn.error", "uvicorn.access"]:
    _logger = logging.getLogger(_log)
    _logger.handlers = [InterceptHandler()]
