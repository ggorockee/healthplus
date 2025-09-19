# OneDayPillo API 테스트 명세서

## 개요

이 문서는 OneDayPillo API의 테스트 명세서입니다. TDD(Test-Driven Development) 방법론에 따라 작성되었으며, 모든 API 엔드포인트에 대한 단위 테스트와 통합 테스트를 포함합니다.

## 테스트 환경

### 테스트 데이터베이스
- **데이터베이스**: SQLite (테스트 전용)
- **생성 시점**: 테스트 시작 시 자동 생성
- **삭제 시점**: 테스트 종료 후 자동 삭제
- **격리**: 각 테스트는 독립적인 데이터베이스 세션을 사용

### 테스트 설정
- **프레임워크**: pytest
- **비동기 지원**: pytest-asyncio
- **테스트 클라이언트**: FastAPI TestClient
- **가상환경**: conda (onedaypillo)

## 테스트 구조

### 테스트 파일 구성
```
tests/
├── conftest.py              # 테스트 설정 및 픽스처
├── test_api.py              # 통합 테스트 및 에러 핸들링
├── test_auth_api.py         # 인증 관련 테스트
├── test_medication_api.py   # 약물 관리 테스트
├── test_reminder_api.py     # 알림 및 리마인더 테스트
├── test_analytics_api.py    # 통계 및 분석 테스트
└── test_system_api.py       # 시스템 관련 테스트
```

## 테스트 카테고리

### 1. 인증 테스트 (test_auth_api.py)

#### 1.1 사용자 등록 테스트
- **test_register_user_success**: 정상적인 사용자 등록
- **test_register_user_duplicate_email**: 중복 이메일 등록 시도
- **test_register_user_weak_password**: 약한 비밀번호 등록 시도
- **test_register_user_invalid_email**: 잘못된 이메일 형식
- **test_register_user_missing_fields**: 필수 필드 누락

#### 1.2 사용자 로그인 테스트
- **test_login_user_success**: 정상적인 로그인
- **test_login_user_invalid_credentials**: 잘못된 인증 정보
- **test_login_user_wrong_password**: 잘못된 비밀번호
- **test_login_user_nonexistent_user**: 존재하지 않는 사용자

#### 1.3 토큰 관리 테스트
- **test_refresh_token_success**: 토큰 갱신 성공
- **test_refresh_token_invalid**: 잘못된 리프레시 토큰
- **test_refresh_token_expired**: 만료된 리프레시 토큰

#### 1.4 프로필 관리 테스트
- **test_get_profile_success**: 프로필 조회 성공
- **test_update_profile_success**: 프로필 업데이트 성공
- **test_update_profile_invalid_data**: 잘못된 프로필 데이터

#### 1.5 로그아웃 테스트
- **test_logout_success**: 로그아웃 성공
- **test_logout_invalid_token**: 잘못된 토큰으로 로그아웃

#### 1.6 통합 테스트
- **test_complete_auth_workflow**: 전체 인증 워크플로우
- **test_token_expiration_handling**: 토큰 만료 처리

### 2. 약물 관리 테스트 (test_medication_api.py)

#### 2.1 약물 CRUD 테스트
- **test_create_medication_success**: 약물 생성 성공
- **test_create_medication_invalid_data**: 잘못된 데이터로 약물 생성
- **test_create_medication_missing_fields**: 필수 필드 누락
- **test_get_medications_success**: 약물 목록 조회 성공
- **test_get_medication_by_id_success**: 특정 약물 조회 성공
- **test_get_medication_by_id_not_found**: 존재하지 않는 약물 조회
- **test_update_medication_success**: 약물 정보 수정 성공
- **test_update_medication_not_found**: 존재하지 않는 약물 수정
- **test_delete_medication_success**: 약물 삭제 성공
- **test_delete_medication_not_found**: 존재하지 않는 약물 삭제

