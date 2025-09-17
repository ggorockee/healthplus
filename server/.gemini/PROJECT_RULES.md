# FastAPI Clean Architecture SRD (Software Requirements Document)

## 1. 프로젝트 개요

### 1.1. 프로젝트 목표
본 프로젝트는 FastAPI와 SQLAlchemy 2.0+ 비동기 ORM을 사용하여 **유지보수성, 확장성, 테스트 용이성**이 뛰어난 백엔드 애플리케이션을 구축하는 것을 목표로 한다. 클린 아키텍처(Clean Architecture) 원칙을 적용하여 비즈니스 로직과 외부 기술(프레임워크, DB 등)을 분리하고, TDD(Test-Driven Development) 방법론을 통해 코드의 안정성과 신뢰성을 확보한다.

### 1.2. 핵심 원칙
- **의존성 규칙(The Dependency Rule)**: 모든 소스 코드 의존성은 외부에서 내부를 향해야 한다. 즉, 외부 계층(프레임워크, UI, DB)의 변경이 내부 계층(비즈니스 규칙, 도메인)에 영향을 주어서는 안 된다.
- **계층 분리**: 도메인(Entities), 애플리케이션(Use Cases), 인프라(Infrastructure), 프레젠테이션(Presentation)의 4가지 주요 계층으로 코드를 분리하여 각자의 역할에 집중하도록 한다.
- **TDD(Test-Driven Development)**: "Red-Green-Refactor" 사이클에 따라 실패하는 테스트를 먼저 작성하고, 테스트를 통과하는 코드를 구현한 뒤, 코드를 리팩토링하는 방식으로 개발을 진행한다.
- **비동기 우선**: 모든 I/O 작업(DB, 외부 API 호출 등)은 `async`/`await`를 사용하여 비동기적으로 처리하여 애플리케이션의 성능과 확장성을 극대화한다.

---

## 2. 기술 스택

| 구분 | 기술 | 버전 | 목적 |
|---|---|---|---|
| **Python Interpreter** | Python | 3.10+ | 애플리케이션 실행 환경 |
| **Web Framework** | FastAPI | 최신 | 고성능 비동기 웹 프레임워크 |
| **ORM** | SQLAlchemy | 2.0+ | 비동기 ORM, 데이터베이스 상호작용 |
| **DB Driver** | asyncpg | 최신 | PostgreSQL 비동기 드라이버 |
| **Testing** | Pytest | 최신 | TDD 및 단위/통합 테스트 |
| **HTTP Client (Test)** | HTTPX | 최신 | 비동기 API 엔드포인트 테스트 |
| **Schema Validation** | Pydantic | V2 | 데이터 유효성 검사 및 설정 관리 |
| **DB Migration** | Alembic | 최신 | 데이터베이스 스키마 버전 관리 |
| **Dependency Injection**| FastAPI Depends | - | 의존성 주입 |
| **Development Server** | Uvicorn | 최신 | ASGI 개발 서버 |
| **Production Server** | Gunicorn + Uvicorn | 최신 | 고성능 프로덕션 ASGI 서버 |
| **Configuration** | Pydantic-Settings | 최신 | 환경 변수 기반 설정 관리 |
| **Linter/Formatter** | Ruff, Black | 최신 | 코드 품질 및 스타일 유지 |

### 2.1. 의존성 관리
- **규칙**: 새로운 라이브러리나 패키지를 추가할 경우, 반드시 `requirements.txt` 파일에 해당 의존성을 명시해야 합니다.
- **방법**: `pip install <package-name>`으로 설치 후, `pip freeze > requirements.txt` 명령어를 사용하여 파일을 업데이트합니다. 이를 통해 모든 개발 환경에서 동일한 의존성을 유지합니다.

---

## 3. 아키텍처 설계

### 3.1. 계층 구조 (Layers)

본 프로젝트는 클린 아키텍처의 4가지 계층을 따르며, 각 계층의 역할은 다음과 같다.

1.  **Domain Layer (Entities)**
    - **역할**: 가장 중심이 되는 계층으로, 애플리케이션의 핵심 비즈니스 로직과 데이터 모델(Entities)을 포함한다.
    - **구성 요소**: 순수한 Python 객체로 표현된 도메인 모델. 다른 계층에 대한 의존성이 없다.
    - **규칙**: 외부 프레임워크나 라이브러리에 대한 의존성을 가져서는 안 된다.

2.  **Application Layer (Use Cases)**
    - **역할**: 애플리케이션의 구체적인 동작(Use Case)을 정의한다. 도메인 객체를 사용하여 비즈니스 흐름을 제어한다.
    - **구성 요소**: 특정 기능을 수행하는 서비스 로직, 데이터 영속성을 위한 인터페이스(추상 클래스), 데이터 전송 객체(DTO)로 사용될 Pydantic 스키마.
    - **규칙**: 도메인 계층에만 의존할 수 있다. 인프라나 프레젠테이션 계층을 직접 참조해서는 안 된다.

3.  **Infrastructure Layer (Frameworks, Drivers)**
    - **역할**: 외부 세계와의 상호작용을 담당한다. 데이터베이스, 외부 API, 파일 시스템 등 구체적인 기술 구현을 포함한다.
    - **구성 요소**: SQLAlchemy 설정 및 세션 관리, DB 모델 정의, 애플리케이션 계층에서 정의한 리포지토리 인터페이스의 실제 구현체, 환경 변수 로드 설정.
    - **규칙**: 애플리케이션 계층의 인터페이스를 구현한다.

