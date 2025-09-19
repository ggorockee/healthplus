import os
import sys
import pytest
from dotenv import load_dotenv

def main():
    # 프로젝트 루트를 Python 경로에 추가
    project_root = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, project_root)

    # .env.dev 파일 로드
    dotenv_path = os.path.join(project_root, '.env.dev')
    load_dotenv(dotenv_path=dotenv_path)

    # pytest 실행
    sys.exit(pytest.main())

if __name__ == "__main__":
    main()
