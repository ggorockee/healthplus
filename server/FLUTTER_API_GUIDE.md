# 📱 OneDayPillo API 사용 가이드

## 📋 개요

OneDayPillo API는 약물 복용 관리를 위한 RESTful API입니다. Flutter 앱에서 이 API를 사용하여 사용자 인증, 약물 관리, 복용 로그, 통계 분석 등의 기능을 구현할 수 있습니다.

### 🎯 주요 기능
- **인증 시스템**: JWT 기반 사용자 인증 및 소셜 로그인
- **약물 관리**: 약물 등록, 수정, 삭제, 조회
- **복용 로그**: 복용 기록 생성 및 관리
- **통계 분석**: 복용 준수율 및 통계 제공
- **알림 시스템**: 약물 복용 알림 설정 및 전송
- **시스템 모니터링**: 헬스체크 및 시스템 상태 확인

### 🛠️ 기술 스택
- **API 버전**: v1.0.0
- **인증**: JWT (Access/Refresh Token)
- **응답 형식**: JSON
- **Base URL**: `https://api.onedaypillo.com/v1`

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

#### 1.3 Google 로그인
```http
POST /v1/auth/google
Content-Type: application/json

{
  "idToken": "google_id_token",
  "accessToken": "google_access_token"
}
```

#### 1.4 Facebook 로그인
```http
POST /v1/auth/facebook
Content-Type: application/json

{
  "accessToken": "facebook_access_token",
  "userId": "facebook_user_id"
}
```

#### 1.5 Kakao 로그인
```http
POST /v1/auth/kakao
Content-Type: application/json

{
  "accessToken": "kakao_access_token",
  "refreshToken": "kakao_refresh_token"
}
```

#### 1.6 토큰 갱신
```http
POST /v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 1.7 로그아웃
```http
POST /v1/auth/logout
Authorization: Bearer {access_token}
```

#### 1.8 사용자 프로필 조회
```http
GET /v1/auth/profile
Authorization: Bearer {access_token}
```

#### 1.9 사용자 프로필 수정
```http
PUT /v1/auth/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "새로운 사용자명",
  "photoURL": "https://example.com/new-photo.jpg"
}
```

### 2. 약물 관리 (`/v1/medications/medicine`)

#### 2.1 약물 목록 조회
```http
GET /v1/medications/medicine
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
POST /v1/medications/medicine
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

#### 2.3 특정 약물 조회
```http
GET /v1/medications/medicine/{id}
Authorization: Bearer {access_token}
```

#### 2.4 약물 수정
```http
PUT /v1/medications/medicine/{id}
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
DELETE /v1/medications/medicine/{id}
Authorization: Bearer {access_token}
```

#### 2.6 오늘의 약물 목록
```http
GET /v1/medications/medicine/today
Authorization: Bearer {access_token}
```

### 3. 복용 로그 (`/v1/medications/medication-log`)

#### 3.1 복용 로그 기록
```http
POST /v1/medications/medication-log
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "medicationId": "med_123",
  "takenAt": "2024-01-01T09:00:00Z",
  "isTaken": true,
  "note": "아침 식사 후 복용"
}
```

#### 3.2 복용 로그 조회
```http
GET /v1/medications/medication-log?medicationId={id}&startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer {access_token}
```

#### 3.3 복용 로그 수정
```http
PUT /v1/medications/medication-log/{id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "isTaken": false,
  "note": "복용하지 않음 - 부작용 발생"
}
```

#### 3.4 복용 로그 삭제
```http
DELETE /v1/medications/medication-log/{id}
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

#### 4.4 분석 요약
```http
GET /v1/analytics/summary?period=month
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

#### 5.5 알림 로그 조회
```http
GET /v1/reminders/logs?startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer {access_token}
```

#### 5.6 알림 통계
```http
GET /v1/reminders/stats?period=month
Authorization: Bearer {access_token}
```

#### 5.7 알림 스케줄링
```http
POST /v1/reminders/schedule
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "medicationId": "med_123",
  "scheduleTime": "2024-01-01T09:00:00Z"
}
```

#### 5.8 알림 처리
```http
POST /v1/reminders/process
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "reminderId": "reminder_123",
  "action": "sent|clicked|dismissed"
}
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

#### 6.3 시스템 설정
```http
GET /v1/system/config
Authorization: Bearer {access_token}
```

#### 6.4 시스템 통계
```http
GET /v1/system/stats
Authorization: Bearer {access_token}
```

#### 6.5 서버 정보
```http
GET /v1/system/info
```

#### 6.6 핑 테스트
```http
GET /v1/system/ping
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
- `AUTH_SOCIAL_LOGIN_FAILED`: 소셜 로그인 실패

### 약물 관리 관련 (MED_*)
- `MED_MEDICATION_NOT_FOUND`: 약물을 찾을 수 없음
- `MED_INVALID_DOSAGE`: 잘못된 복용량
- `MED_INVALID_TIME`: 잘못된 시간 형식
- `MED_DUPLICATE_MEDICATION`: 중복된 약물

### 복용 로그 관련 (LOG_*)
- `LOG_LOG_NOT_FOUND`: 로그를 찾을 수 없음
- `LOG_ALREADY_TAKEN`: 이미 복용 기록이 있음
- `LOG_INVALID_DATE`: 잘못된 날짜

### 통계 관련 (STATS_*)
- `STATS_INVALID_PERIOD`: 잘못된 기간
- `STATS_NO_DATA_FOUND`: 데이터를 찾을 수 없음
- `STATS_INVALID_DATE_RANGE`: 잘못된 날짜 범위

### 알림 관련 (REMINDER_*)
- `REMINDER_NOT_FOUND`: 알림 설정을 찾을 수 없음
- `REMINDER_INVALID_TIME`: 잘못된 알림 시간
- `REMINDER_DUPLICATE`: 중복된 알림 설정
- `REMINDER_NOTIFICATION_FAILED`: 알림 전송에 실패

### 시스템 관련 (SYS_*)
- `SYS_DATABASE_ERROR`: 데이터베이스 오류
- `SYS_EXTERNAL_SERVICE_ERROR`: 외부 서비스 오류
- `SYS_RATE_LIMIT_EXCEEDED`: 요청 한도 초과
- `SYS_NOTIFICATION_NOT_FOUND`: 알림을 찾을 수 없음

## 🔧 개발 환경 설정

### 환경변수
- **개발 환경**: `http://localhost:8000/v1`
- **프로덕션 환경**: `https://api.onedaypillo.com/v1`

### API 문서
- **Swagger UI**: `{BASE_URL}/docs`
- **ReDoc**: `{BASE_URL}/redoc`

## 📋 사용 예제

### 1. 사용자 로그인
```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### 2. 약물 목록 조회
```http
GET /v1/medications/medicine
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. 복용 로그 기록
```http
POST /v1/medications/medication-log
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "medicationId": "med_123",
  "takenAt": "2024-01-01T09:00:00Z",
  "isTaken": true,
  "note": "아침 식사 후 복용"
}
```

### 4. 통계 조회
```http
GET /v1/analytics/medication-stats?startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

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

