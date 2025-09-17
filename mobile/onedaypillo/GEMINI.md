# Gemini 컨텍스트: HealthPlus 모바일 앱

## 프로젝트 개요

이 프로젝트는 Flutter로 개발된 **HealthPlus**라는 이름의 약 복용 관리 모바일 애플리케이션입니다. 사용자가 복용하는 약을 등록하고, 정해진 시간에 맞춰 복용 알림을 받으며, 복용 기록을 추적하고 통계를 확인할 수 있도록 돕습니다.

주요 기술 스택은 다음과 같습니다:

- **프레임워크:** Flutter
- **상태 관리:** Riverpod
- **백엔드 및 데이터베이스:** Supabase (주요 데이터 저장소)
- **인증:** Supabase Auth, Firebase Auth (소셜 로그인 지원)
- **광고:** Google AdMob
- **기타:** `shared_preferences` (로컬 데이터 저장), `http`

## 아키텍처

- **`lib/`**: 애플리케이션의 핵심 소스 코드가 위치합니다.
    - **`main.dart`**: 앱의 진입점으로, Firebase, Supabase, AdMob 등 주요 서비스를 초기화하고 첫 화면을 결정합니다.
    - **`screens/`**: 각 화면을 구성하는 위젯 파일들이 있습니다. (예: `home_screen.dart`, `login_screen.dart`)
    - **`providers/`**: Riverpod를 사용하여 상태를 관리하는 Provider들이 정의되어 있습니다.
    - **`models/`**: 데이터 모델 클래스들이 정의되어 있습니다.
    - **`services/`**: Supabase, Firebase, AdMob 등 외부 서비스와의 통신을 담당하는 서비스 클래스들이 있습니다.
    - **`widgets/`**: 여러 화면에서 재사용되는 공통 위젯들이 있습니다.
    - **`config/`**: Supabase, 환경 변수 등 앱의 설정을 관리하는 파일들이 있습니다.

## 주요 기능

- **사용자 인증:** 이메일, 소셜 로그인(Google, Kakao, Apple)을 지원합니다.
- **약 등록 및 관리:** 사용자가 복용 중인 약의 정보를 등록, 수정, 삭제할 수 있습니다.
- **복용 기록:** 매일 정해진 시간에 약 복용 여부를 기록하고 관리합니다.
- **복용 통계:** 월간 복용 완료율, 연속 복용일 등의 통계를 제공합니다.
- **구독 서비스:** 광고 제거, 건강 리포트 등 프리미엄 기능을 위한 구독 모델이 포함될 수 있습니다.

## 빌드 및 실행

프로젝트를 로컬 환경에서 실행하기 위한 주요 명령어는 다음과 같습니다.

1.  **종속성 설치:**
    ```bash
    flutter pub get
    ```

2.  **애플리케이션 실행:**
    ```bash
    flutter run
    ```

3.  **테스트 실행:**
    ```bash
    flutter test
    ```

4.  **빌드:**
    - **Android:**
      ```bash
      flutter build apk
      ```
    - **iOS:**
      ```bash
      flutter build ipa
      ```

## 개발 컨벤션

- **상태 관리:** `flutter_riverpod`를 사용하여 상태를 관리합니다. 새로운 기능 추가 시 관련 상태는 `providers` 디렉터리에 정의해야 합니다.
- **코드 스타일:** `flutter_lints`의 권장 규칙을 따릅니다. `analysis_options.yaml` 파일에서 규칙을 확인할 수 있습니다.
- **백엔드 통신:** Supabase와의 모든 통신은 `services/supabase_service.dart`에 정의된 메서드를 통해 이루어져야 합니다.
- **환경 변수:** API 키와 같은 민감한 정보는 `.env` 파일에 저장하고 `config/env_config.dart`를 통해 접근해야 합니다.
- **UI:** `Material Design 3`를 사용하며, 앱의 주요 색상은 `Color(0xFF4CAF50)` (녹색 계열)입니다.
