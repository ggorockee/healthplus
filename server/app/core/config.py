from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """OneDayPillo API 애플리케이션 설정"""

    # Pydantic V2 스타일 설정: 정의되지 않은 환경변수는 무시
    model_config = SettingsConfigDict(extra='ignore', case_sensitive=True, env_file=".env", env_file_encoding="utf-8")

    # 데이터베이스 설정 (SQLAlchemy)
    DATABASE_URL: str = Field(..., description="PostgreSQL 연결 문자열")

    # JWT 설정 (API 명세서 기준)
    JWT_SECRET_KEY: str = Field(..., description="JWT 비밀 키")
    JWT_EXPIRES_IN: str = Field("7d", description="액세스 토큰 만료 시간")
    JWT_REFRESH_EXPIRES_IN: str = Field("30d", description="리프레시 토큰 만료 시간")
    JWT_ALGORITHM: str = Field("HS256", description="JWT 알고리즘")
    
    # 기존 호환성을 위한 설정
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(60 * 24 * 7, description="액세스 토큰 만료 시간(분)") # 7 days

    # API 기본 설정 (API 명세서 기준)
    API_VERSION: str = Field("v1", description="API 버전")
    API_TIMEOUT: int = Field(30000, description="API 타임아웃 (밀리초)")
    BASE_URL: str = Field("https://api.onedaypillo.com", description="기본 URL")

    # 앱 설정
    APP_NAME: str = Field("OneDayPillo", description="앱 이름")
    APP_VERSION: str = Field("1.0.0", description="앱 버전")
    APP_ENVIRONMENT: str = Field("development", description="앱 환경")

    # 환경 설정
    DEBUG: bool = Field(True, description="디버그 모드")
    ENVIRONMENT: str = Field("development", description="환경")

    # 소셜 로그인 설정 (API 명세서 기준)
    GOOGLE_CLIENT_ID: Optional[str] = Field(None, description="Google 클라이언트 ID")
    FACEBOOK_APP_ID: Optional[str] = Field(None, description="Facebook 앱 ID")
    KAKAO_CLIENT_ID: Optional[str] = Field(None, description="Kakao 클라이언트 ID")

    # Firebase 설정 (API 명세서 기준)
    FIREBASE_PROJECT_ID: Optional[str] = Field(None, description="Firebase 프로젝트 ID")
    FIREBASE_API_KEY: Optional[str] = Field(None, description="Firebase API 키")

    # AdMob 설정 (API 명세서 기준)
    ADMOB_APP_ID: Optional[str] = Field(None, description="AdMob 앱 ID")
    ADMOB_BANNER_ID: Optional[str] = Field(None, description="AdMob 배너 ID")

    # 알림 설정
    NOTIFICATION_ENABLED: bool = Field(True, description="알림 활성화")
    PUSH_NOTIFICATION_ENABLED: bool = Field(True, description="푸시 알림 활성화")

    # 로깅 설정
    LOG_LEVEL: str = Field("info", description="로그 레벨")

    # Redis 설정
    REDIS_URL: Optional[str] = Field(None, description="Redis 연결 URL")

    # 배포 환경의 Root Path 설정
    ROOT_PATH: str = Field("", description="FastAPI root path for sub-path deployments")

    # 보안 설정
    BCRYPT_ROUNDS: int = Field(12, description="bcrypt 해싱 라운드")


settings = Settings()
