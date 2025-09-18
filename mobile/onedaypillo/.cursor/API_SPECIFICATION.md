# OneDayPillo API 명세서

## 📋 개요

OneDayPillo 앱의 백엔드 API 명세서입니다. 약물 관리 및 복용 로그를 위한 RESTful API를 제공합니다.

## 🔧 기술 스택

- **인증**: JWT (JSON Web Token)
- **API 버전**: v1
- **응답 형식**: JSON
- **인코딩**: UTF-8

## 🌍 환경 설정

### 환경변수 구조

#### Common (.env.common)
```env
# JWT 설정
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# API 기본 설정
API_VERSION=v1
API_TIMEOUT=30000

# 기본 URL
BASE_URL=https://api.onedaypillo.com
```

#### Development (.env.dev)
```env
# 개발 환경 데이터베이스
DATABASE_URL=postgresql://dev_user:dev_password@localhost:5432/onedaypillo_dev

# 개발 환경 키
GOOGLE_CLIENT_ID=dev-google-client-id
FACEBOOK_APP_ID=dev-facebook-app-id
KAKAO_CLIENT_ID=dev-kakao-client-id

# 개발 환경 Firebase
FIREBASE_PROJECT_ID=onedaypillo-dev
FIREBASE_API_KEY=dev-firebase-api-key

# 개발 환경 AdMob
ADMOB_APP_ID=ca-app-pub-3940256099942544~3347511713
ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111
```

#### Production (.env.prod)
```env
# 프로덕션 환경 데이터베이스
DATABASE_URL=postgresql://prod_user:prod_password@prod-db-host:5432/onedaypillo_prod

# 프로덕션 환경 키
GOOGLE_CLIENT_ID=prod-google-client-id
FACEBOOK_APP_ID=prod-facebook-app-id
KAKAO_CLIENT_ID=prod-kakao-client-id

# 프로덕션 환경 Firebase
FIREBASE_PROJECT_ID=onedaypillo-prod
FIREBASE_API_KEY=prod-firebase-api-key

# 프로덕션 환경 AdMob
ADMOB_APP_ID=ca-app-pub-1234567890123456~1234567890
ADMOB_BANNER_ID=ca-app-pub-1234567890123456/1234567890
```

## 🔐 인증 시스템

### JWT 토큰 구조

#### Access Token Payload
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "provider": "email|google|facebook|kakao",
  "iat": 1234567890,
  "exp": 1234567890,
  "iss": "onedaypillo-api",
  "type": "access"
}
```

#### Refresh Token Payload
```json
{
  "sub": "user_id",
  "iat": 1234567890,
  "exp": 1234567890,
  "iss": "onedaypillo-api",
  "type": "refresh"
}
```

### 인증 헤더
```
Authorization: Bearer {access_token}
```

## 📝 API 응답 형식

### 성공 응답
```json
{
  "success": true,
  "data": {},
  "message": "성공 메시지",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "사용자 친화적 메시지",
    "details": "상세 에러 정보",
    "field": "에러가 발생한 필드명 (선택사항)"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 🚀 API 엔드포인트

### 1. 인증 관련 (`/v1/auth`)

#### 1.1 회원가입
```http
POST /v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123!",
  "displayName": "사용자명"
}
```

**응답 (201 Created)**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "displayName": "사용자명",
      "provider": "email",
      "isEmailVerified": false,
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  },
  "message": "회원가입이 완료되었습니다."
}
```

#### 1.2 이메일 로그인
```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123!"
}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "displayName": "사용자명",
      "provider": "email",
      "isEmailVerified": true,
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  },
  "message": "로그인에 성공했습니다."
}
```

#### 1.3 소셜 로그인 (보류)
```http
# Google, Facebook, Kakao 로그인은 현재 보류
# 기존 Supabase 소셜 로그인 유지 예정
```

#### 1.4 토큰 갱신
```http
POST /v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "토큰이 갱신되었습니다."
}
```

#### 1.5 로그아웃
```http
POST /v1/auth/logout
Authorization: Bearer {access_token}
```

#### 1.6 사용자 프로필 조회
```http
GET /v1/auth/profile
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "displayName": "사용자명",
      "photoURL": "https://example.com/photo.jpg",
      "provider": "email",
      "isEmailVerified": true,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### 1.7 사용자 프로필 수정
```http
PUT /v1/auth/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "새로운 사용자명",
  "photoURL": "https://example.com/new-photo.jpg"
}
```

### 2. 약물 관리 (`/v1/medicine`)