#### 2.2 오늘의 약물 테스트
- **test_get_today_medications_success**: 오늘의 약물 조회 성공
- **test_get_today_medications_empty**: 오늘의 약물이 없는 경우

#### 2.3 복용 로그 테스트
- **test_create_medication_log_success**: 복용 로그 생성 성공
- **test_create_medication_log_invalid_medication_id**: 잘못된 약물 ID
- **test_get_medication_logs_success**: 복용 로그 조회 성공
- **test_update_medication_log_success**: 복용 로그 수정 성공
- **test_delete_medication_log_success**: 복용 로그 삭제 성공

#### 2.4 복용 기록 테스트
- **test_create_medication_record_success**: 복용 기록 생성 성공
- **test_get_daily_records_success**: 일일 복용 기록 조회 성공
- **test_update_medication_record_success**: 복용 기록 수정 성공

#### 2.5 통계 테스트
- **test_get_monthly_statistics_success**: 월별 통계 조회 성공

#### 2.6 통합 테스트
- **test_complete_medication_workflow**: 전체 약물 관리 워크플로우

### 3. 알림 및 리마인더 테스트 (test_reminder_api.py)

#### 3.1 리마인더 CRUD 테스트
- **test_create_reminder_success**: 리마인더 생성 성공
- **test_create_reminder_invalid_data**: 잘못된 데이터로 리마인더 생성
- **test_create_reminder_missing_fields**: 필수 필드 누락
- **test_get_reminders_success**: 리마인더 목록 조회 성공
- **test_get_reminder_by_id_success**: 특정 리마인더 조회 성공
- **test_get_reminder_by_id_not_found**: 존재하지 않는 리마인더 조회
- **test_update_reminder_success**: 리마인더 수정 성공
- **test_update_reminder_not_found**: 존재하지 않는 리마인더 수정
- **test_delete_reminder_success**: 리마인더 삭제 성공
- **test_delete_reminder_not_found**: 존재하지 않는 리마인더 삭제

#### 3.2 알림 로그 테스트
- **test_get_notification_logs_success**: 알림 로그 조회 성공
- **test_get_notification_logs_with_filters**: 필터를 사용한 알림 로그 조회
- **test_get_notification_logs_invalid_date_format**: 잘못된 날짜 형식

#### 3.3 알림 통계 테스트
- **test_get_notification_stats_success**: 알림 통계 조회 성공
- **test_get_notification_stats_with_period**: 기간별 알림 통계 조회
- **test_get_notification_stats_invalid_period**: 잘못된 기간

#### 3.4 알림 스케줄링 테스트
- **test_schedule_notifications_success**: 알림 스케줄링 성공
- **test_process_notifications_success**: 알림 처리 성공
- **test_process_notifications_without_auth**: 인증 없이 알림 처리

#### 3.5 통합 테스트
- **test_complete_reminder_workflow**: 전체 리마인더 워크플로우
- **test_reminder_with_multiple_days**: 여러 날짜 리마인더 테스트
- **test_reminder_time_validation**: 리마인더 시간 검증
- **test_reminder_status_filtering**: 리마인더 상태 필터링

### 4. 통계 및 분석 테스트 (test_analytics_api.py)

#### 4.1 약물 통계 테스트
- **test_get_medication_stats_success**: 약물 통계 조회 성공
- **test_get_medication_stats_with_date_range**: 날짜 범위별 통계 조회
- **test_get_medication_stats_invalid_date_format**: 잘못된 날짜 형식

#### 4.2 복용 준수율 테스트
- **test_get_compliance_rate_success**: 복용 준수율 조회 성공
- **test_get_compliance_rate_with_medication_id**: 특정 약물 준수율 조회
- **test_get_compliance_rate_with_period**: 기간별 준수율 조회
- **test_get_compliance_rate_invalid_period**: 잘못된 기간

#### 4.3 약물 복용 이력 테스트
- **test_get_medication_history_success**: 약물 복용 이력 조회 성공
- **test_get_medication_history_with_medication_id**: 특정 약물 이력 조회
- **test_get_medication_history_with_period**: 기간별 이력 조회
- **test_get_medication_history_invalid_period**: 잘못된 기간

