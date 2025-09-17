# HealthPlus 앱 상세 명세서

## 1. 프로젝트 개요

이 문서는 Flutter로 개발된 약 복용 관리 앱 **HealthPlus**의 클라이언트-서버 간 상세 기술 명세를 정의합니다. 사용자가 복용 약을 관리하고, 복용 기록을 추적하며, 관련 통계를 확인할 수 있는 기능을 제공합니다.

이 명세는 클라이언트 코드(`lib/services/supabase_service.dart`)를 기반으로 **앱이 기대하는 서버의 동작**을 기술한 것입니다.

## 2. 기술 스택

- **클라이언트 (Client):** Flutter, Riverpod
- **백엔드 (Backend):** Supabase (PostgreSQL + GoTrue + Realtime + Storage)
- **인증 (Authentication):** Supabase Auth, Firebase Auth (소셜 로그인 연동)
- **광고 (Ads):** Google AdMob

## 3. 데이터베이스 스키마 (예상)

클라이언트 코드 분석을 통해 추론한 Supabase 데이터베이스 테이블 구조입니다.

### 3.1. `users` 테이블

사용자 프로필 정보를 저장합니다. `auth.users` 테이블과 동기화되어야 합니다.

| 컬럼명 | 데이터 타입 | 설명 |
| --- | --- | --- |
| `id` | `uuid` | **Primary Key**. `auth.users.id`를 참조하는 **Foreign Key**여야 합니다. |
| `name` | `text` | 사용자 이름 |
| `created_at` | `timestamptz` | 생성 시각 (기본값: `now()`) |

### 3.2. `medications` 테이블

사용자가 등록한 약 정보를 저장합니다.

| 컬럼명 | 데이터 타입 | 설명 |
| --- | --- | --- |
| `id` | `uuid` | **Primary Key** (기본값: `uuid_generate_v4()`) |
| `user_id` | `uuid` | **Foreign Key** (`users.id` 참조). 어떤 사용자의 약인지 식별합니다. |
| `name` | `text` | 약 이름 |
| `dosage_unit` | `text` | 복용 단위 (예: 정, ml, 포) |
| `single_dosage_amount` | `numeric` | 1회 복용량 |
| `created_at` | `timestamptz` | 생성 시각 (기본값: `now()`) |
| `...` | `...` | 클라이언트에서 추가로 전송하는 `medicationData`에 포함된 다른 필드들 |

### 3.3. `medication_records` 테이블

일자별 약 복용 기록을 저장합니다.

| 컬럼명 | 데이터 타입 | 설명 |
| --- | --- | --- |
| `id` | `uuid` | **Primary Key** (기본값: `uuid_generate_v4()`) |
| `user_id` | `uuid` | **Foreign Key** (`users.id` 참조) |
| `medication_id` | `uuid` | **Foreign Key** (`medications.id` 참조) |
| `date` | `date` | 복용 날짜 (예: `2025-09-17`) |
| `time` | `time` | 복용 시간 (예: `08:00:00`) |
| `status` | `text` | 복용 상태 (예: `taken`, `skipped`) |
| `delay_reason` | `text` | (선택) 복용 지연 사유 |
| `taken_at` | `timestamptz` | (선택) 실제 복용 완료 시각 |

## 4. API 명세 (Supabase)

### 4.1. 인증 (Authentication)

- **기능:** 이메일 회원가입, 로그인, 로그아웃 및 인증 상태 변경 스트림 제공.
- **서비스:** Supabase Auth
- **참고:** 클라이언트에서 `supabase_flutter` 패키지의 `Supabase.instance.client.auth`를 직접 사용합니다.

### 4.2. 사용자 프로필 (`users` 테이블)

- **`getUserProfile()`**
    - **설명:** 현재 로그인된 사용자의 프로필 정보를 가져옵니다.
    - **작업:** `SELECT * FROM users WHERE id = auth.uid() LIMIT 1`
    - **RLS 정책:** **(필수)** 본인의 `id`와 `auth.uid()`가 일치하는 경우에만 `SELECT`를 허용해야 합니다.
- **`updateUserProfile()`**
    - **설명:** 현재 사용자의 프로필을 업데이트합니다.
    - **작업:** `UPDATE users SET ... WHERE id = auth.uid()`
    - **RLS 정책:** **(필수)** 본인의 `id`와 `auth.uid()`가 일치하는 경우에만 `UPDATE`를 허용해야 합니다.