#### 2.1 약물 목록 조회
```http
GET /v1/medicine
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "medications": [
      {
        "id": "med_123",
        "name": "아스피린",
        "dosage": "1정",
        "notificationTime": {
          "hour": 9,
          "minute": 0
        },
        "repeatDays": [1, 2, 3, 4, 5],
        "isActive": true,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "total": 1
  }
}
```

#### 2.2 약물 추가
```http
POST /v1/medicine
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "아스피린",
  "dosage": "1정",
  "notificationTime": {
    "hour": 9,
    "minute": 0
  },
  "repeatDays": [1, 2, 3, 4, 5]
}
```

**응답 (201 Created)**
```json
{
  "success": true,
  "data": {
    "medication": {
      "id": "med_123",
      "name": "아스피린",
      "dosage": "1정",
      "notificationTime": {
        "hour": 9,
        "minute": 0
      },
      "repeatDays": [1, 2, 3, 4, 5],
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  },
  "message": "약물이 추가되었습니다."
}
```

#### 2.3 특정 약물 조회
```http
GET /v1/medicine/{id}
Authorization: Bearer {access_token}
```

#### 2.4 약물 수정
```http
PUT /v1/medicine/{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "수정된 약물명",
  "dosage": "2정",
  "notificationTime": {
    "hour": 10,
    "minute": 30
  },
  "repeatDays": [1, 3, 5],
  "isActive": false
}
```

#### 2.5 약물 삭제
```http
DELETE /v1/medicine/{id}
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "message": "약물이 삭제되었습니다."
}
```

#### 2.6 오늘의 약물 목록
```http
GET /v1/medicine/today
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "medications": [
      {
        "id": "med_123",
        "name": "아스피린",
        "dosage": "1정",
        "notificationTime": {
          "hour": 9,
          "minute": 0
        },
        "isActive": true,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "date": "2024-01-01",
    "total": 1
  }
}
```

### 3. 복용 로그 (`/v1/medication-log`)

#### 3.1 복용 로그 기록
```http
POST /v1/medication-log
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "medicationId": "med_123",
  "takenAt": "2024-01-01T09:00:00Z",
  "isTaken": true,
  "note": "아침 식사 후 복용"
}
```

**응답 (201 Created)**
```json
{
  "success": true,
  "data": {
    "log": {
      "id": "log_123",
      "medicationId": "med_123",
      "takenAt": "2024-01-01T09:00:00Z",
      "isTaken": true,
      "note": "아침 식사 후 복용"
    }
  },
  "message": "복용 로그가 기록되었습니다."
}
```

#### 3.2 복용 로그 조회
```http
GET /v1/medication-log?medicationId={id}&startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log_123",
        "medicationId": "med_123",
        "takenAt": "2024-01-01T09:00:00Z",
        "isTaken": true,
        "note": "아침 식사 후 복용"
      }
    ],
    "total": 1,
    "startDate": "2024-01-01",
    "endDate": "2024-01-31"
  }
}
```

#### 3.3 복용 로그 수정
```http
PUT /v1/medication-log/{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "isTaken": false,
  "note": "복용하지 않음 - 부작용 발생"
}
```

#### 3.4 복용 로그 삭제
```http
DELETE /v1/medication-log/{id}
Authorization: Bearer {access_token}
```

### 4. 통계 및 분석 (`/v1/analytics`)

#### 4.1 약물 복용 통계
```http
GET /v1/analytics/medication-stats?startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer {access_token}
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "totalMedications": 5,
    "totalLogs": 150,
    "complianceRate": 85.5,
    "mostTakenMedication": {
      "id": "med_123",
      "name": "아스피린",
      "count": 30
    },
    "dailyStats": [
      {
        "date": "2024-01-01",
        "total": 5,
        "taken": 4,
        "missed": 1
      }
    ]
  }
}
```

#### 4.2 복용 준수율
```http
GET /v1/analytics/compliance-rate?medicationId={id}&period=month
Authorization: Bearer {access_token}
```

#### 4.3 복용 히스토리
```http
GET /v1/analytics/history?medicationId={id}&period=week
Authorization: Bearer {access_token}
```

### 5. 알림 및 리마인더 (`/v1/reminders`)

#### 5.1 알림 설정 조회
```http
GET /v1/reminders
Authorization: Bearer {access_token}
```

#### 5.2 알림 설정 추가
```http
POST /v1/reminders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "medicationId": "med_123",
  "reminderTime": {
    "hour": 9,
    "minute": 0
  },
  "isEnabled": true,
  "notificationType": "push"
}
```

#### 5.3 알림 설정 수정
```http
PUT /v1/reminders/{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "reminderTime": {
    "hour": 10,
    "minute": 0
  },
  "isEnabled": false
}
```

#### 5.4 알림 설정 삭제
```http
DELETE /v1/reminders/{id}
Authorization: Bearer {access_token}
```

