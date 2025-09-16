# HealthPlus API Server

모바일 앱을 위한 약물 복용 관리 FastAPI 백엔드 서버입니다.

## 🚀 빠른 시작

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. 환경 변수 설정
`.env.example` 파일을 복사하여 `.env` 파일을 생성하고 적절한 값을 설정하세요.

```bash
cp .env.example .env
```

### 3. Supabase 데이터베이스 설정
`database_schema.sql` 파일의 내용을 Supabase 프로젝트의 SQL 에디터에서 실행하세요.

### 4. 서버 시작
```bash
# 자동 설정 스크립트 사용
python start.py

# 또는 직접 실행
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## 📚 API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- **Swagger UI**: http://localhost:8000/api/v1/docs
- **ReDoc**: http://localhost:8000/api/v1/redoc
- **헬스체크**: http://localhost:8000/health

## 🏗️ 프로젝트 구조

```
server/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── auth.py          # 인증 엔드포인트
│   │       ├── medications.py   # 약물 관리 엔드포인트
│   │       └── router.py        # 라우터 설정
│   ├── core/
│   │   ├── config.py           # 애플리케이션 설정
│   │   ├── database.py         # Supabase 클라이언트
│   │   └── exceptions.py       # 예외 처리
│   ├── models/                 # 데이터 모델 (미래 확장용)
│   ├── schemas/
│   │   ├── auth.py            # 인증 관련 스키마
│   │   └── medication.py      # 약물 관리 스키마
│   ├── services/
│   │   ├── auth_service.py    # 인증 서비스
│   │   └── medication_service.py # 약물 관리 서비스
│   └── utils/
│       └── auth.py            # 인증 유틸리티
├── main.py                    # FastAPI 애플리케이션
├── start.py                   # 서버 시작 스크립트
├── requirements.txt           # Python 의존성
├── database_schema.sql        # Supabase 데이터베이스 스키마
├── .env                      # 환경 변수 (gitignore됨)
└── .env.example              # 환경 변수 예시
```

## 🛠️ 주요 기능

### 인증 API (`/api/v1/auth`)
- `POST /signup` - 이메일 회원가입
- `POST /signin` - 이메일 로그인
- `GET /me` - 현재 사용자 정보 조회
- `POST /logout` - 로그아웃
- `PUT /profile` - 프로필 업데이트

### 약물 관리 API (`/api/v1/medications`)
- `POST /medications` - 약물 등록
- `GET /medications` - 약물 목록 조회
- `GET /medications/{id}` - 특정 약물 조회
- `PUT /medications/{id}` - 약물 정보 수정
- `DELETE /medications/{id}` - 약물 삭제
- `POST /medications/records` - 복용 기록 생성
- `GET /medications/records/daily` - 일별 복용 기록 조회
- `PUT /medications/records/{id}` - 복용 기록 수정
- `GET /medications/statistics/monthly` - 월간 통계 조회

## 🔧 기술 스택

- **FastAPI**: 고성능 Python 웹 프레임워크
- **Supabase**: PostgreSQL 기반 BaaS
- **Pydantic**: 데이터 검증 및 직렬화
- **python-jose**: JWT 토큰 처리
- **passlib**: 비밀번호 해싱
- **uvicorn**: ASGI 서버

## 🔐 보안

- JWT 기반 인증
- Supabase Row Level Security (RLS)
- 비밀번호 해싱 (bcrypt)
- CORS 설정
- 환경 변수를 통한 민감 정보 관리

## 🚀 성능 최적화

- **비동기 처리**: 모든 데이터베이스 작업을 비동기로 처리
- **연결 풀링**: Supabase 클라이언트 싱글톤 패턴
- **응답 캐싱**: Redis를 통한 캐싱 (추후 구현)
- **배치 처리**: 대용량 데이터 처리 최적화

## 📊 모니터링

### 헬스체크
```bash
curl http://localhost:8000/health
```

### 로그 레벨 설정
`.env` 파일에서 `LOG_LEVEL` 설정:
- `debug`: 상세한 디버그 정보
- `info`: 일반 정보
- `warning`: 경고
- `error`: 오류만

## 🔄 개발 워크플로우

1. **개발 환경 설정**
   ```bash
   python start.py
   ```

2. **API 테스트**
   - Swagger UI 사용: http://localhost:8000/api/v1/docs
   - 또는 curl/Postman 사용

3. **데이터베이스 마이그레이션**
   - Supabase 대시보드에서 SQL 실행
   - 또는 Supabase CLI 사용

## 🐛 문제 해결

### 자주 발생하는 오류

1. **Supabase 연결 실패**
   - `.env` 파일의 Supabase 설정 확인
   - 네트워크 연결 확인

2. **JWT 토큰 오류**
   - `JWT_SECRET` 설정 확인
   - 토큰 만료 시간 확인

3. **RLS 정책 오류**
   - Supabase RLS 정책 활성화 확인
   - 사용자 권한 확인

### 로그 확인
```bash
# 실시간 로그 보기
tail -f app.log

# 에러 로그만 보기
grep ERROR app.log
```

## 🤝 기여하기

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing-feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 라이센스

이 프로젝트는 MIT 라이센스 하에 있습니다.

## 📞 지원

문제가 발생하면 GitHub Issues를 통해 문의해주세요.