4.  **Presentation Layer (API Endpoints)**
    - **역할**: 사용자 또는 외부 시스템과의 인터페이스를 제공한다. FastAPI 라우터가 이 계층에 해당한다.
    - **구성 요소**: FastAPI의 `APIRouter`를 사용하여 엔드포인트를 정의.
    - **규칙**: HTTP 요청을 받아 애플리케이션 계층의 서비스를 호출하고, 그 결과를 HTTP 응답으로 변환하여 반환한다. 의존성 주입(DI)을 통해 서비스와 리포지토리를 주입받는다.

### 3.2. 프로젝트 디렉토리 구조 (예시)
├── app/
│   ├── api/
│   │   ├── deps.py
│   │   └── v1/
│   │       ├── endpoints/
│   │       │   └── users.py
│   │       └── router.py
│   ├── core/
│   │   └── config.py
│   ├── domain/
│   │   └── models/
│   │       └── user.py
│   ├── infrastructure/
│   │   ├── database/
│   │   │   ├── base.py
│   │   │   ├── models/
│   │   │   │   └── user.py
│   │   │   └── session.py
│   │   └── repositories/
│   │       └── user_repository.py
│   ├── application/
│   │   ├── repositories/
│   │   │   └── user_repository.py
│   │   ├── schemas/
│   │   │   └── user.py
│   │   └── services/
│   │       └── user_service.py
│   └── main.py
├── tests/
│   ├── conftest.py
│   ├── application/
│   │   └── test_user_service.py
│   ├── infrastructure/
│   │   └── test_user_repository.py
│   └── presentation/
│       └── test_user_api.py
├── alembic/
├── alembic.ini
├── .env
├── .env.example
├── .gitignore
├── pyproject.toml
├── README.md
└── scripts/
├── run_dev.sh
└── run_tests.sh

## 4. 개발 및 테스트 워크플로우 (TDD)

1.  **요구사항 분석**: 구현할 기능의 요구사항을 명확히 정의한다.
2.  **테스트 작성 (Red)**:
    - **API 테스트**: `tests/presentation/`에 해당 기능의 API 엔드포인트에 대한 실패하는 테스트를 작성한다.
    - **서비스 테스트**: `tests/application/`에 비즈니스 로직에 대한 실패하는 단위 테스트를 작성한다. 리포지토리는 Mock 객체나 Fake 구현체를 사용한다.
    - **리포지토리 테스트**: `tests/infrastructure/`에 실제 DB와 상호작용하는 리포지토리 구현체에 대한 실패하는 통합 테스트를 작성한다.
3.  **코드 구현 (Green)**: 작성한 테스트를 통과할 수 있는 최소한의 코드를 `app/` 내의 각 계층에 맞게 구현한다.
4.  **리팩토링 (Refactor)**: 모든 테스트가 통과하는 상태에서 코드의 가독성, 효율성, 구조를 개선한다.
5.  **반복**: 새로운 기능에 대해 1~4단계를 반복한다.

### Python 인터프리터 설정
로컬 개발 환경(IDE 등)에서 사용할 Python 인터프리터 경로는 `"C:\Users\user\anaconda3\envs\healthplus\python.exe"` 로 지정한다.

---

## 5. 환경 구성 및 배포

### 5.1. 환경 변수 관리
`pydantic-settings` 라이브러리를 사용하여 `.env` 파일 또는 시스템 환경 변수로부터 설정을 안전하게 로드한다. 데이터베이스 연결 정보, API Prefix, 외부 서비스 키 등의 설정 값은 코드가 아닌 환경 변수를 통해 관리한다.

### 5.2. 환경별 엔드포인트
- **개발(Development)**: `https://api-dev.woohacompany.com/onedaypillo/v1`
- **운영(Production)**: `https://api.woohacompany.com/onedaypillo/v1`

FastAPI 애플리케이션의 메인 파일에서 환경 변수로 설정된 API Prefix를 읽어와 각 버전의 라우터를 동적으로 등록한다.

### 5.3. 배포 전략
1.  **로컬 개발**: 개발자는 로컬 환경에서 TDD 사이클에 따라 기능을 개발하고 모든 테스트를 통과시킨다.
2.  **CI/CD 파이프라인**:
    - Git 브랜치에 코드를 푸시하면 CI(Continuous Integration) 파이프라인이 트리거된다.
    - CI 단계에서는 코드 스타일 검사, 모든 테스트 실행, Docker 이미지 빌드 및 컨테이너 레지스트리 푸시를 자동화한다.
3.  **개발 환경 배포 (Staging/Dev)**:
    - 특정 브랜치(예: `develop` 또는 `main`)에 머지되면 CD(Continuous Deployment) 파이프라인이 개발 환경에 자동으로 배포한다.
    - 이 환경에서 E2E 테스트 및 QA를 진행한다.
4.  **운영 환경 배포 (Production)**:
    - Git 태그(tag)를 생성하거나 `main` 브랜치에서 수동 승인을 통해 운영 환경 배포를 트리거한다.
    - 배포는 Blue/Green 또는 Canary와 같은 무중단 배포 전략을 고려한다.

### 5.4. 프로덕션 서버 실행
프로덕션 환경에서는 Gunicorn을 WSGI 서버로 사용하여 Uvicorn 워커 프로세스를 관리한다. 이를 통해 멀티-프로세스 환경의 이점을 활용하여 안정성과 성능을 확보한다. 실행 시 워커의 수와 종류, 바인딩 주소 등을 설정하여 서버를 실행한다.