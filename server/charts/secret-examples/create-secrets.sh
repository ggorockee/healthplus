#!/bin/bash

# HealthPlus Secret 생성 스크립트
# 사용법: ./create-secrets.sh [development|production] [namespace]

set -e

ENVIRONMENT=${1:-development}
NAMESPACE=${2}

if [ "$ENVIRONMENT" != "development" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "❌ 오류: 환경은 'development' 또는 'production'이어야 합니다."
    echo "사용법: $0 [development|production] [namespace]"
    exit 1
fi

if [ -z "$NAMESPACE" ]; then
    echo "❌ 오류: 네임스페이스를 지정해주세요."
    echo "사용법: $0 [development|production] [namespace]"
    echo "예시: $0 development my-release-namespace"
    echo "예시: $0 production healthplus-production"
    exit 1
fi

echo "🔐 $ENVIRONMENT 환경용 Secret을 '$NAMESPACE' 네임스페이스에 생성 중..."

if [ "$ENVIRONMENT" = "development" ]; then
    SUPABASE_URL="https://yjkfjytsfnpkahuiajjv.supabase.co"
    SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlqa2ZqeXRzZm5wa2FodWlhamp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NDQwNjIsImV4cCI6MjA3MzUyMDA2Mn0.3HpbNmM3jD5jy-B38KghXwKJwJe2ZMACxAsdHGluRxM"
    SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlqa2ZqeXRzZm5wa2FodWlhamp2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzk0NDA2MiwiZXhwIjoyMDczNTIwMDYyfQ.IWTt0M59NpTxCFMb7G4cvQaNeDuemuR_GT82-MGsHYg=="
    JWT_SECRET="144X+RuI10Spg9XCSHlmTeEPYikepKkQaCeXgVoKIjBtT3HeTBpvL5un5PK2suLggWFSJQGFjRt69Sg9f9Pw5A=="
    REDIS_URL="redis://localhost:6379"
else
    SUPABASE_URL="https://uabrhzqtxxbhvxgwpaki.supabase.co"
    SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhYnJoenF0eHhiaHZ4Z3dwYWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5ODYyMDEsImV4cCI6MjA3MzU2MjIwMX0.iHBCjCi12tKx4P_mj6t5-uKYmXoq5vLe33j9ADWAFyM"
    SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhYnJoenF0eHhiaHZ4Z3dwYWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzk4NjIwMSwiZXhwIjoyMDczNTYyMjAxfQ.ZbPz4dst_5rUnMDN9m3yY2gqn8QxaC4P3o_JPZREEHc"
    JWT_SECRET="Ol27qZlTCWqK+8LhMEm2JGT7FHBAvSqhSXpX1xFRUQFNGo30tHItlioCJxpao3jzB0OsroOx4VPThSsfBULcIw=="
    REDIS_URL="redis://production-redis-url:6379"
fi

# 네임스페이스 생성 (존재하지 않는 경우)
echo "📁 네임스페이스 '$NAMESPACE' 확인 중..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 기존 Secret 삭제 (존재하는 경우)
if kubectl get secret healthplus-secrets -n $NAMESPACE > /dev/null 2>&1; then
    echo "🗑️  기존 Secret 삭제 중..."
    kubectl delete secret healthplus-secrets -n $NAMESPACE
fi

# Secret 생성
echo "✨ Secret 생성 중..."
kubectl create secret generic healthplus-secrets \
    --from-literal=SUPABASE_URL="$SUPABASE_URL" \
    --from-literal=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    --from-literal=SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY" \
    --from-literal=JWT_SECRET="$JWT_SECRET" \
    --from-literal=REDIS_URL="$REDIS_URL" \
    --namespace=$NAMESPACE

# 레이블 추가
echo "🏷️  레이블 추가 중..."
kubectl label secret healthplus-secrets \
    app.kubernetes.io/name=healthplus \
    app.kubernetes.io/instance=healthplus-$ENVIRONMENT \
    environment=$ENVIRONMENT \
    --namespace=$NAMESPACE

echo "✅ $ENVIRONMENT 환경용 Secret이 성공적으로 생성되었습니다!"
echo "🔍 확인: kubectl get secret healthplus-secrets -n $NAMESPACE -o yaml"

# Secret 내용 확인 (마스킹된 형태로)
echo ""
echo "📋 생성된 Secret 정보:"
kubectl get secret healthplus-secrets -n $NAMESPACE -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,KEYS:.data --no-headers | \
    awk '{print "Name: " $1 "\nNamespace: " $2 "\nKeys: " $3}'