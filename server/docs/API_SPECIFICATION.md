# OneDayPillo API 명세서

## 개요

OneDayPillo는 약물 복용 관리를 위한 RESTful API입니다. 사용자가 약물을 등록하고, 복용 알림을 받으며, 복용 기록을 관리할 수 있는 기능을 제공합니다.

## 기본 정보

- **API 버전**: v1
- **Base URL**: `https://api.onedaypillo.com/v1`
- **인증 방식**: JWT Bearer Token
- **응답 형식**: JSON
- **문자 인코딩**: UTF-8

## 응답 형식

모든 API는 표준화된 응답 형식을 사용합니다.

### 성공 응답
```json
{
    "success": true,
    "data": { ... },
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
        "message": "에러 메시지",
        "details": "상세 정보 (선택사항)",
        "field": "문제가 된 필드 (선택사항)"
    },
    "timestamp": "2024-01-01T00:00:00Z"
}
```

## 인증

대부분의 API는 JWT 토큰을 통한 인증이 필요합니다. Authorization 헤더에 `Bearer {access_token}` 형식으로 토큰을 포함해주세요.

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 엔드포인트

### 1. 인증 (Authentication)

#### 1.1 사용자 등록
```http
POST /auth/register
```

**요청 본문:**
```json
{
    "email": "user@example.com",
    "password": "password123",
    "display_name": "사용자 이름"
}
```

**응답:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "uuid",
            "email": "user@example.com",
            "display_name": "사용자 이름",
            "is_email_verified": false,
            "created_at": "2024-01-01T00:00:00Z"
        },
        "tokens": {
            "access_token": "jwt_token",
            "refresh_token": "refresh_token",
            "expires_in": 3600
        }
    },
    "message": "사용자 등록이 완료되었습니다"
}
```

#### 1.2 사용자 로그인
```http
POST /auth/login
```

**요청 본문:**
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```