### 4.3. 약 정보 (`medications` 테이블)

- **`getMedications()`**
    - **설명:** 현재 사용자가 등록한 모든 약 목록을 가져옵니다.
    - **작업:** `SELECT * FROM medications WHERE user_id = auth.uid() ORDER BY created_at DESC`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행에 대해서만 `SELECT`를 허용해야 합니다.
- **`addMedication()`**
    - **설명:** 새로운 약 정보를 추가합니다.
    - **작업:** `INSERT INTO medications (user_id, ...medicationData) VALUES (auth.uid(), ...)`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행만 `INSERT`할 수 있도록 허용해야 합니다.
- **`updateMedication()`**
    - **설명:** 기존 약 정보를 수정합니다.
    - **작업:** `UPDATE medications SET ... WHERE id = :medicationId AND user_id = auth.uid()`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행에 대해서만 `UPDATE`를 허용해야 합니다.
- **`deleteMedication()`**
    - **설명:** 약 정보를 삭제합니다.
    - **작업:** `DELETE FROM medications WHERE id = :medicationId AND user_id = auth.uid()`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행에 대해서만 `DELETE`를 허용해야 합니다.

### 4.4. 복용 기록 (`medication_records` 테이블)

- **`getMedicationRecords()`**
    - **설명:** 특정 날짜의 복용 기록을 관련 약 정보와 함께 가져옵니다.
    - **작업:** `SELECT *, medications(*) FROM medication_records WHERE user_id = auth.uid() AND date = :date`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행에 대해서만 `SELECT`를 허용해야 합니다.
- **`addMedicationRecord()`**
    - **설명:** 새로운 복용 기록을 추가합니다.
    - **작업:** `INSERT INTO medication_records (user_id, ...) VALUES (auth.uid(), ...)`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행만 `INSERT`할 수 있도록 허용해야 합니다.
- **`updateMedicationRecord()`**
    - **설명:** 기존 복용 기록의 상태를 업데이트합니다.
    - **작업:** `UPDATE medication_records SET ... WHERE id = :recordId AND user_id = auth.uid()`
    - **RLS 정책:** **(필수)** `user_id`가 `auth.uid()`와 일치하는 행에 대해서만 `UPDATE`를 허용해야 합니다.

### 4.5. 통계

- **`getMonthlyStatistics()`**
    - **설명:** 특정 월의 복용 통계를 계산하여 반환합니다.
    - **작업:** `SELECT status, date, time FROM medication_records WHERE user_id = auth.uid() AND date BETWEEN :startDate AND :endDate`
    - **RLS 정책:** `medication_records` 테이블의 `SELECT` 정책이 적용됩니다.
    - **참고:** 현재 통계 계산 로직은 클라이언트(`SupabaseService._calculateMonthlyStats`)에 구현되어 있습니다. 성능 최적화를 위해 **PostgreSQL 함수(Database Function)로 이전하는 것을 강력히 권장**합니다.

## 5. 백엔드 개발 참고사항

- **명세의 한계:** 이 명세는 클라이언트 코드를 기반으로 추론되었으므로, 실제 백엔드 구현 시 반드시 Supabase 대시보드에서 테이블 구조, 데이터 타입, 제약 조건 등을 재확인해야 합니다.
- **RLS 정책:** **가장 중요한 부분입니다.** 위에서 명시된 RLS(Row Level Security) 정책은 데이터 보안의 최소 요구사항입니다. 각 테이블에 대해 **"사용자는 자신의 데이터만 보고 수정할 수 있다"**는 원칙을 적용하여 RLS 정책을 반드시 설정해야 합니다. 정책이 없으면 모든 사용자의 데이터가 노출될 수 있습니다.
- **`users` 테이블 자동 생성:** 신규 사용자가 가입(`auth.users` 테이블에 추가)될 때, `users` 테이블에 해당 유저의 프로필 행이 자동으로 생성되도록 **데이터베이스 트리거(Database Trigger)**를 설정하는 것을 권장합니다.

## 6. 클라이언트 개발 참고사항

- **실행 환경:**
    - 종속성 설치: `flutter pub get`
    - 앱 실행: `flutter run`
- **코딩 컨벤션:**
    - `flutter_lints`의 권장 규칙을 따릅니다.
    - 상태 관리는 `Riverpod`를 사용합니다.
    - Supabase API 호출은 `lib/services/supabase_service.dart`를 통해서만 이루어져야 합니다.
