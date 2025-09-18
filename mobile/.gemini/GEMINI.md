# HealthPlus 모바일 앱 프로젝트 분석

## 1. 프로젝트 개요

이 프로젝트는 Flutter로 개발된 **HealthPlus**라는 약 복용 관리 모바일 애플리케이션입니다. 사용자가 복용하는 약을 등록하고, 정해진 시간에 맞춰 복용 알림을 받으며, 복용 기록을 추적하고 통계를 확인할 수 있도록 돕습니다.

주요 기술 스택은 다음과 같습니다:

- **프레임워크:** Flutter
- **상태 관리:** Riverpod
- **백엔드 및 데이터베이스:** Supabase (주요 데이터 저장소)
- **인증:** Supabase Auth, Firebase Auth (소셜 로그인 지원)
- **광고:** Google AdMob
- **로컬 저장소:** `shared_preferences`

## 2. 아키텍처 및 파일 상세 분석

### `lib/`

애플리케이션의 핵심 소스 코드가 위치합니다.

#### `main.dart`

- **역할:** 앱의 진입점 (Entry Point).
- **주요 기능:**
    - `WidgetsFlutterBinding` 초기화.
    - Firebase, Supabase, AdMob 등 주요 서비스 초기화.
    - `ProviderScope`를 사용하여 Riverpod 상태 관리 환경 설정.
    - `AuthWrapper`를 통해 사용자의 인증 상태에 따라 `LoginScreen` 또는 `MainNavigationScreen`으로 분기.

#### `config/`

앱의 설정을 관리하는 파일들이 위치합니다.

- **`theme.dart`:**
    - **역할:** 앱의 전역 테마(색상, 타이포그래피 등)를 정의합니다.
    - **주요 내용:**
        - `AppColors`: 앱에서 사용되는 주요 색상 팔레트를 정의합니다. (Primary: 녹색 계열)
        - `AppTypography`: `HelveticaNeue` 폰트 기반의 텍스트 스타일을 정의합니다.
        - `buildLightTheme()`: 정의된 색상과 타이포그래피를 사용하여 `ThemeData`를 생성합니다.

- **`supabase_config.dart`:**
    - **역할:** Supabase 클라이언트 초기화 및 관리를 담당합니다. (내용 유추)

- **`firebase_config.dart`:**
    - **역할:** Firebase 관련 설정(Remote Config 등)을 관리합니다. (내용 유추)

#### `models/`

애플리케이션에서 사용되는 데이터 모델 클래스들이 정의되어 있습니다.

- **`medication.dart`:**
    - **역할:** '약물' 정보를 담는 `Medication` 모델 클래스를 정의합니다.
    - **주요 속성:** `id`, `name`(약 이름), `dosage`(복용량), `notificationTime`(알림 시간), `repeatDays`(반복 요일), `isActive`(활성화 여부).

- **`medication_log.dart`:**
    - **역할:** '약물 복용 기록'을 담는 `MedicationLog` 모델 클래스를 정의합니다.
    - **주요 속성:** `id`, `medicationId`, `takenAt`(복용 시간), `isTaken`(복용 여부), `note`(메모).

- **`user.dart`:**
    - **역할:** '사용자' 정보 및 인증 상태 관련 모델들을 정의합니다.
    - **주요 클래스 및 열거형:**
        - `User`: 사용자 정보를 담는 모델. (`id`, `email`, `displayName` 등)
        - `AuthProvider`: 인증 제공자(email, google 등)를 나타내는 열거형.
        - `AuthStatus`: 인증 상태(loading, authenticated 등)를 나타내는 열거형.
        - `AuthState`: 인증 상태와 사용자 정보를 함께 관리하는 모델.

#### `providers/`

Riverpod를 사용하여 상태를 관리하는 Provider들이 정의되어 있습니다.

- **`auth_provider.dart`:**
    - **역할:** 앱의 전반적인 인증 상태를 관리합니다.
    - **주요 기능:**
        - `AuthNotifier`: `SupabaseAuthService`와 상호작용하여 회원가입, 로그인, 로그아웃 처리.
        - `authProvider`: `AuthNotifier`를 제공하는 `StateNotifierProvider`.
        - `currentUserProvider`, `isAuthenticatedProvider`: 인증 상태에 따라 파생된 데이터를 제공하는 프로바이더.

- **`medication_provider.dart`:**
    - **역할:** 약물 목록(`List<Medication>`) 상태를 관리합니다.
    - **주요 기능:**
        - `MedicationNotifier`: 약물 추가, 수정, 삭제, 토글 기능 제공.
        - `shared_preferences`를 사용하여 약물 목록을 로컬에 저장하고 불러옵니다.
        - `todayMedicationsProvider`: 오늘 복용해야 할 약물 목록만 필터링하여 제공합니다.

- **`medication_log_provider.dart`:**
    - **역할:** 약물 복용 기록(`List<MedicationLog>`) 상태를 관리합니다.
    - **주요 기능:**
        - `MedicationLogNotifier`: 복용 기록 추가, 수정, 삭제 기능 제공.
        - `shared_preferences`를 사용하여 복용 기록을 로컬에 저장하고 불러옵니다.
        - 특정 약물/날짜에 대한 복용 기록 조회, 복용률 계산 등의 유틸리티 메서드를 제공합니다.

