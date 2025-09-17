import uuid
from sqlalchemy import Column, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID

from app.infrastructure.database.session import Base


class User(Base):
    """
    사용자 정보를 저장하는 ORM 모델
    - Base를 상속받아 SQLAlchemy가 이 클래스를 테이블과 매핑합니다.
    """
    __tablename__ = "users"

    # Primary Key, UUID v4를 기본값으로 사용
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # 이메일, 고유해야 하며 인덱스 설정으로 조회 성능 향상
    email = Column(String, unique=True, index=True, nullable=False)

    # 해시된 비밀번호
    hashed_password = Column(String, nullable=False)

    # 사용자 이름
    name = Column(String, nullable=True)

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
