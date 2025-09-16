-- HealthPlus 약물 관리 앱 데이터베이스 스키마 (상용 환경)
-- 상용 Supabase Project ID: your_production_project_id
-- 이 파일은 상용 환경에서 사용되는 스키마입니다.

-- 사용자 프로필 테이블
CREATE TABLE user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    profile_image_url TEXT,
    login_method VARCHAR(20) DEFAULT 'email' CHECK (login_method IN ('email', 'kakao', 'google', 'apple')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 약물 정보 테이블
CREATE TABLE medications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    image_path TEXT,
    daily_dosage_count INTEGER NOT NULL CHECK (daily_dosage_count > 0 AND daily_dosage_count <= 10),
    dosage_times TEXT[] NOT NULL,
    form VARCHAR(20) NOT NULL CHECK (form IN ('tablet', 'capsule', 'syrup', 'other')),
    single_dosage_amount INTEGER NOT NULL CHECK (single_dosage_amount > 0),
    dosage_unit VARCHAR(20) NOT NULL CHECK (dosage_unit IN ('tablet', 'capsule', 'ml', 'mg', 'other')),
    has_meal_relation BOOLEAN DEFAULT true,
    meal_relation VARCHAR(20) CHECK (meal_relation IN ('before_meal', 'after_meal', 'irrelevant')),
    is_continuous BOOLEAN DEFAULT true,
    memo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 복용 기록 테이블
CREATE TABLE medication_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    time VARCHAR(5) NOT NULL, -- HH:MM 형식
    status VARCHAR(20) NOT NULL CHECK (status IN ('taken', 'missed', 'delayed')),
    delay_reason TEXT,
    taken_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, medication_id, date, time)
);

-- 알림 설정 테이블
CREATE TABLE notification_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    medication_id UUID REFERENCES medications(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT true,
    reminder_minutes_before INTEGER DEFAULT 0 CHECK (reminder_minutes_before >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, medication_id)
);

-- 상용 환경용 로그 테이블
CREATE TABLE system_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    level VARCHAR(20) NOT NULL CHECK (level IN ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    message TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_medications_user_id ON medications(user_id);
CREATE INDEX idx_medications_created_at ON medications(created_at DESC);
CREATE INDEX idx_medication_records_user_id ON medication_records(user_id);
CREATE INDEX idx_medication_records_date ON medication_records(date DESC);
CREATE INDEX idx_medication_records_user_date ON medication_records(user_id, date);
CREATE INDEX idx_notification_settings_user_id ON notification_settings(user_id);
CREATE INDEX idx_system_logs_level ON system_logs(level);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at DESC);

-- RLS (Row Level Security) 정책 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_logs ENABLE ROW LEVEL SECURITY;

-- 사용자 프로필 RLS 정책
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- 약물 정보 RLS 정책
CREATE POLICY "Users can view own medications" ON medications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own medications" ON medications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own medications" ON medications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own medications" ON medications
    FOR DELETE USING (auth.uid() = user_id);

-- 복용 기록 RLS 정책
CREATE POLICY "Users can view own medication records" ON medication_records
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own medication records" ON medication_records
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own medication records" ON medication_records
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own medication records" ON medication_records
    FOR DELETE USING (auth.uid() = user_id);

-- 알림 설정 RLS 정책
CREATE POLICY "Users can view own notification settings" ON notification_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification settings" ON notification_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification settings" ON notification_settings
    FOR UPDATE USING (auth.uid() = user_id);

-- 시스템 로그 RLS 정책 (서비스 역할만 접근 가능)
CREATE POLICY "Service role can manage system logs" ON system_logs
    FOR ALL USING (auth.role() = 'service_role');

-- 트리거 함수: updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medications_updated_at BEFORE UPDATE ON medications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_settings_updated_at BEFORE UPDATE ON notification_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 함수: 월간 통계 계산
CREATE OR REPLACE FUNCTION get_monthly_statistics(
    p_user_id UUID,
    p_year INTEGER,
    p_month INTEGER
)
RETURNS JSON AS $$
DECLARE
    start_date DATE;
    end_date DATE;
    total_records INTEGER;
    completed_records INTEGER;
    avg_completion_rate DECIMAL;
    consecutive_days INTEGER;
    best_time VARCHAR(10);
    result JSON;
BEGIN
    -- 월의 시작일과 종료일 계산
    start_date := DATE(p_year || '-' || p_month || '-01');
    end_date := start_date + INTERVAL '1 month';

    -- 총 기록 수와 완료된 기록 수
    SELECT COUNT(*), COUNT(*) FILTER (WHERE status = 'taken')
    INTO total_records, completed_records
    FROM medication_records
    WHERE user_id = p_user_id
      AND date >= start_date
      AND date < end_date;

    -- 완료율 계산
    IF total_records > 0 THEN
        avg_completion_rate := completed_records::DECIMAL / total_records;
    ELSE
        avg_completion_rate := 0;
    END IF;

    -- 연속 복용일 계산 (간단한 버전)
    WITH daily_completion AS (
        SELECT date,
               CASE WHEN COUNT(*) = COUNT(*) FILTER (WHERE status = 'taken')
                    THEN 1 ELSE 0 END AS completed
        FROM medication_records
        WHERE user_id = p_user_id
          AND date >= start_date
          AND date < end_date
        GROUP BY date
        ORDER BY date DESC
    )
    SELECT COUNT(*)
    INTO consecutive_days
    FROM (
        SELECT date, completed,
               ROW_NUMBER() OVER (ORDER BY date DESC) as rn
        FROM daily_completion
        WHERE completed = 1
    ) t
    WHERE rn = (SELECT COUNT(*) FROM daily_completion WHERE completed = 1 LIMIT rn);

    -- 가장 많이 복용한 시간대
    SELECT time
    INTO best_time
    FROM medication_records
    WHERE user_id = p_user_id
      AND date >= start_date
      AND date < end_date
      AND status = 'taken'
    GROUP BY time
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    IF best_time IS NULL THEN
        best_time := '아침';
    ELSE
        CASE
            WHEN CAST(SPLIT_PART(best_time, ':', 1) AS INTEGER) BETWEEN 6 AND 11 THEN
                best_time := '아침';
            WHEN CAST(SPLIT_PART(best_time, ':', 1) AS INTEGER) BETWEEN 12 AND 17 THEN
                best_time := '점심';
            ELSE
                best_time := '저녁';
        END CASE;
    END IF;

    -- JSON 결과 생성
    result := JSON_BUILD_OBJECT(
        'average_completion_rate', avg_completion_rate,
        'consecutive_days', COALESCE(consecutive_days, 0),
        'best_time', best_time,
        'total_days', (SELECT COUNT(DISTINCT date) FROM medication_records
                      WHERE user_id = p_user_id AND date >= start_date AND date < end_date),
        'completed_days', (SELECT COUNT(DISTINCT date) FROM medication_records
                          WHERE user_id = p_user_id AND date >= start_date AND date < end_date
                          GROUP BY date HAVING COUNT(*) = COUNT(*) FILTER (WHERE status = 'taken'))
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 상용 환경용 함수: 시스템 로그 기록
CREATE OR REPLACE FUNCTION log_system_event(
    p_level VARCHAR(20),
    p_message TEXT,
    p_user_id UUID DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    log_id UUID;
BEGIN
    INSERT INTO system_logs (level, message, user_id, metadata)
    VALUES (p_level, p_message, p_user_id, p_metadata)
    RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
