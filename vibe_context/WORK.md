# CI/CD 파이프라인 개선 작업 계획서

## 1. 개요

`healthplus` 애플리케이션의 `develop` 브랜치에 새로운 코드가 푸시(Push)될 때, 자동으로 Docker 이미지를 빌드하고 Docker Hub에 푸시한 후, 해당 이미지 태그를 `infra` Git 저장소에 있는 ArgoCD 애플리케이션의 `values.yaml` 파일에 업데이트하는 CI/CD 파이프라인을 구축합니다.

## 2. 핵심 과제

`yq`와 같은 표준 YAML 처리 도구는 파일을 수정하는 과정에서 기존의 주석(Comments)을 모두 제거하는 문제가 있습니다. 이는 `values.yaml` 파일에 작성된 중요한 설명이나 히스토리를 유실시킬 수 있습니다.

따라서, **주석을 온전히 보존하면서** 특정 값(`image.tag`)만 안정적으로 수정하는 자동화 방법이 필요합니다.

## 3. 제안 해결책

주석과 원본 포맷을 유지하면서 YAML 파일을 수정하는 데 특화된 Python 라이브러리인 **`ruamel.yaml`**을 사용하는 스크립트를 작성하여 이 문제를 해결합니다.

이 방법은 `sed`와 같은 정규식(Regex) 기반의 텍스트 치환 방식보다 YAML의 구조를 정확히 이해하고 처리하므로, 파일 구조가 복잡해지더라도 훨씬 더 안정적이고 유지보수가 용이합니다.

## 4. 세부 작업 절차

### 1단계: YAML 업데이트 Python 스크립트 작성

-   **파일명**: `scripts/update_infra_values.py` (프로젝트 루트에 `scripts` 디렉터리를 생성하고 그 안에 위치시킵니다.)
-   **기능**:
    1.  스크립트 실행 시 인자(Argument)로 새로운 Docker 이미지 태그를 받습니다.
    2.  `infra` 저장소를 임시 디렉터리에 클론(Clone)합니다.
    3.  `ruamel.yaml` 라이브러리를 사용하여 `charts/argocd/applicationsets/valuefiles/dev/onedaypillo/values.yaml` 파일을 로드합니다.
    4.  로드된 YAML 데이터에서 `image.tag` 값을 전달받은 새 태그로 수정합니다.
    5.  주석과 형식을 그대로 유지한 채 변경된 내용을 동일한 파일에 다시 씁니다.
    6.  커밋 작성자(Author)를 `Github Bot`으로 설정하여, 자동화된 커밋임을 명확히 표시합니다.

### 2단계: GitHub Actions 워크플로우 수정 또는 생성

-   **파일명**: `.github/workflows/ci-server.yml` 파일을 수정하거나, `deploy-dev.yml`과 같은 새 워크플로우 파일을 생성합니다.
-   **트리거(Trigger) 설정**: `develop` 브랜치로 푸시될 때 워크플로우가 실행되도록 설정합니다.
    ```yaml
    on:
      push:
        branches:
          - develop
    ```
-   **주요 작업(Job) 단계**:
    1.  **코드 체크아웃**: `actions/checkout`을 사용하여 `healthplus` 저장소의 코드를 가져옵니다.
    2.  **Docker 이미지 태그 생성**: Git 커밋 해시(short SHA)를 사용하여 고유한 이미지 태그를 생성합니다. (예: `$(git rev-parse --short HEAD)`)
    3.  **Docker 빌드 및 푸시**: 생성된 태그로 Docker 이미지를 빌드하고, Docker Hub에 푸시합니다. (Docker Hub 자격 증명은 GitHub Secrets를 사용합니다.)
    4.  **Python 환경 설정 및 의존성 설치**:
        -   `actions/setup-python`을 사용하여 Python 환경을 설정합니다.
        -   `pip install ruamel.yaml GitPython` 명령으로 필요한 라이브러리를 설치합니다.
    5.  **`infra` 저장소 업데이트**:
        -   앞서 작성한 `scripts/update_infra_values.py` 스크립트를 실행합니다.
        -   이때, 인자로 2단계에서 생성한 Docker 이미지 태그와 `infra` 저장소에 접근하기 위한 Deploy Key(또는 PAT)를 전달합니다.
        -   스크립트 내부에서 `infra` 저장소를 클론하고, `values.yaml` 파일을 수정한 후, 변경사항을 커밋(Commit)하고 푸시(Push)합니다.

## 5. 사전 준비 사항

1.  **`infra` 저장소 접근 토큰**:
    -   `healthplus` 저장소의 `Settings > Secrets and variables > Actions`에 `INFRA_GITHUB_TOKEN` Secret이 등록되어 있습니다.
    -   이 토큰은 `infra` 저장소에 접근하여 `values.yaml` 파일을 수정하고 푸시할 권한을 가진 PAT(Personal Access Token)여야 합니다.

2.  **Docker Hub 자격 증명**:
    -   `healthplus` 저장소의 Actions Secrets에 다음과 같이 Docker Hub 자격 증명이 등록되어 있습니다.
        -   `DOCKERHUB_USERNAME`: Docker Hub 사용자 이름
        -   `DOCKERHUB_TOKEN`: Docker Hub에 로그인하기 위한 Access Token

## 6. 기대 효과

-   `develop` 브랜치의 변경사항이 배포 환경에 자동으로 반영되는 완전 자동화된 CI/CD 파이프라인이 구축됩니다.
-   수동으로 `values.yaml` 파일을 수정하는 과정에서 발생할 수 있는 실수를 방지합니다.
-   주석을 보존하여 파일의 가독성과 유지보수성을 해치지 않습니다.
