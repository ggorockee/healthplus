#!/bin/bash

# HealthPlus 환경 전환 스크립트
# 사용법: ./switch_env.sh [development|production|staging]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 환경 검증
validate_environment() {
    local env=$1
    case $env in
        development|production|staging)
            return 0
            ;;
        *)
            print_error "지원하지 않는 환경입니다: $env"
            print_info "지원되는 환경: development, production, staging"
            exit 1
            ;;
    esac
}

# 환경 파일 존재 확인
check_env_file() {
    local env=$1
    local env_file=".env.$env"
    
    if [ ! -f "$env_file" ]; then
        print_warning "환경 파일이 존재하지 않습니다: $env_file"
        print_info "예제 파일을 복사하여 생성하시겠습니까? (y/n)"
        read -r response
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            if [ -f "env.$env.example" ]; then
                cp "env.$env.example" "$env_file"
                print_success "환경 파일이 생성되었습니다: $env_file"
                print_warning "실제 값으로 수정해주세요!"
            else
                print_error "예제 파일이 존재하지 않습니다: env.$env.example"
                exit 1
            fi
        else
            print_error "환경 파일이 필요합니다: $env_file"
            exit 1
        fi
    fi
}

# 환경 전환
switch_environment() {
    local env=$1
    
    print_info "환경을 $env로 전환합니다..."
    
    # 환경 파일 확인
    check_env_file "$env"
    
    # 환경변수 설정
    export ENVIRONMENT="$env"
    
    # 현재 환경 정보 출력
    print_success "환경이 $env로 전환되었습니다"
    print_info "현재 환경: $ENVIRONMENT"
    
    # 환경별 추가 설정
    case $env in
        development)
            print_info "개발 환경 설정:"
            print_info "  - DEBUG 모드 활성화"
            print_info "  - 상세 로깅 활성화"
            print_info "  - 테스트 데이터 포함"
            ;;
        production)
            print_info "상용 환경 설정:"
            print_info "  - DEBUG 모드 비활성화"
            print_info "  - 경고 레벨 로깅"
            print_info "  - 시스템 로그 활성화"
            ;;
        staging)
            print_info "스테이징 환경 설정:"
            print_info "  - DEBUG 모드 비활성화"
            print_info "  - 정보 레벨 로깅"
            ;;
    esac
}

# 데이터베이스 연결 테스트
test_database_connection() {
    local env=$1
    
    print_info "데이터베이스 연결을 테스트합니다..."
    
    # Python 스크립트로 연결 테스트
    python3 -c "
import os
import sys
sys.path.append('.')
os.environ['ENVIRONMENT'] = '$env'

try:
    from app.core.config import settings
    from app.core.database import SupabaseClient
    
    print(f'환경: {settings.ENVIRONMENT}')
    print(f'데이터베이스 URL: {settings.SUPABASE_URL}')
    
    # 클라이언트 초기화 테스트
    client = SupabaseClient.get_client()
    service_client = SupabaseClient.get_service_client()
    
    # 연결 테스트
    response = service_client.table('user_profiles').select('count', count='exact').execute()
    print('✅ 데이터베이스 연결 성공')
    
except Exception as e:
    print(f'❌ 데이터베이스 연결 실패: {e}')
    sys.exit(1)
"
    
    if [ $? -eq 0 ]; then
        print_success "데이터베이스 연결 테스트 성공"
    else
        print_error "데이터베이스 연결 테스트 실패"
        exit 1
    fi
}

# 메인 함수
main() {
    local env=${1:-development}
    
    print_info "HealthPlus 환경 전환 스크립트"
    print_info "================================"
    
    # 환경 검증
    validate_environment "$env"
    
    # 환경 전환
    switch_environment "$env"
    
    # 데이터베이스 연결 테스트
    test_database_connection "$env"
    
    print_success "환경 전환이 완료되었습니다!"
    print_info "서버를 시작하려면: python main.py"
}

# 스크립트 실행
main "$@"
