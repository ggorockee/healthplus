# HealthPlus Helm Chart

HealthPlus 약물 관리 애플리케이션을 Kubernetes에 배포하기 위한 Helm Chart입니다.

## 소개

이 Helm Chart는 개발(Development) 및 운영(Production) 환경 모두에서 사용할 수 있는 범용 배포 차트입니다. `values.yaml`의 `environmentType` 설정을 통해 환경별 특성에 맞는 설정을 자동으로 적용합니다.

## 주요 기능

- ✅ **환경별 설정 분리**: `environmentType`을 통한 개발/운영 환경 구분
- ✅ **Fluent-bit 연동**: 로그 수집을 위한 사용자 정의 레이블 지원
- ✅ **자동 스케일링**: 환경별 Replica 수 자동 조정
- ✅ **리소스 관리**: 환경별 CPU/메모리 제한 설정
- ✅ **Health Check**: Liveness/Readiness Probe 지원
- ✅ **보안**: Non-root 사용자 실행 및 보안 컨텍스트 적용

## 사전 요구사항

- Kubernetes 1.19+
- Helm 3.0+
- Docker 이미지가 레지스트리에 push된 상태

## 설치 방법

### 1. 차트 다운로드
```bash
git clone <repository-url>
cd healthplus/server/charts/healthplus
```

### 2. 운영 환경 배포
```bash
helm install healthplus-prod . \
  --set environmentType=production \
  --set image.repository=your-registry/healthplus \
  --set image.tag=v1.0.0 \
  --namespace healthplus-prod \
  --create-namespace
```

### 3. 개발 환경 배포
```bash
helm install healthplus-dev . \
  --set environmentType=development \
  --set image.repository=your-registry/healthplus \
  --set image.tag=latest \
  --namespace healthplus-dev \
  --create-namespace
```

### 4. 사용자 정의 values.yaml 사용
```bash
# custom-values.yaml 파일 생성 후
helm install healthplus-prod . -f custom-values.yaml
```

## 환경별 설정

### Production (운영 환경)
- **Replica Count**: 2
- **Resources**: CPU 250m-500m, Memory 256Mi-512Mi
- **Log Level**: info
- **Gunicorn Workers**: 4
- **Health Check**: 엄격한 설정

### Development (개발 환경)
- **Replica Count**: 1
- **Resources**: 제한 없음
- **Log Level**: debug
- **Gunicorn Workers**: 1
- **Health Check**: 관대한 설정

## 주요 설정 옵션

### 이미지 설정
```yaml
image:
  repository: healthplus
  pullPolicy: IfNotPresent
  tag: "latest"
```

### 서비스 설정
```yaml
service:
  type: ClusterIP
  port: 80
  targetPort: 8000
```

### Fluent-bit 로그 수집 설정
```yaml
podExtraLabels:
  logging: "fluent-bit"
  app-group: "healthplus-backend"
  tier: "backend"
```

## Secret 관리

Secret은 Helm Chart에서 직접 생성하지 않으며, 배포 전에 수동으로 생성해야 합니다:

```bash
kubectl create secret generic healthplus-secrets \
  --from-literal=SUPABASE_URL="..." \
  --from-literal=SUPABASE_ANON_KEY="..." \
  --from-literal=SUPABASE_SERVICE_ROLE_KEY="..." \
  --from-literal=JWT_SECRET="..." \
  --from-literal=REDIS_URL="..." \
  --namespace your-namespace
```

## 업그레이드

```bash
helm upgrade healthplus-prod . \
  --set image.tag=v1.1.0 \
  --namespace healthplus-prod
```

## 제거

```bash
helm uninstall healthplus-prod --namespace healthplus-prod
```

## 모니터링

### Health Check 엔드포인트
- **URL**: `/health`
- **응답**: `{"status": "healthy", "message": "HealthPlus API is running"}`

### 로그 수집
Pod에 설정된 `podExtraLabels`를 통해 Fluent-bit가 자동으로 로그를 수집합니다:
- `logging: "fluent-bit"`
- `app-group: "healthplus-backend"`

## 문제 해결

### Pod가 시작되지 않는 경우
```bash
kubectl describe pod -l app.kubernetes.io/name=healthplus -n your-namespace
kubectl logs -l app.kubernetes.io/name=healthplus -n your-namespace
```

### ConfigMap 확인
```bash
kubectl get configmap healthplus-config -o yaml -n your-namespace
```

### 서비스 연결 확인
```bash
kubectl port-forward svc/healthplus 8080:80 -n your-namespace
curl http://localhost:8080/health
```

## 라이센스

이 프로젝트는 MIT 라이센스 하에 있습니다.