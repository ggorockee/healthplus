import pytest
import uuid
from datetime import datetime, timedelta
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from main import app
from app.infrastructure.database.session import get_db
from app.infrastructure.database.session import Base
from app.infrastructure.database.models.user import User
from app.infrastructure.database.models.medications import Medication, MedicationRecord
from app.infrastructure.database.models.reminders import Reminder, NotificationLog


# 테스트용 데이터베이스 설정
SQLALCHEMY_DATABASE_URL = "sqlite+aiosqlite:///./test.db"

engine = create_async_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    class_=AsyncSession,
)


async def override_get_db():
    """테스트용 데이터베이스 세션"""
    async with TestingSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


@pytest.fixture(scope="session")
async def setup_test_db():
    """테스트 데이터베이스 초기화"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
def client(setup_test_db):
    """테스트 클라이언트"""
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def test_user():
    """테스트용 사용자 데이터"""
    return {
        "email": "test@example.com",
        "password": "testpassword123",
        "display_name": "테스트 사용자"
    }


@pytest.fixture
def test_medication():
    """테스트용 약물 데이터"""
    return {
        "name": "테스트 약물",
        "dosage": "1정",
        "notification_time": {
            "hour": 9,
            "minute": 0
        },
        "repeat_days": [1, 2, 3, 4, 5]  # 월-금
    }


class TestHealthCheck:
    """헬스체크 테스트"""

    def test_health_check(self, client):
        """기본 헬스체크 테스트"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    def test_system_health_check(self, client):
        """시스템 헬스체크 테스트"""
        response = client.get("/v1/system/health")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "timestamp" in data
        assert "version" in data
        assert "database" in data


class TestAuthAPI:
    """인증 API 테스트"""

    def test_register_user(self, client, test_user):
        """사용자 등록 테스트"""
        response = client.post("/v1/auth/register", json=test_user)
        assert response.status_code == 201
        data = response.json()
        assert data["success"] is True
        assert "data" in data
        assert "tokens" in data["data"]

    def test_login_user(self, client, test_user):
        """사용자 로그인 테스트"""
        # 먼저 사용자 등록
        client.post("/v1/auth/register", json=test_user)
        
        # 로그인 시도
        login_data = {
            "email": test_user["email"],
            "password": test_user["password"]
        }
        response = client.post("/v1/auth/login", json=login_data)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "tokens" in data["data"]

    def test_login_invalid_credentials(self, client):
        """잘못된 인증 정보로 로그인 테스트"""
        login_data = {
            "email": "invalid@example.com",
            "password": "wrongpassword"
        }
        response = client.post("/v1/auth/login", json=login_data)
        assert response.status_code == 401
        data = response.json()
        assert data["success"] is False
        assert "error" in data


