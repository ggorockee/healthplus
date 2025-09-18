# HealthPlus 디자인 시스템 작업 프롬프트

## 🎯 기본 작업 요청 템플릿

### 1. Figma 디자인 분석 및 구현
```
"Figma 프레임 [프레임명]을 분석해서 Flutter 컴포넌트로 구현해줘.
- 기존 lib/config/theme.dart의 AppColors, AppTypography 사용
- lib/widgets/의 AppButton, AppCard 등 공용 위젯 활용
- 디자인 토큰을 JSON으로 추출해서 design-tokens.json에 저장
- 구현한 컴포넌트는 lib/widgets/에 저장"
```

### 2. 디자인 토큰 추출
```
"현재 연결된 Figma 문서에서 디자인 토큰을 JSON 형태로 추출해줘.
- 색상 팔레트 (primary, secondary, accent 등)
- 타이포그래피 (폰트 크기, 가중치, 라인 높이)
- 간격, 둥근 모서리, 그림자 값
- design-tokens.json 파일로 저장"
```

### 3. 컴포넌트 변형 생성
```
"기존 [컴포넌트명]에 새로운 변형을 추가해줘.
- 예: AppButton에 'ghost', 'icon' 변형 추가
- JSON 토큰 기반으로 구현
- 기존 디자인 시스템과 일관성 유지"
```

### 4. 크로스 플랫폼 변환
```
"JSON 디자인 토큰을 [플랫폼]용 코드로 변환해줘.
- Flutter: lib/config/tokens.dart
- Web: CSS 변수
- React: TypeScript 상수"
```

## 📋 구체적인 요청 예시

### 예시 1: 버튼 컴포넌트 구현
```
"Figma의 'sign in' 프레임에서 버튼 디자인을 분석해서 AppButton에 새로운 변형을 추가해줘.
- 기존 primary, outline 변형 외에 새로운 스타일 추가
- JSON 토큰으로 정의해서 재사용 가능하게 만들어줘"
```

### 예시 2: 카드 컴포넌트 확장
```
"Figma의 'home' 프레임에서 카드 디자인을 보고 AppCard 컴포넌트를 확장해줘.
- 새로운 elevation, border 스타일 추가
- design-tokens.json에 카드 관련 토큰 정의"
```

### 예시 3: 전체 디자인 시스템 업데이트
```
"Figma 문서 전체를 분석해서 현재 Flutter 디자인 시스템을 업데이트해줘.
- 새로운 색상, 타이포그래피 토큰 추출
- 기존 컴포넌트들과 매핑
- JSON 토큰 파일 생성"
```

## 🔧 작업 순서 가이드

1. **Figma 연결 확인**: "현재 Figma 연결 상태 확인해줘"
2. **디자인 분석**: "Figma 프레임 [이름] 분석해줘"
3. **토큰 추출**: "디자인 토큰을 JSON으로 추출해줘"
4. **Flutter 구현**: "토큰을 기반으로 Flutter 컴포넌트 구현해줘"
5. **검증**: "구현된 컴포넌트가 디자인과 일치하는지 확인해줘"

## ✅ 체크리스트

작업 완료 후 확인사항:
- [ ] JSON 토큰 파일 생성됨
- [ ] Flutter 컴포넌트 구현됨
- [ ] 기존 디자인 시스템과 일관성 유지
- [ ] 다른 플랫폼 변환 가능한 구조
- [ ] Git 커밋 완료

## 📝 현재 연결된 Figma 프레임 목록

```
- home
- Meditate v2
- COURSE Details
- choose topic
- Reminders
- welcome
- sign in
- sign up
- sign up and Sign in
- music V2
- sleep
- play option
- music
- welcome sleep
- sleep music
```

## 🎨 분석된 디자인 토큰 (Figma 기반)

### 색상 팔레트
```json
{
  "primary": "#8e97fd",      // 메인 보라색
  "secondary": "#7583ca",    // 페이스북 버튼 색상
  "accent": "#3f414e",       // 다크 텍스트
  "surface": "#ffffff",      // 배경색
  "surfaceAlt": "#f2f3f7",   // 입력 필드 배경
  "textPrimary": "#3f414e",  // 주요 텍스트
  "textSecondary": "#a1a4b2", // 보조 텍스트
  "textOnPrimary": "#f6f1fb", // 버튼 내 텍스트
  "border": "#ebeaec",       // 테두리 색상
  "borderLight": "#e6e6e6"   // 라이트 테두리
}
```

