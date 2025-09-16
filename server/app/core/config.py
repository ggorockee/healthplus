import os
from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """애플리케이션 설정"""

    # Supabase 설정
    SUPABASE_URL: str = Field(..., env="SUPABASE_URL")
    SUPABASE_ANON_KEY: str = Field(..., env="SUPABASE_ANON_KEY")
    SUPABASE_SERVICE_ROLE_KEY: str = Field(..., env="SUPABASE_SERVICE_ROLE_KEY")

    # JWT 설정
    JWT_SECRET: str = Field(..., env="JWT_SECRET")
    JWT_EXPIRY_HOURS: int = Field(24, env="JWT_EXPIRY_HOURS")
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

    class Config:
        case_sensitive = True

        @property
        def env_file(self):
            """환경에 따라 다른 .env 파일 로드"""
            environment = os.getenv("ENVIRONMENT", "development")
            env_file = f".env.{environment}"

            # 환경별 파일이 없으면 기본 .env 파일 사용
            if not os.path.exists(env_file):
                return ".env"
            return env_file


def get_settings() -> Settings:
    """환경별 설정 반환"""
    return Settings()


settings = get_settings()