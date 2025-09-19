# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Starting the Server
```bash
# Auto-setup and start (recommended)
python start.py

# Direct start with uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Production start
gunicorn -c gunicorn_conf.py main:app
```

### Testing
```bash
# Run all tests
pytest

# Run tests with verbose output
pytest -v

# Run specific test file
pytest tests/test_api.py

# Run tests with coverage
pytest --cov=app tests/
```

### Database Operations
```bash
# Reset database (development only)
python -c "import asyncio; from reset_database import reset_database; asyncio.run(reset_database())"

# Run SQL migration script
# Execute contents of database_schema.sql in your PostgreSQL/Supabase instance
```

### Environment Management
```bash
# Switch to development environment
./switch_env.sh dev

# Switch to production environment
./switch_env.sh prod

# Check current environment settings
python -c "from app.core.config import settings; print(f'Environment: {settings.APP_ENVIRONMENT}')"
```

### Docker Operations
```bash
# Build Docker image
docker build -t healthplus-api .

# Run with Docker
docker run -p 8000:8000 --env-file .env healthplus-api
```

## Architecture Overview

### Clean Architecture Pattern
The project follows Clean Architecture with clear separation of concerns:

- **`app/api/`**: HTTP layer (FastAPI routes, request/response handling)
- **`app/application/`**: Application layer (business logic, use cases, repositories)
- **`app/infrastructure/`**: Infrastructure layer (database models, external services)
- **`app/core/`**: Core utilities (config, exceptions, middleware)

### Key Architectural Decisions

**Multi-App FastAPI Structure**: Uses nested FastAPI applications for API versioning:
- Root app (`app`) handles global concerns (CORS, middleware, health)
- v1 sub-app (`v1_app`) mounted at `/v1` with API routes
- Supports `ROOT_PATH` for sub-path deployments (e.g., `/api/onedaypillo`)

**Database Architecture**:
- SQLAlchemy 2.0 with async support
- PostgreSQL primary, SQLite for testing
- Models in `app/infrastructure/database/models/`
- Repository pattern in `app/application/repositories/`

**Authentication System**:
- JWT-based with access/refresh token separation
- Social login support (Google, Facebook, Kakao) - infrastructure ready
- Middleware-based auth enforcement

### Core Components

**Configuration System** (`app/core/config.py`):
- Pydantic-based settings with environment file support
- Supports multiple environments (.env.dev, .env.prod, .env.common)
- Auto-discovery of environment variables

**Error Handling** (`app/core/exceptions.py`, `app/core/error_codes.py`):
- Standardized API error responses with error codes
- Hierarchical error code system (AUTH_*, MED_*, LOG_*, SYS_*)
- Global exception middleware

**Middleware Stack**:
- Security headers (production only)
- Request logging (debug mode)
- CORS handling
- Error handling and standardization

### Database Schema

**Core Entities**:
- `User`: Authentication and profile management
- `Medication`: Medicine information and dosing schedules
- `MedicationLog`: Consumption tracking and compliance
- `Reminder`: Notification settings and scheduling

**Key Relationships**:
- Users have many Medications (1:N)
- Medications have many MedicationLogs (1:N)
- Medications have many Reminders (1:N)
- All foreign keys use UUID references

## API Documentation

- **Swagger UI**: http://localhost:8000/v1/docs (development only)
- **ReDoc**: http://localhost:8000/v1/redoc (development only)
- **Health Check**: http://localhost:8000/health

### API Response Format
All APIs use standardized response format:

**Success Response**:
```json
{
  "success": true,
  "data": { ... },
  "message": "성공 메시지",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**Error Response**:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": "상세 정보",
    "field": "문제 필드"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Development Guidelines

### Environment Setup
1. Copy appropriate env file: `cp .env.dev .env` (for development)
2. Set required environment variables:
   - `DATABASE_URL`: PostgreSQL connection string
   - `JWT_SECRET_KEY`: JWT signing secret
3. Install dependencies: `pip install -r requirements.txt`
4. Start server: `python start.py`

### Testing Philosophy
- Use SQLite in-memory database for tests
- Async test fixtures in `tests/conftest.py`
- Test database auto-creates/drops per session
- Cover happy path, error cases, and edge conditions

### Code Organization Rules
- Follow existing import patterns in each layer
- Use repository pattern for database operations
- Keep business logic in application layer, not API routes
- Use Pydantic schemas for request/response validation
- Error handling through custom exceptions, not bare HTTP exceptions

### Security Considerations
- JWT tokens include user context and expiration
- Password hashing uses bcrypt with configurable rounds
- CORS configured for development (wildcard) and production (specific origins)
- SQL injection protection through SQLAlchemy ORM
- Input validation through Pydantic schemas

### Korean Localization
- Error messages and API responses support Korean
- Database schema comments in Korean
- Documentation mixing Korean and English (Korean for business domain, English for technical terms)