### 타이포그래피
```json
{
  "fontFamily": "HelveticaNeue",
  "displayLarge": {
    "fontSize": 30,
    "fontWeight": 700,
    "lineHeight": 41.13,
    "letterSpacing": 0.3
  },
  "headlineSmall": {
    "fontSize": 28,
    "fontWeight": 700,
    "lineHeight": 37.8
  },
  "titleLarge": {
    "fontSize": 18,
    "fontWeight": 700,
    "lineHeight": 19.46
  },
  "bodyMedium": {
    "fontSize": 16,
    "fontWeight": 300,
    "lineHeight": 17.3,
    "letterSpacing": 0.8
  },
  "labelMedium": {
    "fontSize": 14,
    "fontWeight": 400,
    "lineHeight": 15.13,
    "letterSpacing": 0.7
  },
  "labelSmall": {
    "fontSize": 12,
    "fontWeight": 400,
    "lineHeight": 12.97,
    "letterSpacing": 0.6
  }
}
```

### 간격 및 둥근 모서리
```json
{
  "spacing": {
    "x1": 8,
    "x2": 16,
    "x3": 24,
    "x4": 32,
    "x5": 40,
    "x6": 48
  },
  "radius": {
    "sm": 10,
    "md": 15,
    "lg": 38,
    "full": 9999
  },
  "elevation": {
    "none": 0,
    "sm": 2,
    "md": 4
  }
}
```

### 컴포넌트별 토큰

#### 버튼 (Button)
```json
{
  "button": {
    "primary": {
      "backgroundColor": "#8e97fd",
      "textColor": "#f6f1fb",
      "borderRadius": 38,
      "padding": "0 24px",
      "height": 63,
      "fontSize": 14,
      "fontWeight": 400,
      "letterSpacing": 0.7
    },
    "outline": {
      "backgroundColor": "transparent",
      "textColor": "#3f414e",
      "borderColor": "#ebeaec",
      "borderRadius": 38,
      "padding": "0 24px",
      "height": 63
    },
    "social": {
      "facebook": {
        "backgroundColor": "#7583ca",
        "textColor": "#f6f1fb"
      },
      "google": {
        "backgroundColor": "transparent",
        "textColor": "#3f414e",
        "borderColor": "#ebeaec"
      }
    }
  }
}
```

#### 입력 필드 (Input)
```json
{
  "input": {
    "default": {
      "backgroundColor": "#f2f3f7",
      "textColor": "#3f414e",
      "placeholderColor": "#a1a4b2",
      "borderRadius": 15,
      "padding": "18px 16px",
      "height": 63,
      "fontSize": 16,
      "fontWeight": 300,
      "letterSpacing": 0.8
    }
  }
}
```

#### 카드 (Card)
```json
{
  "card": {
    "default": {
      "backgroundColor": "#ffffff",
      "borderRadius": 10,
      "elevation": 0,
      "padding": "16px"
    },
    "meditation": {
      "backgroundColor": "#8e97fd",
      "borderRadius": 10,
      "height": 210
    },
    "relaxation": {
      "backgroundColor": "#ffc97e",
      "borderRadius": 10,
      "height": 210
    },
    "focus": {
      "backgroundColor": "#afdbc5",
      "borderRadius": 10,
      "height": 113
    }
  }
}
```

## 🚀 실제 구현 예시

### 1. 홈 화면 구현
```
"Figma의 'home' 프레임을 분석해서 홈 화면을 구현해줘.
- 상단 인사말 섹션 (Good Morning, Afsar)
- 추천 카드 섹션 (Basics, Relaxation)
- 일일 명상 카드
- 하단 네비게이션 바
- design-tokens.json에 홈 화면 관련 토큰 정의"
```

### 2. 로그인 화면 구현
```
"Figma의 'sign in' 프레임을 분석해서 로그인 화면을 구현해줘.
- 소셜 로그인 버튼 (Google, Facebook)
- 이메일/패스워드 입력 필드
- 로그인 버튼
- 비밀번호 찾기 링크
- 회원가입 링크"
```

### 3. 웰컴 화면 구현
```
"Figma의 'welcome' 프레임을 분석해서 온보딩 화면을 구현해줘.
- 브랜드 로고 및 타이틀
- 환영 메시지
- 설명 텍스트
- 원형 배경 요소들
- 시작하기 버튼"
```

## 🔄 JSON 토큰 활용 워크플로우

1. **Figma → JSON**: 디자인 토큰을 JSON으로 추출
2. **JSON → Flutter**: `lib/config/tokens.dart`로 변환
3. **Flutter → 컴포넌트**: 공용 위젯에 토큰 적용
4. **컴포넌트 → 화면**: 실제 화면에서 사용
5. **검증**: 디자인 일치성 확인

---

**사용법**: 이 프롬프트 템플릿을 참고해서 구체적이고 일관된 작업 요청을 하시면 됩니다!