from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """애플리케이션 설정"""

    # Pydantic V2 스타일 설정: 정의되지 않은 환경변수는 무시
    model_config = SettingsConfigDict(extra='ignore', case_sensitive=True, env_file=".env", env_file_encoding="utf-8")

    # 데이터베이스 설정 (SQLAlchemy)
    DATABASE_URL: str = Field(..., description="PostgreSQL 연결 문자열")

    # JWT 설정
    JWT_SECRET_KEY: str = Field(..., description="JWT 비밀 키")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(60 * 24, description="액세스 토큰 만료 시간(분)") # 1 day
    JWT_ALGORITHM: str = "HS256"

    # 앱 설정
    APP_NAME: str = Field("내 약 관리", env="APP_NAME")
    APP_VERSION: str = Field("1.0.0", env="APP_VERSION")
    APP_ENVIRONMENT: str = Field("development", env="APP_ENVIRONMENT")

    # 환경 설정
    DEBUG: bool = Field(True, env="DEBUG")
    ENVIRONMENT: str = Field("development", env="ENVIRONMENT")

    # 알림 설정
    NOTIFICATION_ENABLED: bool = Field(True, env="NOTIFICATION_ENABLED")
    PUSH_NOTIFICATION_ENABLED: bool = Field(True, env="PUSH_NOTIFICATION_ENABLED")

    # 로깅 설정
    LOG_LEVEL: str = Field("debug", env="LOG_LEVEL")

    # Redis 설정
    REDIS_URL: Optional[str] = Field(None, env="REDIS_URL")


settings = Settings()
