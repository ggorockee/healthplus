# GitHub Actions CI Workflow 생성 요청

## 목표
`ggorockee/healthplus` GitHub 리포지토리를 위한 CI(Continuous Integration) 워크플로우를 생성합니다. 이 워크플로우는 `server` 디렉토리의 코드가 변경될 때마다 Docker 이미지를 빌드하고 Docker Hub에 푸시하는 작업을 자동화합니다.

## 워크플로우 요구사항

### 1. 트리거 조건
- **이벤트**: `push`
- **브랜치**: `main` 브랜치에 푸시될 때만 워크플로우를 실행합니다.
- **경로 필터링**: 변경 사항이 `server/` 디렉토리 내의 파일에 발생했을 때만 워크플로우가 동작해야 합니다. 워크플로우 파일 자체(`.github/workflows/`)가 변경될 때도 실행되도록 포함합니다.

### 2. 필요한 시크릿 (Secrets)
워크플로우는 다음 GitHub Secrets에 접근할 수 있어야 합니다.
- `DOCKERHUB_USERNAME`: Docker Hub 사용자 이름
- `DOCKERHUB_TOKEN`: Docker Hub 액세스 토큰
- `INFRA_GITHUB_TOKEN`: (선택 사항) 추후 인프라 저장소에 접근하여 매니페스트를 업데이트할 때 필요할 수 있습니다.

### 3. 주요 작업 (Jobs)

#### **Job 1: 변경 사항 감지 (Detect Changes)**
- `server/` 디렉토리에 실제 변경이 있었는지 확인하는 작업을 가장 먼저 수행합니다.
- 변경이 감지된 경우에만 후속 빌드 작업을 진행하여 불필요한 리소스 사용을 방지합니다.

#### **Job 2: Docker 이미지 빌드 및 푸시 (Build and Push)**
- 이 작업은 '변경 사항 감지' 작업의 결과, `server` 디렉토리에 변경이 확인된 경우에만 실행됩니다.
- **단계 (Steps):**
    1.  **저장소 코드 체크아웃**: `actions/checkout@v4`를 사용하여 코드를 가져옵니다.
    2.  **Docker Hub 로그인**: `docker/login-action@v3`를 사용하여 `DOCKERHUB_USERNAME`과 `DOCKERHUB_TOKEN` 시크릿으로 Docker Hub에 로그인합니다.
    3.  **이미지 태그 생성**: 이미지에 고유한 태그를 동적으로 생성합니다. 태그 형식은 **`{현재날짜}-{git-commit-short-sha}`** (예: `20250917-a1b2c3d`)로 합니다.
    4.  **Docker 이미지 빌드 및 푸시**:
        - `docker/build-push-action@v5`를 사용합니다.
        - **빌드 컨텍스트(Context)**: `./server` 디렉토리를 사용합니다.
        - **푸시(Push)**: `true`로 설정하여 빌드 후 이미지를 Docker Hub에 푸시합니다.
        - **이미지 이름 및 태그**: `[DOCKERHUB_USERNAME]/healthplus-server:[생성된-태그]` 형식으로 푸시합니다. (예: `ggorockee/healthplus-server:20250917-a1b2c3d`)

### 4. 개발/운영 빌드 구성 방안 (추천)
- `server/Dockerfile` 내에서 `ARG`를 사용하여 빌드 환경(예: `BUILD_MODE`)을 변수로 받도록 설정합니다.
- GitHub Actions 워크플로우의 `docker/build-push-action` 단계에서 `with.build-args`를 통해 이 변수 값을 전달할 수 있습니다.
- **예시**:
  ```yaml
  # Dockerfile 내
  ARG BUILD_MODE=production
  ENV APP_ENV=${BUILD_MODE}
  # ... 이후 ENV 값에 따라 다른 설정 적용

  # workflow.yml 내
  - name: Build and push Docker image
    uses: docker/build-push-action@v5
    with:
      # ...
      build-args: |
        BUILD_MODE=production # 또는 development