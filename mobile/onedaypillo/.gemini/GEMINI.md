# Gemini 컨텍스트: HealthPlus (onedaypillo) 모바일 앱

## 프로젝트 개요

이 프로젝트는 Flutter로 개발된 **HealthPlus (onedaypillo)** 라는 이름의 약 복용 관리 모바일 애플리케이션입니다. 사용자가 복용하는 약을 등록하고, 정해진 시간에 맞춰 복용 알림을 받으며, 복용 기록을 추적하고 통계를 확인할 수 있도록 돕습니다.

주요 기술 스택은 `pubspec.yaml` 파일과 프로젝트 구조를 통해 다음과 같이 확인되었습니다:

- **프레임워크:** Flutter
- **상태 관리:** `flutter_riverpod`
- **백엔드 및 데이터베이스:** `supabase_flutter` (주요 데이터 저장소)
- **인증:** `firebase_auth`, `supabase_flutter`를 활용한 이메일 및 소셜 로그인 (Google, Kakao, Apple)
- **광고:** `google_mobile_ads` (Google AdMob)
- **로컬 저장소:** `shared_preferences`
- **분석 및 모니터링:** Firebase (Analytics, Crashlytics, Performance, Remote Config)
- **차트/통계:** `fl_chart`

## 디렉토리 구조

주요 디렉토리 구조는 다음과 같습니다.

- **`lib/`**: 애플리케이션의 핵심 Dart 소스 코드가 위치합니다.
    - **`main.dart`**: 앱의 진입점(Entry Point)으로, 주요 서비스 초기화 및 첫 화면을 설정합니다.
    - **`screens/`**: 각 화면(UI)을 구성하는 위젯 파일들이 있습니다. (예: `home_screen.dart`, `login_screen.dart`)
    - **`providers/`**: Riverpod를 사용하여 상태를 관리하는 Provider들이 정의되어 있습니다.
    - **`models/`**: 데이터 모델 클래스(예: `Medication`, `User`)들이 정의되어 있습니다.
    - **`services/`**: Supabase, Firebase 등 외부 서비스와의 통신을 담당하는 서비스 클래스들이 있습니다.
    - **`widgets/`**: 여러 화면에서 재사용되는 공통 위젯(예: 버튼, 카드)들이 있습니다.
    - **`config/`**: 테마, 라우팅 등 앱의 설정을 관리하는 파일들이 있습니다.
- **`assets/`**: 이미지, 폰트 등 정적 리소스 파일이 위치합니다.
- **`android/`**: Android 플랫폼 관련 네이티브 코드 및 설정 파일이 있습니다.
- **`ios/`**: iOS 플랫폼 관련 네이티브 코드 및 설정 파일이 있습니다.
- **`test/`**: 단위 테스트, 위젯 테스트 등 테스트 코드가 위치합니다.
- **`pubspec.yaml`**: 프로젝트의 의존성 및 메타데이터를 정의하는 파일입니다.
- **`GEMINI.md`**: Gemini가 프로젝트를 이해하고 작업을 수행하기 위한 컨텍스트 정보를 담고 있는 파일입니다. (현재 파일)

## 주요 기능

- **사용자 인증:** 이메일, 소셜 로그인(Google, Kakao, Apple)을 지원합니다.
- **약 등록 및 관리:** 사용자가 복용 중인 약의 정보를 등록, 수정, 삭제할 수 있습니다.
- **복용 기록:** 매일 정해진 시간에 약 복용 여부를 기록하고 관리합니다.
- **복용 통계:** `fl_chart`를 사용하여 월간 복용 완료율, 연속 복용일 등의 통계를 시각적으로 제공합니다.
- **광고:** Google AdMob을 통한 배너 광고 등이 포함될 수 있습니다.

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
