# HealthPlus API 서버 분석 보고서

## 1. 프로젝트 개요

HealthPlus API 서버는 모바일 애플리케이션을 위한 약물 복용 관리 백엔드 시스템입니다. FastAPI를 기반으로 구축되었으며, 사용자 인증, 약물 정보 관리, 복용 기록 추적 및 통계 기능을 제공합니다. Supabase (PostgreSQL)를 데이터베이스로 사용하여 안정적인 데이터 관리를 지원하며, 비동기 처리를 통해 높은 성능을 제공합니다.

## 2. 기술 스택

- **웹 프레임워크**: FastAPI
- **데이터베이스**: Supabase (PostgreSQL)
- **인증**: JWT (JSON Web Tokens)
- **비동기 서버**: Uvicorn, Gunicorn
- **데이터 검증**: Pydantic
- **ORM**: SQLAlchemy (Asyncio support)
- **의존성 관리**: pip, requirements.txt
- **배포**: Docker, Kubernetes (Helm)

## 3. 프로젝트 구조

```
server/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── endpoints/
│   │       │   ├── auth.py          # 인증 엔드포인트
│   │       │   └── medications.py   # 약물 관리 엔드포인트
│   │       ├── deps.py              # 의존성 주입
│   │       └── router.py            # API 라우터
│   ├── application/
│   │   ├── repositories/          # 데이터베이스 추상화 레포지토리
│   │   ├── schemas/               # Pydantic 스키마
│   │   └── services/              # 비즈니스 로직
│   ├── core/
│   │   ├── config.py              # 환경 변수 및 설정
│   │   └── exceptions.py          # 커스텀 예외 처리
│   ├── domain/
│   │   └── models/                # 도메인 모델 (미래 확장용)
│   ├── infrastructure/
│   │   ├── database/
│   │   │   ├── models/            # SQLAlchemy 모델
│   │   │   └── session.py         # 데이터베이스 세션 관리
│   │   └── repositories/          # 레포지토리 구현체
│   └── main.py                    # FastAPI 앱 초기화
├── charts/                        # Helm 차트
├── Dockerfile                     # Docker 이미지 빌드 파일
├── requirements.txt               # Python 의존성 목록
└── ...
```

## 4. 핵심 기능

- **사용자 관리**: 회원가입, 로그인, 프로필 관리
- **약물 관리**: 약물 등록, 조회, 수정, 삭제
- **복용 기록**: 복용 기록 추가, 조회, 수정
- **통계**: 월별 복용 통계 조회

## 5. API 엔드포인트

### 인증 (`/v1/auth`)
- `POST /signup`: 회원가입
- `POST /signin`: 로그인
- `GET /me`: 내 정보 조회
- `POST /logout`: 로그아웃
- `PUT /profile`: 프로필 수정

### 약물 (`/v1/medications`)
- `POST /`: 약물 추가
- `GET /`: 내 약물 목록 조회
- `GET /{medication_id}`: 특정 약물 조회
- `PUT /{medication_id}`: 약물 정보 수정
- `DELETE /{medication_id}`: 약물 삭제
- `POST /records`: 복용 기록 추가
- `GET /records/daily`: 일별 복용 기록 조회
- `PUT /records/{record_id}`: 복용 기록 수정
- `GET /statistics/monthly`: 월별 복용 통계

## 6. 데이터베이스 스키마

`database_schema.sql` 파일에 정의된 스키마를 기반으로 하며, 주요 테이블은 다음과 같습니다.

- `users`: 사용자 정보
- `medications`: 약물 정보
- `medication_records`: 약물 복용 기록
- `medication_schedules`: 약물 복용 스케줄

## 7. 설정 (Configuration)

`.env` 파일을 통해 환경 변수를 설정합니다. 주요 설정은 `app/core/config.py`에 정의되어 있습니다.

- `DATABASE_URL`: Supabase 데이터베이스 연결 URL
- `JWT_SECRET_KEY`: JWT 서명에 사용되는 비밀 키
- `ACCESS_TOKEN_EXPIRE_MINUTES`: 액세스 토큰 만료 시간
- `DEBUG`: 디버그 모드 활성화

## 8. 설치 및 실행

1.  **의존성 설치**: `pip install -r requirements.txt`
2.  **환경 변수 설정**: `.env.example` 파일을 복사하여 `.env` 파일 생성 후, 내부 값 설정
3.  **데이터베이스 마이그레이션**: `database_schema.sql` 파일 실행
4.  **서버 실행**: `python start.py` 또는 `uvicorn main:app --reload`

## 9. 재사용성 가이드

이 프로젝트의 아키텍처는 다른 FastAPI 기반 프로젝트에서 재사용하기에 적합합니다.

- **`app/core`**: 설정, 예외 처리 등 핵심 로직은 대부분의 FastAPI 프로젝트에서 재사용 가능합니다.
- **`app/api`**: API 엔드포인트 구조는 새로운 도메인을 추가할 때 템플릿으로 사용할 수 있습니다.
- **`app/application`**: 서비스와 레포지토리 패턴은 비즈니스 로직과 데이터베이스 로직을 분리하여 코드의 유지보수성을 높입니다.
- **`app/infrastructure`**: 데이터베이스 설정 및 SQLAlchemy 모델 구조는 다른 프로젝트에서도 유사하게 적용할 수 있습니다.

새로운 기능을 추가하려면 다음 단계를 따르세요.

1.  **도메인 모델 정의**: `app/domain/models`에 새로운 모델 추가 (필요 시)
2.  **데이터베이스 모델 생성**: `app/infrastructure/database/models`에 SQLAlchemy 모델 추가
3.  **Pydantic 스키마 생성**: `app/application/schemas`에 데이터 유효성 검사를 위한 스키마 추가
4.  **레포지토리 생성**: `app/application/repositories` 및 `app/infrastructure/repositories`에 데이터베이스와 상호작용하는 레포지토리 추가
5.  **서비스 로직 구현**: `app/application/services`에 비즈니스 로직 추가
6.  **API 엔드포인트 추가**: `app/api/v1/endpoints`에 새로운 엔드포인트 추가하고 `app/api/v1/router.py`에 등록