#### 4.4 분석 요약 테스트
- **test_get_analytics_summary_success**: 분석 요약 조회 성공

#### 4.5 통합 테스트
- **test_complete_analytics_workflow**: 전체 분석 워크플로우
- **test_analytics_with_date_filters**: 날짜 필터를 사용한 분석
- **test_analytics_with_period_filters**: 기간 필터를 사용한 분석
- **test_analytics_with_medication_specific_filters**: 약물별 필터를 사용한 분석
- **test_analytics_data_consistency**: 분석 데이터 일관성
- **test_analytics_empty_data_handling**: 빈 데이터 처리

### 5. 시스템 테스트 (test_system_api.py)

#### 5.1 헬스체크 테스트
- **test_health_check_success**: 루트 헬스체크 성공
- **test_system_health_check_success**: 시스템 헬스체크 성공
- **test_system_health_check_detailed**: 상세한 시스템 헬스체크

#### 5.2 버전 정보 테스트
- **test_get_version_info_success**: 버전 정보 조회 성공
- **test_version_info_format**: 버전 정보 형식 검증

#### 5.3 시스템 설정 테스트
- **test_get_system_config_success**: 시스템 설정 조회 성공
- **test_system_config_public_info_only**: 공개 정보만 포함되는지 확인

#### 5.4 시스템 통계 테스트
- **test_get_system_stats_success**: 시스템 통계 조회 성공
- **test_system_stats_format**: 시스템 통계 형식 검증

#### 5.5 서버 정보 테스트
- **test_get_system_info_success**: 서버 정보 조회 성공
- **test_system_info_completeness**: 서버 정보 완전성 검증

#### 5.6 핑 테스트
- **test_ping_success**: 핑 테스트 성공
- **test_ping_response_time**: 핑 응답 시간 측정

#### 5.7 에러 핸들링 테스트
- **test_system_endpoints_method_not_allowed**: 허용되지 않는 HTTP 메서드
- **test_system_endpoints_with_invalid_params**: 잘못된 파라미터

#### 5.8 통합 테스트
- **test_all_system_endpoints_accessible**: 모든 시스템 엔드포인트 접근 가능
- **test_system_endpoints_response_format_consistency**: 응답 형식 일관성
- **test_system_monitoring_workflow**: 시스템 모니터링 워크플로우
- **test_system_performance_under_load**: 부하 상태에서의 성능
- **test_system_data_consistency**: 시스템 데이터 일관성

### 6. 통합 테스트 (test_api.py)

#### 6.1 에러 핸들링 테스트
- **test_not_found_error**: 404 에러 처리
- **test_unauthorized_access**: 401 에러 처리
- **test_malformed_json**: 잘못된 JSON 처리
- **test_missing_content_type**: Content-Type 누락 처리

#### 6.2 API 통합 테스트
- **test_complete_user_workflow**: 전체 사용자 워크플로우
- **test_cross_user_data_isolation**: 사용자 간 데이터 격리
- **test_concurrent_requests**: 동시 요청 처리
- **test_api_cors_headers**: CORS 헤더 검증
- **test_api_response_format_consistency**: API 응답 형식 일관성
- **test_api_performance_benchmarks**: API 성능 벤치마크
- **test_api_data_validation_edge_cases**: 데이터 검증 엣지 케이스
- **test_api_pagination_and_limits**: 페이지네이션 및 제한

## 테스트 실행

### 전체 테스트 실행
```bash
conda activate onedaypillo
export DATABASE_URL="sqlite+aiosqlite:///./test.db"
export JWT_SECRET_KEY="test-secret-key-for-development-only"
python -m pytest tests/ -v
```

### 특정 테스트 파일 실행
```bash
python -m pytest tests/test_auth_api.py -v
```