class TestMedicationAPI:
    """약물 관리 API 테스트"""

    def test_create_medication(self, client, test_user, test_medication):
        """약물 생성 테스트"""
        # 사용자 등록 및 로그인
        client.post("/v1/auth/register", json=test_user)
        login_response = client.post("/v1/auth/login", json={
            "email": test_user["email"],
            "password": test_user["password"]
        })
        token = login_response.json()["data"]["tokens"]["access_token"]
        
        # 약물 생성
        headers = {"Authorization": f"Bearer {token}"}
        response = client.post("/v1/medications/medicine", json=test_medication, headers=headers)
        assert response.status_code == 201
        data = response.json()
        assert data["success"] is True
        assert data["data"]["name"] == test_medication["name"]

    def test_get_medications(self, client, test_user, test_medication):
        """약물 목록 조회 테스트"""
        # 사용자 등록 및 로그인
        client.post("/v1/auth/register", json=test_user)
        login_response = client.post("/v1/auth/login", json={
            "email": test_user["email"],
            "password": test_user["password"]
        })
        token = login_response.json()["data"]["tokens"]["access_token"]
        
        # 약물 생성
        headers = {"Authorization": f"Bearer {token}"}
        client.post("/v1/medications/medicine", json=test_medication, headers=headers)
        
        # 약물 목록 조회
        response = client.get("/v1/medications/medicine", headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "medications" in data["data"]
        assert len(data["data"]["medications"]) == 1

    def test_get_medication_unauthorized(self, client):
        """인증되지 않은 사용자의 약물 조회 테스트"""
        response = client.get("/v1/medications/medicine")
        assert response.status_code == 401


class TestAnalyticsAPI:
    """통계 API 테스트"""

    def test_get_medication_stats(self, client, test_user):
        """약물 통계 조회 테스트"""
        # 사용자 등록 및 로그인
        client.post("/v1/auth/register", json=test_user)
        login_response = client.post("/v1/auth/login", json={
            "email": test_user["email"],
            "password": test_user["password"]
        })
        token = login_response.json()["data"]["tokens"]["access_token"]
        
        # 통계 조회
        headers = {"Authorization": f"Bearer {token}"}
        response = client.get("/v1/analytics/medication-stats", headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "total_medications" in data["data"]
        assert "total_logs" in data["data"]
        assert "compliance_rate" in data["data"]


class TestSystemAPI:
    """시스템 API 테스트"""

    def test_get_version_info(self, client):
        """버전 정보 조회 테스트"""
        response = client.get("/v1/system/version")
        assert response.status_code == 200
        data = response.json()
        assert "version" in data["data"]
        assert "build_number" in data["data"]
        assert "release_date" in data["data"]

    def test_get_system_config(self, client):
        """시스템 설정 조회 테스트"""
        response = client.get("/v1/system/config")
        assert response.status_code == 200
        data = response.json()
        assert "config" in data["data"]
        assert "last_updated" in data["data"]

    def test_ping(self, client):
        """핑 테스트"""
        response = client.get("/v1/system/ping")
        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "pong"


class TestErrorHandling:
    """에러 처리 테스트"""

    def test_not_found_error(self, client):
        """404 에러 테스트"""
        response = client.get("/v1/nonexistent-endpoint")
        assert response.status_code == 404

    def test_method_not_allowed(self, client):
        """405 에러 테스트"""
        response = client.post("/v1/system/health")
        assert response.status_code == 405

    def test_validation_error(self, client, test_user):
        """유효성 검사 에러 테스트"""
        # 잘못된 이메일 형식으로 등록 시도
        invalid_user = test_user.copy()
        invalid_user["email"] = "invalid-email"
        
        response = client.post("/v1/auth/register", json=invalid_user)
        assert response.status_code == 422  # Validation Error


# 통합 테스트
class TestIntegration:
    """통합 테스트"""

    def test_complete_medication_workflow(self, client, test_user, test_medication):
        """완전한 약물 관리 워크플로우 테스트"""
        # 1. 사용자 등록
        register_response = client.post("/v1/auth/register", json=test_user)
        assert register_response.status_code == 201
        
        # 2. 로그인
        login_response = client.post("/v1/auth/login", json={
            "email": test_user["email"],
            "password": test_user["password"]
        })
        assert login_response.status_code == 200
        token = login_response.json()["data"]["tokens"]["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        # 3. 약물 생성
        medication_response = client.post("/v1/medications/medicine", json=test_medication, headers=headers)
        assert medication_response.status_code == 201
        medication_id = medication_response.json()["data"]["id"]
        
        # 4. 약물 조회
        get_medication_response = client.get(f"/v1/medications/medicine/{medication_id}", headers=headers)
        assert get_medication_response.status_code == 200
        
        # 5. 복용 로그 생성
        log_data = {
            "medication_id": medication_id,
            "taken_at": datetime.utcnow().isoformat(),
            "is_taken": True,
            "note": "테스트 복용"
        }
        log_response = client.post("/v1/medications/medication-log", json=log_data, headers=headers)
        assert log_response.status_code == 201
        
        # 6. 통계 조회
        stats_response = client.get("/v1/analytics/medication-stats", headers=headers)
        assert stats_response.status_code == 200
        assert stats_response.json()["data"]["total_medications"] == 1
        assert stats_response.json()["data"]["total_logs"] == 1
