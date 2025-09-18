# OneDayPillo API 구현 계획서

## 📋 현재 상태 분석

### ✅ 이미 구현된 기능
- [x] FastAPI 기반 프로젝트 구조 설정
- [x] Clean Architecture 패턴 적용
- [x] PostgreSQL 데이터베이스 연결
- [x] 기본 사용자 모델 (User)
- [x] 기본 약물 모델 (Medication, MedicationRecord)
- [x] 기본 인증 시스템 (이메일 회원가입/로그인)
- [x] 기본 약물 관리 CRUD API
- [x] 기본 복용 기록 API
- [x] JWT 토큰 기반 인증
- [x] 기본 에러 핸들링

### ❌ 누락된 기능 (API 명세서 기준)
- [ ] 환경변수 파일들 (.env.common, .env.dev, .env.prod)
- [ ] 소셜 로그인 (Google, Facebook, Kakao)
- [ ] 토큰 갱신 (refresh token) 기능
- [ ] API 명세서에 맞는 응답 형식 표준화
- [ ] 통계 및 분석 API
- [ ] 알림 시스템
- [ ] 시스템 헬스체크 API
- [ ] 에러 코드 체계화

## 🎯 구현 계획

### Phase 1: 환경 설정 및 기본 구조 완성 (우선순위: 높음)

#### 1.1 환경변수 파일 생성
- [x] `.env.common` 파일 생성 (JWT 설정, API 기본 설정)
- [x] `.env.dev` 파일 생성 (개발 환경 설정)
- [x] `.env.prod` 파일 생성 (프로덕션 환경 설정)
- [x] 환경변수 로딩 로직 확인 및 수정 (config.py 업데이트 완료)

#### 1.2 데이터베이스 모델 업데이트
- [x] User 모델을 API 명세서에 맞게 수정 (provider, isEmailVerified 등 추가)
- [x] Medication 모델을 API 명세서에 맞게 수정 (notificationTime, repeatDays 등 추가)
- [x] MedicationLog 모델 추가 (복용 로그 전용)
- [x] 데이터베이스 마이그레이션 스크립트 작성

#### 1.3 API 응답 형식 표준화
- [x] 공통 응답 스키마 생성 (success, data, message, timestamp)
- [x] 에러 응답 스키마 생성 (error code, message, details)
- [x] 모든 API 엔드포인트에 표준 응답 형식 적용

### Phase 2: 인증 시스템 완성 (우선순위: 높음)

#### 2.1 JWT 토큰 시스템 개선
- [x] Access Token과 Refresh Token 분리
- [x] 토큰 갱신 API 구현 (`/v1/auth/refresh`)
- [x] 토큰 만료 처리 로직 개선

#### 2.2 소셜 로그인 구현
- [ ] Google 로그인 API (`/v1/auth/google`)
- [ ] Facebook 로그인 API (`/v1/auth/facebook`)
- [ ] Kakao 로그인 API (`/v1/auth/kakao`)
- [ ] 소셜 로그인 토큰 검증 로직

#### 2.3 사용자 프로필 관리
- [x] 프로필 조회 API 개선 (`/v1/auth/profile`)
- [x] 프로필 수정 API 완성 (`/v1/auth/profile` PUT)
- [ ] 이메일 인증 기능 (선택사항)

### Phase 3: 약물 관리 API 완성 (우선순위: 높음)

#### 3.1 약물 관리 API 개선
- [ ] 약물 목록 조회 API 개선 (`/v1/medicine`)
- [ ] 약물 추가 API 개선 (`/v1/medicine` POST)
- [ ] 특정 약물 조회 API (`/v1/medicine/{id}`)
- [ ] 약물 수정 API (`/v1/medicine/{id}` PUT)
- [ ] 약물 삭제 API (`/v1/medicine/{id}` DELETE)
- [ ] 오늘의 약물 목록 API (`/v1/medicine/today`)

