# HealthPlus 개발 실행 계획 (v2)

이 문서는 프로젝트 목표를 달성하기 위한 고도화된 실행 계획입니다. 작업은 Epic(대규모 목표), Feature(기능 단위), Task(개별 작업)로 구조화됩니다.

---

## Epic 1: Foundational Setup (완료)

**목표:** 개발, 스테이징, 운영 환경을 분리하여 안정적인 개발 및 배포 파이프라인의 기반을 마련합니다.

- **Feature: 환경 변수 관리**
  - **Task:** `flutter_dotenv` 의존성 추가.
  - **Task:** 환경별 `.env` 파일(`.common`, `.dev`, `.prod`) 생성.
  - **Task:** `pubspec.yaml`에 `.env` 파일 에셋 등록.
  - **Task:** 빌드 모드에 따른 환경 변수 로드 로직 구현 (`main.dart`).
  - **Task:** 환경 변수 접근을 위한 설정 클래스(`EnvConfig`) 생성.
  - **Task:** 코드 내 하드코딩된 값을 환경 변수로 대체.

---

## Epic 2: Monetization & User Insights

**목표:** 광고를 통해 수익 모델을 구축하고, 사용자 행동 분석을 통해 데이터 기반 의사결정의 기틀을 마련합니다.

- **Feature: 광고 기능 (AdMob)**
  - **Task:** `main.dart`에서 AdMob SDK 초기화.
  - **Task:** 배너 광고의 상태(로딩, 성공, 실패)를 관리하는 `admob_provider` 구현.
  - **Task:** 재사용 가능한 `BannerAdWidget` 공통 위젯 생성.
  - **Task:** 홈 화면 등 주요 화면에 배너 광고 위젯 통합.

- **Feature: 사용자 행동 분석 (Firebase Analytics)**
  - **Task:** `FirebaseAnalytics`를 래핑하여 표준 로깅 메서드(`logScreenView`, `logEvent`)를 제공하는 `AnalyticsService` 클래스 생성.
  - **Task:** 각 화면 진입 시 `logScreenView`를 호출하여 화면 조회 이벤트 기록.
  - **Task:** 회원가입, 로그인, 약 추가 등 핵심 사용자 행동에 `logEvent`를 호출하여 맞춤 이벤트 기록.

---

## Epic 3: Quality & Reliability

**목표:** 앱의 성능, 안정성, 코드 품질을 향상시켜 사용자 경험을 극대화하고 유지보수 효율성을 높입니다.

- **Feature: 앱 성능 최적화**
  - **Task:** `main.dart`의 초기화 로직을 분석하여 지연 로딩을 적용하고 앱 시작 시간 단축.
  - **Task:** Flutter DevTools를 사용하여 위젯 리빌드를 프로파일링하고, `const`, `select` 등을 활용하여 불필요한 렌더링 최소화.
  - **Task:** 이미지 리소스 크기 최적화 및 캐시 전략 수립을 통한 메모리 사용량 개선.
  - **Task:** `flutter build --analyze-size`를 활용하여 앱 번들 크기를 분석하고, 불필요한 에셋 및 패키지 제거.

- **Feature: E2E (End-to-End) 테스트**
  - **Task:** `flutter_driver` 및 `test` 의존성을 설정하고 `test_driver` 디렉토리 구조 생성.
  - **Task:** 인증(회원가입, 로그인, 로그아웃) 플로우에 대한 E2E 테스트 스크립트 작성.
  - **Task:** 핵심 기능(약 추가/복용/삭제) 플로우에 대한 E2E 테스트 스크립트 작성.
  - **Task:** 하단 네비게이션을 통한 화면 이동 E2E 테스트 스크립트 작성.

---

## Epic 4: Core User Experience

**목표:** 사용자가 앱의 핵심 가치를 원활하게 경험할 수 있도록 주요 기능을 구현하고 개선합니다.

- **Feature: 통합 인증 (Unified Authentication) - UI Mockup**
  **목표:** `@.gemini/DESIGN.md` 디자인 시스템 명세에 따라, 실제 기능 연동 전 회원가입 화면의 UI를 먼저 구현합니다.

  - **Task:** 신규 회원가입 화면 `signup_screen.dart` 파일 생성 및 기본 레이아웃 설정.
  - **Task:** `@.gemini/DESIGN.md`의 `sign up` 프레임과 디자인 토큰을 준수하여 이메일/비밀번호 입력 필드 UI 구현.
  - **Task:** `@.gemini/DESIGN.md`의 `social` 버튼 토큰을 기반으로 Google, Kakao, Apple 소셜 로그인 버튼 UI 컴포넌트 구현.
  - **Task:** 구현된 UI 컴포넌트들을 `signup_screen.dart`에 배치하여 전체 회원가입 Mockup 화면 완성.
  - **Task:** 기존 `login_screen.dart`에 회원가입 화면으로 이동하는 네비게이션 링크 UI 추가.
  - **Task:** 실제 인증 로직 연동은 다음 단계로 명시하며, 현재는 UI 상호작용만 가능하도록 버튼의 `onPressed`는 비워둡니다.

---

## Project Governance

**목표:** 일관성 있고 효율적인 개발 문화를 정착시킵니다.

- **Rule:** **API 개발 프로토콜:** 신규 API 또는 변경이 필요할 경우, 백엔드 개발자와 요구사항을 먼저 논의하고 확정한 후 개발을 시작합니다.
- **Rule:** **UI/UX 구현 프로토콜:** 모든 UI 컴포넌트는 `@.gemini/DESIGN.md`의 명세를 따릅니다. 명세에 없는 컴포넌트는 임의로 만들지 않고, `DESIGN.md`에 명세를 추가한 후 구현합니다.