### 특정 테스트 클래스 실행
```bash
python -m pytest tests/test_auth_api.py::TestAuthRegistration -v
```

### 특정 테스트 함수 실행
```bash
python -m pytest tests/test_auth_api.py::TestAuthRegistration::test_register_user_success -v
```

## 테스트 픽스처

### 주요 픽스처
- **client**: FastAPI 테스트 클라이언트
- **auth_headers**: 인증 헤더가 포함된 딕셔너리
- **test_user**: 테스트용 사용자 데이터
- **test_medication**: 테스트용 약물 데이터
- **test_reminder**: 테스트용 리마인더 데이터
- **db_session**: 데이터베이스 세션 (자동 롤백)

### 데이터베이스 픽스처
- **setup_test_db**: 테스트 데이터베이스 생성 및 삭제
- **db_session**: 각 테스트마다 새로운 데이터베이스 세션 제공

## 테스트 데이터

### 테스트 사용자
```python
test_user = {
    "email": f"test{uuid.uuid4()}@example.com",
    "password": "TestPassword123!",
    "display_name": "테스트 사용자"
}
```

### 테스트 약물
```python
test_medication = {
    "name": "테스트 약물",
    "dosage": "1정",
    "frequency": "하루 3회",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31",
    "instructions": "식후 30분에 복용",
    "reminder_times": ["08:00", "14:00", "20:00"]
}
```

### 테스트 리마인더
```python
test_reminder = {
    "medication_id": "uuid",
    "reminder_time": "08:00",
    "days_of_week": [1, 2, 3, 4, 5],
    "is_active": True,
    "notification_type": "push"
}
```

## 테스트 커버리지

### 목표 커버리지
- **라인 커버리지**: 90% 이상
- **브랜치 커버리지**: 85% 이상
- **함수 커버리지**: 95% 이상

### 커버리지 측정
```bash
python -m pytest tests/ --cov=app --cov-report=html
```

## 테스트 모범 사례

### 1. 테스트 격리
- 각 테스트는 독립적으로 실행되어야 합니다.
- 테스트 간 데이터 공유를 피해야 합니다.
- 데이터베이스 세션은 각 테스트마다 롤백됩니다.

### 2. 테스트 명명
- 테스트 함수명은 `test_`로 시작해야 합니다.
- 테스트 클래스명은 `Test`로 시작해야 합니다.
- 명명 규칙: `test_{기능}_{상황}_{예상결과}`

### 3. 테스트 구조
- **Arrange**: 테스트 데이터 준비
- **Act**: 테스트 실행
- **Assert**: 결과 검증

### 4. 에러 테스트
- 정상 케이스뿐만 아니라 에러 케이스도 테스트해야 합니다.
- 예외 상황에 대한 적절한 에러 응답을 검증해야 합니다.

### 5. 성능 테스트
- 응답 시간이 허용 범위 내에 있는지 확인해야 합니다.
- 동시 요청 처리 능력을 테스트해야 합니다.

## 지속적 통합 (CI)

### GitHub Actions 워크플로우
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.12
      - name: Install dependencies
        run: |
          conda create -n test-env python=3.12
          conda activate test-env
          pip install -r requirements.txt
      - name: Run tests
        run: |
          conda activate test-env
          python -m pytest tests/ -v --cov=app
```

## 문제 해결

### 일반적인 문제
1. **데이터베이스 연결 오류**: 테스트 환경 변수 확인
2. **임포트 오류**: 모델 임포트 순서 확인
3. **비동기 테스트 오류**: pytest-asyncio 설정 확인

### 디버깅 팁
- `-v` 플래그로 상세한 출력 확인
- `--tb=short`로 간단한 트레이스백 확인
- `-s` 플래그로 print 출력 확인

## 결론

이 테스트 명세서는 OneDayPillo API의 모든 기능을 포괄적으로 테스트하기 위한 가이드입니다. TDD 방법론에 따라 작성되었으며, 높은 코드 품질과 안정성을 보장합니다.