#### 3.2 복용 로그 API 완성
- [ ] 복용 로그 기록 API (`/v1/medication-log` POST)
- [ ] 복용 로그 조회 API (`/v1/medication-log` GET)
- [ ] 복용 로그 수정 API (`/v1/medication-log/{id}` PUT)
- [ ] 복용 로그 삭제 API (`/v1/medication-log/{id}` DELETE)

### Phase 4: 통계 및 분석 API (우선순위: 중간)

#### 4.1 통계 API 구현
- [ ] 약물 복용 통계 API (`/v1/analytics/medication-stats`)
- [ ] 복용 준수율 API (`/v1/analytics/compliance-rate`)
- [ ] 복용 히스토리 API (`/v1/analytics/history`)

### Phase 5: 알림 시스템 (우선순위: 중간)

#### 5.1 알림 관리 API
- [ ] 알림 설정 조회 API (`/v1/reminders` GET)
- [ ] 알림 설정 추가 API (`/v1/reminders` POST)
- [ ] 알림 설정 수정 API (`/v1/reminders/{id}` PUT)
- [ ] 알림 설정 삭제 API (`/v1/reminders/{id}` DELETE)

### Phase 6: 시스템 API (우선순위: 낮음)

#### 6.1 시스템 관리 API
- [ ] 헬스체크 API 개선 (`/v1/system/health`)
- [ ] 앱 버전 정보 API (`/v1/system/version`)

### Phase 7: 에러 처리 및 보안 (우선순위: 중간)

#### 7.1 에러 처리 개선
- [ ] 에러 코드 체계화 (AUTH_*, MED_*, LOG_*, SYS_*)
- [ ] 상세한 에러 메시지 및 필드 정보 제공
- [ ] 로깅 시스템 개선

#### 7.2 보안 강화
- [ ] CORS 설정 개선
- [ ] Rate Limiting 구현
- [ ] 입력 데이터 검증 강화

### Phase 8: 테스트 및 문서화 (우선순위: 낮음)

#### 8.1 테스트 코드 작성
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] API 테스트 작성

#### 8.2 문서화
- [ ] API 문서 자동 생성 확인
- [ ] README 업데이트
- [ ] 배포 가이드 작성

## 🔧 기술적 고려사항

### 데이터베이스 설계
- UUID를 기본 키로 사용
- 인덱스 최적화 (email, user_id, medication_id 등)
- 관계형 데이터 무결성 보장

### 보안
- JWT 토큰 보안 강화
- 비밀번호 해싱 (bcrypt)
- SQL Injection 방지
- XSS 방지

### 성능
- 데이터베이스 쿼리 최적화
- 캐싱 전략 (Redis 활용)
- 비동기 처리

### 확장성
- 마이크로서비스 아키텍처 고려
- API 버전 관리
- 모니터링 및 로깅

## 📊 진행 상황 추적

### 전체 진행률: 12.5% (1/8 Phase 완료)

- [x] Phase 1: 환경 설정 및 기본 구조 완성
- [ ] Phase 2: 인증 시스템 완성
- [ ] Phase 3: 약물 관리 API 완성
- [ ] Phase 4: 통계 및 분석 API
- [ ] Phase 5: 알림 시스템
- [ ] Phase 6: 시스템 API
- [ ] Phase 7: 에러 처리 및 보안
- [ ] Phase 8: 테스트 및 문서화

## 🚀 다음 단계

1. **즉시 시작**: Phase 1.1 - 환경변수 파일 생성
2. **우선순위**: Phase 1, 2, 3 순서로 진행
3. **병렬 작업**: 가능한 작업들은 동시에 진행
4. **테스트**: 각 Phase 완료 후 기능 테스트

---

*이 계획서는 API 명세서를 기반으로 작성되었으며, 실제 구현 과정에서 필요에 따라 수정될 수 있습니다.*
*최종 업데이트: 2024-01-01*