**응답:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "uuid",
            "email": "user@example.com",
            "display_name": "사용자 이름"
        },
        "tokens": {
            "access_token": "jwt_token",
            "refresh_token": "refresh_token",
            "expires_in": 3600
        }
    },
    "message": "로그인에 성공했습니다"
}
```

#### 1.3 토큰 갱신
```http
POST /auth/refresh
```

**요청 본문:**
```json
{
    "refresh_token": "refresh_token"
}
```

#### 1.4 프로필 조회
```http
GET /auth/profile
```

**헤더:** `Authorization: Bearer {access_token}`

#### 1.5 프로필 업데이트
```http
PUT /auth/profile
```

**헤더:** `Authorization: Bearer {access_token}`

**요청 본문:**
```json
{
    "display_name": "새로운 이름",
    "photo_url": "https://example.com/photo.jpg"
}
```

#### 1.6 로그아웃
```http
POST /auth/logout
```

**헤더:** `Authorization: Bearer {access_token}`

### 2. 약물 관리 (Medications)

#### 2.1 약물 등록
```http
POST /medicine
```

**헤더:** `Authorization: Bearer {access_token}`

**요청 본문:**
```json
{
    "name": "아스피린",
    "dosage": "1정",
    "frequency": "하루 3회",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31",
    "instructions": "식후 30분에 복용",
    "reminder_times": ["08:00", "14:00", "20:00"]
}
```

#### 2.2 약물 목록 조회
```http
GET /medicine
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.3 특정 약물 조회
```http
GET /medicine/{medication_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.4 약물 정보 수정
```http
PUT /medicine/{medication_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.5 약물 삭제
```http
DELETE /medicine/{medication_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.6 오늘의 약물 조회
```http
GET /medicine/today
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.7 복용 로그 생성
```http
POST /medicine/{medication_id}/logs
```

**헤더:** `Authorization: Bearer {access_token}`

**요청 본문:**
```json
{
    "taken_at": "2024-01-01T08:00:00Z",
    "notes": "복용 완료"
}
```

#### 2.8 복용 로그 조회
```http
GET /medicine/{medication_id}/logs
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.9 복용 기록 생성
```http
POST /medicine/records
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.10 일일 복용 기록 조회
```http
GET /medicine/records/daily
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `date`: 조회할 날짜 (YYYY-MM-DD)

#### 2.11 복용 기록 수정
```http
PUT /medicine/records/{record_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 2.12 월별 통계 조회
```http
GET /medicine/statistics/monthly
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `year`: 연도 (YYYY)
- `month`: 월 (MM)

### 3. 알림 및 리마인더 (Reminders)

#### 3.1 리마인더 생성
```http
POST /reminders
```

**헤더:** `Authorization: Bearer {access_token}`

**요청 본문:**
```json
{
    "medication_id": "uuid",
    "reminder_time": "08:00",
    "days_of_week": [1, 2, 3, 4, 5],
    "is_active": true,
    "notification_type": "push"
}
```

#### 3.2 리마인더 목록 조회
```http
GET /reminders
```

**헤더:** `Authorization: Bearer {access_token}`

#### 3.3 특정 리마인더 조회
```http
GET /reminders/{reminder_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 3.4 리마인더 수정
```http
PUT /reminders/{reminder_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 3.5 리마인더 삭제
```http
DELETE /reminders/{reminder_id}
```

**헤더:** `Authorization: Bearer {access_token}`

#### 3.6 알림 로그 조회
```http
GET /reminders/notifications/logs
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `start_date`: 시작 날짜 (YYYY-MM-DD)
- `end_date`: 종료 날짜 (YYYY-MM-DD)
- `status`: 알림 상태 (SENT, FAILED, PENDING)

#### 3.7 알림 통계 조회
```http
GET /reminders/notifications/stats
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `period`: 기간 (daily, weekly, monthly)

#### 3.8 알림 스케줄링
```http
POST /reminders/schedule
```

**헤더:** `Authorization: Bearer {access_token}`

#### 3.9 알림 처리
```http
POST /reminders/process
```

**헤더:** `Authorization: Bearer {access_token}`

### 4. 통계 및 분석 (Analytics)

#### 4.1 약물 통계 조회
```http
GET /analytics/medication-stats
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `start_date`: 시작 날짜 (YYYY-MM-DD)
- `end_date`: 종료 날짜 (YYYY-MM-DD)
- `medication_id`: 특정 약물 ID (선택사항)

#### 4.2 복용 준수율 조회
```http
GET /analytics/compliance-rate
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `period`: 기간 (daily, weekly, monthly)
- `medication_id`: 특정 약물 ID (선택사항)

#### 4.3 약물 복용 이력 조회
```http
GET /analytics/medication-history
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `start_date`: 시작 날짜 (YYYY-MM-DD)
- `end_date`: 종료 날짜 (YYYY-MM-DD)
- `medication_id`: 특정 약물 ID (선택사항)

#### 4.4 분석 요약 조회
```http
GET /analytics/summary
```

**헤더:** `Authorization: Bearer {access_token}`

**쿼리 파라미터:**
- `period`: 기간 (daily, weekly, monthly)

### 5. 시스템 (System)

#### 5.1 헬스체크
```http
GET /system/health
```

**응답:**
```json
{
    "success": true,
    "data": {
        "status": "healthy",
        "timestamp": "2024-01-01T00:00:00Z",
        "database": "connected",
        "services": {
            "auth": "healthy",
            "medication": "healthy",
            "notification": "healthy"
        }
    },
    "message": "헬스체크 성공"
}
```

#### 5.2 버전 정보
```http
GET /system/version
```

**응답:**
```json
{
    "success": true,
    "data": {
        "version": "1.0.0",
        "build_number": "100",
        "release_date": "2024-01-01T00:00:00Z",
        "min_supported_version": "1.0.0",
        "force_update": false
    },
    "message": "버전 정보 조회 성공"
}
```

#### 5.3 시스템 설정
```http
GET /system/config
```

**응답:**
```json
{
    "success": true,
    "data": {
        "config": {
            "maintenance_mode": false,
            "api_rate_limit": 1000,
            "max_file_size": 10485760,
            "supported_image_formats": ["jpg", "jpeg", "png", "gif"],
            "notification_enabled": true,
            "analytics_enabled": true
        },
        "last_updated": "2024-01-01T00:00:00Z"
    },
    "message": "시스템 설정 조회 성공"
}
```

#### 5.4 시스템 통계
```http
GET /system/stats
```

**응답:**
```json
{
    "success": true,
    "data": {
        "stats": {
            "total_users": 1000,
            "active_users": 800,
            "total_medications": 5000,
            "total_logs": 15000,
            "api_requests_today": 10000,
            "uptime_seconds": 86400
        },
        "timestamp": "2024-01-01T00:00:00Z"
    },
    "message": "시스템 통계 조회 성공"
}
```

#### 5.5 서버 정보
```http
GET /system/info
```

**응답:**
```json
{
    "success": true,
    "data": {
        "server": {
            "name": "OneDayPillo",
            "version": "1.0.0",
            "environment": "production",
            "python_version": "3.12.11",
            "platform": "posix",
            "uptime": "1d 2h 30m 45s",
            "resources": {
                "cpu_percent": 15.5,
                "memory_percent": 45.2,
                "disk_percent": 30.1
            }
        },
        "database": {
            "url": "hidden",
            "pool_size": 10,
            "max_overflow": 20
        },
        "features": {
            "social_login": true,
            "firebase": true,
            "admob": true,
            "notifications": true,
            "analytics": true
        }
    },
    "message": "서버 정보 조회 성공"
}
```

#### 5.6 핑 테스트
```http
GET /system/ping
```

**응답:**
```json
{
    "success": true,
    "data": {
        "message": "pong",
        "timestamp": "2024-01-01T00:00:00Z",
        "response_time_ms": 5
    },
    "message": "핑 테스트 성공"
}
```

## 에러 코드

| 코드 | HTTP 상태 | 설명 |
|------|-----------|------|
| `VALIDATION_ERROR` | 400 | 요청 데이터 검증 실패 |
| `UNAUTHORIZED` | 401 | 인증 실패 |
| `FORBIDDEN` | 403 | 권한 없음 |
| `NOT_FOUND` | 404 | 리소스를 찾을 수 없음 |
| `DUPLICATE_EMAIL` | 409 | 중복된 이메일 |
| `RATE_LIMIT_EXCEEDED` | 429 | 요청 한도 초과 |
| `INTERNAL_ERROR` | 500 | 서버 내부 오류 |
| `DATABASE_ERROR` | 500 | 데이터베이스 오류 |
| `EXTERNAL_SERVICE_ERROR` | 502 | 외부 서비스 오류 |

## 요청 제한

- **Rate Limit**: 분당 1000 요청
- **파일 크기**: 최대 10MB
- **지원 이미지 형식**: JPG, JPEG, PNG, GIF

## 보안

- 모든 API 요청은 HTTPS를 통해 전송됩니다.
- JWT 토큰은 1시간 후 만료됩니다.
- 민감한 정보는 로그에 기록되지 않습니다.
- CORS 정책이 적용되어 허용된 도메인에서만 접근 가능합니다.

## 버전 관리

API 버전은 URL 경로에 포함됩니다 (`/v1/`). 새로운 버전이 출시될 때는 이전 버전과의 호환성을 유지합니다.

## 지원

API 사용 중 문제가 발생하면 다음으로 문의해주세요:
- 이메일: woohyeon@woohalabs.com
- 문서: https://docs.onedaypillo.com
