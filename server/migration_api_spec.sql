-- OneDayPillo API 데이터베이스 마이그레이션 스크립트
-- API 명세서에 맞게 모델 업데이트

-- 1. User 테이블 업데이트
-- 기존 컬럼 수정 및 새 컬럼 추가

-- hashed_password를 nullable로 변경 (소셜 로그인 지원)
ALTER TABLE users ALTER COLUMN hashed_password DROP NOT NULL;

-- name 컬럼을 display_name으로 변경
ALTER TABLE users RENAME COLUMN name TO display_name;

-- 새 컬럼들 추가
ALTER TABLE users ADD COLUMN photo_url VARCHAR;
ALTER TABLE users ADD COLUMN provider VARCHAR NOT NULL DEFAULT 'email';
ALTER TABLE users ADD COLUMN is_email_verified BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Medication 테이블 업데이트
-- API 명세서 기준 필드들 추가

-- 새 컬럼들 추가
ALTER TABLE medications ADD COLUMN dosage VARCHAR NOT NULL DEFAULT '1정';
ALTER TABLE medications ADD COLUMN notification_hour INTEGER NOT NULL DEFAULT 9;
ALTER TABLE medications ADD COLUMN notification_minute INTEGER NOT NULL DEFAULT 0;
ALTER TABLE medications ADD COLUMN repeat_days JSONB NOT NULL DEFAULT '[1,2,3,4,5]';
ALTER TABLE medications ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- 기존 필드들을 nullable로 변경 (호환성 유지)
ALTER TABLE medications ALTER COLUMN daily_dosage_count DROP NOT NULL;
ALTER TABLE medications ALTER COLUMN dosage_times DROP NOT NULL;
ALTER TABLE medications ALTER COLUMN form DROP NOT NULL;
ALTER TABLE medications ALTER COLUMN single_dosage_amount DROP NOT NULL;
ALTER TABLE medications ALTER COLUMN dosage_unit DROP NOT NULL;

-- 3. MedicationRecord 테이블 업데이트
-- API 명세서 기준 필드들 추가

-- 새 컬럼들 추가
ALTER TABLE medication_records ADD COLUMN taken_at TIMESTAMP NOT NULL DEFAULT NOW();
ALTER TABLE medication_records ADD COLUMN is_taken BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE medication_records ADD COLUMN note VARCHAR;

-- 기존 필드들을 nullable로 변경 (호환성 유지)
ALTER TABLE medication_records ALTER COLUMN date DROP NOT NULL;
ALTER TABLE medication_records ALTER COLUMN time DROP NOT NULL;
ALTER TABLE medication_records ALTER COLUMN status DROP NOT NULL;

-- 4. 인덱스 추가 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_users_provider ON users(provider);
CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(is_email_verified);
CREATE INDEX IF NOT EXISTS idx_medications_active ON medications(is_active);
CREATE INDEX IF NOT EXISTS idx_medications_notification_time ON medications(notification_hour, notification_minute);
CREATE INDEX IF NOT EXISTS idx_medication_records_taken_at ON medication_records(taken_at);
CREATE INDEX IF NOT EXISTS idx_medication_records_is_taken ON medication_records(is_taken);

-- 5. 코멘트 추가
COMMENT ON COLUMN users.display_name IS '사용자 표시명';
COMMENT ON COLUMN users.photo_url IS '프로필 사진 URL';
COMMENT ON COLUMN users.provider IS '로그인 제공자 (email, google, facebook, kakao)';
COMMENT ON COLUMN users.is_email_verified IS '이메일 인증 상태';

COMMENT ON COLUMN medications.dosage IS '복용량 (예: 1정, 2캡슐)';
COMMENT ON COLUMN medications.notification_hour IS '알림 시간 (시)';
COMMENT ON COLUMN medications.notification_minute IS '알림 시간 (분)';
COMMENT ON COLUMN medications.repeat_days IS '반복 요일 배열 [1,2,3,4,5]';
COMMENT ON COLUMN medications.is_active IS '약물 활성 상태';

COMMENT ON COLUMN medication_records.taken_at IS '복용 시간';
COMMENT ON COLUMN medication_records.is_taken IS '복용 여부';
COMMENT ON COLUMN medication_records.note IS '복용 메모';

-- 마이그레이션 완료 메시지
SELECT 'OneDayPillo API 데이터베이스 마이그레이션 완료' AS migration_status;