### 6. 시스템 (`/v1/system`)

#### 6.1 헬스체크
```http
GET /v1/system/health
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0",
    "database": "connected",
    "services": {
      "auth": "healthy",
      "medication": "healthy",
      "notification": "healthy"
    }
  }
}
```

#### 6.2 앱 버전 정보
```http
GET /v1/system/version
```

**응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "version": "1.0.0",
    "buildNumber": "1",
    "releaseDate": "2024-01-01T00:00:00Z",
    "minSupportedVersion": "1.0.0",
    "forceUpdate": false
  }
}
```

## 📊 HTTP 상태 코드

| 코드 | 설명 | 사용 시나리오 |
|------|------|---------------|
| 200 | OK | 성공적인 GET, PUT, DELETE 요청 |
| 201 | Created | 성공적인 POST 요청 (리소스 생성) |
| 400 | Bad Request | 잘못된 요청 형식 또는 파라미터 |
| 401 | Unauthorized | 인증 실패 또는 토큰 만료 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스를 찾을 수 없음 |
| 409 | Conflict | 리소스 충돌 (중복 등) |
| 422 | Unprocessable Entity | 유효성 검사 실패 |
| 500 | Internal Server Error | 서버 내부 오류 |

## 🚨 에러 코드

### 인증 관련 (AUTH_*)
- `AUTH_INVALID_CREDENTIALS`: 잘못된 인증 정보
- `AUTH_TOKEN_EXPIRED`: 토큰 만료
- `AUTH_TOKEN_INVALID`: 유효하지 않은 토큰
- `AUTH_USER_NOT_FOUND`: 사용자를 찾을 수 없음
- `AUTH_EMAIL_ALREADY_EXISTS`: 이메일이 이미 존재함
- `AUTH_WEAK_PASSWORD`: 약한 비밀번호
- ~~`AUTH_SOCIAL_LOGIN_FAILED`: 소셜 로그인 실패~~ (보류)

### 약물 관리 관련 (MED_*)
- `MED_MEDICATION_NOT_FOUND`: 약물을 찾을 수 없음
- `MED_INVALID_DOSAGE`: 잘못된 복용량
- `MED_INVALID_TIME`: 잘못된 시간 형식
- `MED_DUPLICATE_MEDICATION`: 중복된 약물

### 복용 로그 관련 (LOG_*)
- `LOG_LOG_NOT_FOUND`: 로그를 찾을 수 없음
- `LOG_ALREADY_TAKEN`: 이미 복용 기록이 있음
- `LOG_INVALID_DATE`: 잘못된 날짜

### 시스템 관련 (SYS_*)
- `SYS_DATABASE_ERROR`: 데이터베이스 오류
- `SYS_EXTERNAL_SERVICE_ERROR`: 외부 서비스 오류
- `SYS_RATE_LIMIT_EXCEEDED`: 요청 한도 초과

## 📋 체크리스트

### ✅ 완료된 항목
- [x] API 명세서 작성 완료
- [x] JWT 토큰 구조 정의
- [x] 환경변수 구조 설계
- [x] 에러 코드 체계 정의
- [x] HTTP 상태 코드 정의
- [x] 응답 형식 표준화

### ⏳ 진행 중인 항목
- [ ] 백엔드 API 구현
- [ ] 데이터베이스 스키마 설계
- [ ] 인증 미들웨어 구현
- [ ] 에러 핸들링 시스템
- [ ] API 테스트 작성
- [ ] 문서화 및 배포

### 📝 구현 우선순위

#### Phase 1: 핵심 기능 (우선순위 높음)
1. 인증 시스템 (JWT)
2. 약물 관리 CRUD
3. 복용 로그 CRUD
4. 기본 에러 핸들링

#### Phase 2: 확장 기능 (우선순위 중간)
1. 통계 및 분석
2. 알림 시스템
3. API 테스트
4. ~~소셜 로그인 통합~~ (보류)

#### Phase 3: 고급 기능 (우선순위 낮음)
1. 실시간 알림
2. 데이터 백업/복원
3. 성능 최적화
4. 모니터링 시스템

## 🔄 버전 관리

- **현재 버전**: v1.0.0
- **API 버전**: v1
- **호환성**: 하위 호환성 유지
- **업데이트 주기**: 월 1회 (필요시 긴급 업데이트)

## 📞 지원

- **개발팀**: dev@onedaypillo.com
- **문서**: https://docs.onedaypillo.com
- **이슈 트래커**: https://github.com/onedaypillo/api/issues

---

*이 문서는 OneDayPillo API v1.0.0 기준으로 작성되었습니다.*
*최종 업데이트: 2024-01-01*
