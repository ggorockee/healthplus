#!/usr/bin/env python3
"""
HealthPlus FastAPI Server 시작 스크립트
"""

import asyncio
import subprocess
import sys
import os
from pathlib import Path


def check_python_version():
    """Python 버전 확인"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8 이상이 필요합니다.")
        sys.exit(1)
    print(f"✅ Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")


def install_dependencies():
    """의존성 설치"""
    print("📦 의존성을 설치하고 있습니다...")
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        print("✅ 의존성 설치 완료")
    except subprocess.CalledProcessError:
        print("❌ 의존성 설치 실패")
        sys.exit(1)


def check_env_file():
    """환경 변수 파일 확인"""
    env_file = Path(".env")
    if not env_file.exists():
        print("❌ .env 파일이 없습니다.")
        print("💡 .env.example 파일을 참고하여 .env 파일을 생성해주세요.")
        sys.exit(1)
    print("✅ .env 파일 확인됨")


def start_server():
    """서버 시작"""
    print("🚀 HealthPlus API 서버를 시작합니다...")
    print("📍 API 문서: http://localhost:8000/api/v1/docs")
    print("📍 ReDoc: http://localhost:8000/api/v1/redoc")
    print("📍 헬스체크: http://localhost:8000/health")
    print("-" * 50)

    try:
        subprocess.run([
            sys.executable, "-m", "uvicorn",
            "main:app",
            "--host", "0.0.0.0",
            "--port", "8000",
            "--reload",
            "--log-level", "info"
        ], check=True)
    except KeyboardInterrupt:
        print("\n⛔ 서버가 종료되었습니다.")
    except subprocess.CalledProcessError:
        print("❌ 서버 시작 실패")
        sys.exit(1)


def main():
    """메인 함수"""
    print("=" * 50)
    print("🏥 HealthPlus API Server")
    print("=" * 50)

    # 1. Python 버전 확인
    check_python_version()

    # 2. 환경 변수 파일 확인
    check_env_file()

    # 3. 의존성 설치
    install_dependencies()

    # 4. 서버 시작
    start_server()


if __name__ == "__main__":
    main()