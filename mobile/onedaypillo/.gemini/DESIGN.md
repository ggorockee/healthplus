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

---

**사용법**: 이 프롬프트 템플릿을 참고해서 구체적이고 일관된 작업 요청을 하시면 됩니다!