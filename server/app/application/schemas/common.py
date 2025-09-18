"""
OneDayPillo API 공통 응답 스키마
API 명세서에 맞는 표준화된 응답 형식
"""

from datetime import datetime
from typing import Any, Optional, Generic, TypeVar
from pydantic import BaseModel, Field

# 제네릭 타입 변수
T = TypeVar('T')


class APIResponse(BaseModel, Generic[T]):
    """API 성공 응답 스키마"""
    success: bool = Field(True, description="성공 여부")
    data: T = Field(..., description="응답 데이터")
    message: Optional[str] = Field(None, description="성공 메시지")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="응답 시간")


class ErrorDetail(BaseModel):
    """에러 상세 정보"""
    code: str = Field(..., description="에러 코드")
    message: str = Field(..., description="사용자 친화적 메시지")
    details: Optional[str] = Field(None, description="상세 에러 정보")
    field: Optional[str] = Field(None, description="에러가 발생한 필드명")


class APIErrorResponse(BaseModel):
    """API 에러 응답 스키마"""
    success: bool = Field(False, description="성공 여부")
    error: ErrorDetail = Field(..., description="에러 정보")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="응답 시간")


# 편의를 위한 타입 별칭
SuccessResponse = APIResponse
ErrorResponse = APIErrorResponse
