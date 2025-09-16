import asyncio
from typing import Optional
from supabase import create_client, Client, ClientOptions
from app.core.config import settings


class SupabaseClient:
    """Supabase 클라이언트 싱글톤"""

    _instance: Optional[Client] = None
    _service_instance: Optional[Client] = None

    @classmethod
    def get_client(cls) -> Client:
        """일반 클라이언트 인스턴스 반환"""
        if cls._instance is None:
            options = ClientOptions(
                auto_refresh_token=True,
                persist_session=True
            )
            cls._instance = create_client(
                settings.SUPABASE_URL,
                settings.SUPABASE_ANON_KEY,
                options=options
            )
        return cls._instance

    @classmethod
    def get_service_client(cls) -> Client:
        """서비스 역할 클라이언트 인스턴스 반환"""
        if cls._service_instance is None:
            options = ClientOptions(
                auto_refresh_token=False,
                persist_session=False
            )
            cls._service_instance = create_client(
                settings.SUPABASE_URL,
                settings.SUPABASE_SERVICE_ROLE_KEY,
                options=options
            )
        return cls._service_instance


async def init_db():
    """데이터베이스 초기화"""
    try:
        client = SupabaseClient.get_client()
        print("✅ Supabase 클라이언트 초기화 완료")

        # 서비스 클라이언트도 초기화
        service_client = SupabaseClient.get_service_client()
        print("✅ Supabase 서비스 클라이언트 초기화 완료")

        # 연결 테스트
        response = service_client.table("user_profiles").select("count", count="exact").execute()
        print(f"✅ 데이터베이스 연결 테스트 완료")

    except Exception as e:
        print(f"❌ Supabase 초기화 실패: {e}")
        print("⚠️  데이터베이스 스키마가 생성되었는지 확인해주세요")
        # 초기화 실패해도 앱이 종료되지 않도록 함
        pass


def get_supabase() -> Client:
    """일반 Supabase 클라이언트 의존성"""
    return SupabaseClient.get_client()


def get_service_supabase() -> Client:
    """서비스 Supabase 클라이언트 의존성"""
    return SupabaseClient.get_service_client()