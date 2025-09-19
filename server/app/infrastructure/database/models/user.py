import uuid
from sqlalchemy import Column, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.types import TypeDecorator, CHAR

from app.infrastructure.database.session import Base


class GUID(TypeDecorator):
    """SQLite 호환 UUID 타입"""
    impl = CHAR
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(UUID())
        else:
            return dialect.type_descriptor(CHAR(36))

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        elif dialect.name == 'postgresql':
            return str(value)
        else:
            if not isinstance(value, uuid.UUID):
                return str(uuid.UUID(value))
            return str(value)

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        else:
            if not isinstance(value, uuid.UUID):
                return uuid.UUID(value)
            return value


class User(Base):
    """
    사용자 정보를 저장하는 ORM 모델 (API 명세서 기준)
    - Base를 상속받아 SQLAlchemy가 이 클래스를 테이블과 매핑합니다.
    """
    __tablename__ = "users"

    # Primary Key, UUID v4를 기본값으로 사용 (SQLite 호환)
    id = Column(GUID(), primary_key=True, default=uuid.uuid4)

    # 이메일, 고유해야 하며 인덱스 설정으로 조회 성능 향상
    email = Column(String, unique=True, index=True, nullable=False)

    # 해시된 비밀번호 (이메일 로그인용)
    hashed_password = Column(String, nullable=True)

    # 사용자 표시명 (API 명세서 기준)
    display_name = Column(String, nullable=True)

    # 프로필 사진 URL (API 명세서 기준)
    photo_url = Column(String, nullable=True)

    # 로그인 제공자 (API 명세서 기준: email, google, facebook, kakao)
    provider = Column(String, nullable=False, default="email")

    # 이메일 인증 상태 (API 명세서 기준)
    is_email_verified = Column(Boolean, default=False)

    # 계정 활성 상태 (소프트 삭제 등에 사용 가능)
    is_active = Column(Boolean, default=True)

    # 생성 및 수정 시각, 데이터베이스의 now() 함수를 사용
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Medication 및 MedicationRecord 와의 관계 설정
    # 'cascade="all, delete-orphan"' 옵션은 사용자가 삭제될 때
    # 관련된 약물 및 복용 기록도 함께 삭제되도록 합니다.
    medications = relationship("Medication", back_populates="user", cascade="all, delete-orphan")
    medication_records = relationship("MedicationRecord", back_populates="user", cascade="all, delete-orphan")