- **`admob_provider.dart`:**
    - **역할:** Google AdMob 광고 상태를 관리합니다.
    - **주요 기능:**
        - `AdMobNotifier`: AdMob 초기화, 배너 광고 로드 및 해제 기능 제공.
        - `AdUnitIds`: Android/iOS 플랫폼별 광고 단위 ID를 정의합니다.

#### `screens/`

각 화면을 구성하는 위젯 파일들이 위치합니다.

- **`login_screen.dart`:** 이메일/비밀번호를 이용한 로그인 UI 및 기능 제공. 데모 계정으로 빠른 로그인을 지원합니다.
- **`signup_screen.dart`:** 이메일/비밀번호를 이용한 회원가입 UI 및 기능 제공.
- **`main_navigation_screen.dart`:** 로그인 후 진입하는 메인 화면. `AppBottomNav`를 통해 `HomeScreen`, `HistoryScreen`, `StatisticsScreen`, `GuardianScreen`을 전환합니다.
- **`home_screen.dart`:** '오늘의 약' 목록을 보여주는 홈 화면. `SwipeableMedicationCard`를 통해 각 약물의 복용 여부를 체크하고, 편집/삭제할 수 있습니다. 하단에는 배너 광고가 표시됩니다.
- **`add_medication_screen.dart`:** 새로운 약물을 등록하는 화면. 약 이름, 복용량, 알림 시간, 반복 요일을 설정할 수 있습니다.
- **`history_screen.dart`:** 날짜별 복용 기록을 보여주는 화면. 주간 캘린더로 날짜를 선택하고, 필터(전체, 미복용, 복용완료)를 통해 기록을 조회할 수 있습니다.
- **`statistics_screen.dart`:** 복용 통계를 시각적으로 보여주는 화면. 복용률 추이, 일별 복용 현황 등을 차트(`fl_chart`)로 표시합니다. (현재는 모의 데이터 사용)
- **`guardian_screen.dart`:** 가족/친구에게 복용 현황을 공유하는 기능의 UI를 보여주는 화면. (현재는 플레이스홀더)

#### `services/`

외부 서비스와의 통신을 담당하는 서비스 클래스들이 위치합니다.

- **`supabase_auth_service.dart`:**
    - **역할:** Supabase를 이용한 인증 관련 로직을 처리합니다.
    - **주요 기능:** 이메일 회원가입, 이메일 로그인, 로그아웃 기능을 Supabase Auth API와 연동하여 구현합니다. 데모용으로 로그인/회원가입이 무조건 성공하도록 처리되어 있습니다.

#### `widgets/`

여러 화면에서 재사용되는 공통 위젯들이 위치합니다.

- **`app_bottom_nav.dart`:** 하단 네비게이션 바 위젯.
- **`app_button.dart`:** 앱의 주요 스타일에 맞는 공용 버튼 위젯.
- **`app_card.dart`:** 공용 카드 레이아웃 위젯.
- **`app_chip.dart`:** 필터링 등에 사용되는 공용 칩 위젯.
- **`app_input.dart`:** 로그인/회원가입 등에서 사용되는 공용 입력 필드 위젯.
- **`app_text.dart`:** 앱의 타이포그래피 스타일에 맞는 공용 텍스트 위젯.
- **`swipeable_medication_card.dart`:** 홈 화면에서 약물 정보를 보여주는 카드. 토글, 편집, 삭제 기능을 포함합니다.

### `test/`

- **`widget_test.dart`:** 앱의 초기 화면에 '하루 알약'과 '오늘의 약' 텍스트가 정상적으로 표시되는지 확인하는 간단한 위젯 테스트가 포함되어 있습니다.

## 3. 주요 실행 흐름

1.  **앱 시작 (`main.dart`)**:
    - Firebase, Supabase, AdMob 서비스가 초기화됩니다.
    - `AuthWrapper`가 현재 인증 상태를 확인합니다.
2.  **인증 분기 (`AuthWrapper`)**:
    - **미인증 상태**: `LoginScreen`이 표시됩니다.
        - 사용자는 이메일/비밀번호로 로그인하거나, `SignUpScreen`으로 이동하여 회원가입할 수 있습니다.
        - 데모 계정으로 즉시 로그인을 시도할 수 있습니다.
    - **인증 상태**: `MainNavigationScreen`으로 이동합니다.
3.  **메인 화면 (`MainNavigationScreen`)**:
    - 하단 네비게이션 바를 통해 4개의 주요 화면(`HomeScreen`, `HistoryScreen`, `StatisticsScreen`, `GuardianScreen`)으로 이동할 수 있습니다.
    - 기본적으로 `HomeScreen`이 표시됩니다.
4.  **약물 관리 (`HomeScreen`, `AddMedicationScreen`)**:
    - `HomeScreen`에서 '약 추가' 플로팅 버튼을 눌러 `AddMedicationScreen`으로 이동합니다.
    - 새로운 약물 정보를 입력하고 저장하면 `medicationProvider`를 통해 상태가 업데이트되고 로컬(`shared_preferences`)에 저장됩니다.
    - `HomeScreen`에서 약물 카드의 토글 버튼을 눌러 복용 여부를 체크하면 `medication_log_provider`를 통해 기록이 저장됩니다.
5.  **기록 및 통계 확인 (`HistoryScreen`, `StatisticsScreen`)**:
    - `HistoryScreen`에서 날짜별/상태별 복용 기록을 확인할 수 있습니다.
    - `StatisticsScreen`에서 차트를 통해 복용 패턴과 통계를 시각적으로 확인할 수 있습니다.
