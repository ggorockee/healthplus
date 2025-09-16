# HealthPlus 환경별 데이터베이스 분리 가이드

## 개요

HealthPlus 애플리케이션은 개발용과 상용계 데이터베이스를 분리하여 운영할 수 있도록 구성되었습니다. 이 문서는 환경별 데이터베이스 설정과 사용 방법을 설명합니다.

## 환경 구성

### 지원되는 환경

- **development**: 개발 환경
- **staging**: 스테이징 환경  
- **production**: 상용 환경

### 환경별 특징

| 환경 | DEBUG | 로그 레벨 | 테스트 데이터 | 시스템 로그 |
|------|-------|-----------|---------------|-------------|
| development | ✅ | debug | ✅ | ❌ |
| staging | ❌ | info | ❌ | ✅ |
| production | ❌ | warning | ❌ | ✅ |

## 설정 파일

### 환경별 설정 파일

각 환경별로 다음과 같은 설정 파일을 사용합니다:

- `.env.development` - 개발 환경 설정
- `.env.staging` - 스테이징 환경 설정  
- `.env.production` - 상용 환경 설정

### 설정 파일 생성

1. 예제 파일을 복사합니다:
   ```bash
   cp env.development.example .env.development
   cp env.production.example .env.production
   ```

2. 실제 값으로 수정합니다:
   ```bash
   # .env.development
   SUPABASE_URL=https://your-dev-project.supabase.co
   SUPABASE_ANON_KEY=your_dev_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_dev_service_role_key
   JWT_SECRET=your_dev_jwt_secret
   ```

## 데이터베이스 스키마

### 환경별 스키마 파일

- `database_schema.development.sql` - 개발 환경용 스키마
- `database_schema.production.sql` - 상용 환경용 스키마

### 스키마 차이점

#### 개발 환경 스키마
- `dev_test_data` 테이블 포함 (테스트용)
- 모든 사용자가 테스트 데이터 접근 가능
- 샘플 데이터 자동 삽입

#### 상용 환경 스키마
- `system_logs` 테이블 포함 (시스템 로깅용)
- 서비스 역할만 시스템 로그 접근 가능
- 보안 강화된 RLS 정책

## 환경 전환

### 자동 전환 스크립트 사용

```bash
# 개발 환경으로 전환
./switch_env.sh development

# 상용 환경으로 전환
./switch_env.sh production

# 스테이징 환경으로 전환
./switch_env.sh staging
```

### 수동 전환

```bash
# 환경변수 설정
export ENVIRONMENT=development

# 또는
export ENVIRONMENT=production

# 서버 시작
python main.py
```

## 데이터베이스 설정

### Supabase 프로젝트 생성

1. **개발용 프로젝트**:
   - Supabase 대시보드에서 새 프로젝트 생성
   - 프로젝트 이름: `healthplus-dev`
   - 데이터베이스 비밀번호 설정

2. **상용용 프로젝트**:
   - Supabase 대시보드에서 새 프로젝트 생성
   - 프로젝트 이름: `healthplus-prod`
   - 강화된 보안 설정 적용

### 스키마 적용

1. **개발 환경**:
   ```sql
   -- Supabase SQL Editor에서 실행
   -- database_schema.development.sql 내용 복사하여 실행
   ```

2. **상용 환경**:
   ```sql
   -- Supabase SQL Editor에서 실행
   -- database_schema.production.sql 내용 복사하여 실행
   ```

## 애플리케이션 코드에서 환경 확인

### 설정 확인

```python
from app.core.config import settings

# 환경 확인
if settings.is_development:
    print("개발 환경입니다")
elif settings.is_production:
    print("상용 환경입니다")

# 데이터베이스 정보 확인
db_info = settings.database_info
print(f"현재 환경: {db_info['environment']}")
print(f"데이터베이스 URL: {db_info['url']}")
```

### 데이터베이스 클라이언트 사용

```python
from app.core.database import get_supabase, get_service_supabase, get_database_info

# 일반 클라이언트
client = get_supabase()

# 서비스 클라이언트
service_client = get_service_supabase()

# 현재 데이터베이스 정보
db_info = get_database_info()
```

## 배포 및 운영

### Docker 환경에서 사용

```dockerfile
# Dockerfile 예시
FROM python:3.11-slim

# 환경변수 설정
ENV ENVIRONMENT=production

# 애플리케이션 복사 및 실행
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt

CMD ["python", "main.py"]
```

### Kubernetes 환경에서 사용

```yaml
# k8s-configmap.yaml 예시
apiVersion: v1
kind: ConfigMap
metadata:
  name: healthplus-config
data:
  ENVIRONMENT: "production"
  DEBUG: "false"
  LOG_LEVEL: "warning"
```

## 보안 고려사항

### 환경별 보안 설정

1. **개발 환경**:
   - 테스트 데이터 포함 가능
   - 상세한 로깅 활성화
   - 디버그 모드 활성화

2. **상용 환경**:
   - 민감한 정보 로깅 금지
   - 강화된 RLS 정책 적용
   - 시스템 로그 모니터링

### API 키 관리

- 각 환경별로 다른 Supabase 프로젝트 사용
- 환경별로 다른 JWT 시크릿 키 사용
- 상용 환경에서는 강력한 비밀번호 사용

## 문제 해결

### 일반적인 문제

1. **환경 파일이 없을 때**:
   ```bash
   # 예제 파일 복사
   cp env.development.example .env.development
   ```

2. **데이터베이스 연결 실패**:
   - Supabase URL과 API 키 확인
   - 네트워크 연결 상태 확인
   - 스키마가 올바르게 적용되었는지 확인

3. **환경 전환 후 문제**:
   ```bash
   # 환경 전환 스크립트로 테스트
   ./switch_env.sh development
   ```

### 로그 확인

```python
# 환경별 로그 레벨 확인
from app.core.config import settings
print(f"현재 로그 레벨: {settings.LOG_LEVEL}")
print(f"디버그 모드: {settings.DEBUG}")
```

## 추가 리소스

- [Supabase 문서](https://supabase.com/docs)
- [FastAPI 환경 설정](https://fastapi.tiangolo.com/advanced/settings/)
- [Pydantic Settings](https://pydantic-docs.helpmanual.io/usage/settings/)
