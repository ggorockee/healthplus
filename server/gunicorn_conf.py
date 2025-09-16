import os
import multiprocessing

# Server socket
bind = f"{os.getenv('HOST', '0.0.0.0')}:{os.getenv('PORT', '8000')}"
backlog = int(os.getenv('GUNICORN_BACKLOG', '2048'))

# Worker processes
workers = int(os.getenv('GUNICORN_WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = int(os.getenv('GUNICORN_WORKER_CONNECTIONS', '1000'))
max_requests = int(os.getenv('GUNICORN_MAX_REQUESTS', '1000'))
max_requests_jitter = int(os.getenv('GUNICORN_MAX_REQUESTS_JITTER', '50'))
preload_app = os.getenv('GUNICORN_PRELOAD_APP', 'true').lower() == 'true'
timeout = int(os.getenv('GUNICORN_TIMEOUT', '30'))
keepalive = int(os.getenv('GUNICORN_KEEPALIVE', '5'))

# Logging
accesslog = os.getenv('GUNICORN_ACCESS_LOG', '-')  # stdout
errorlog = os.getenv('GUNICORN_ERROR_LOG', '-')    # stderr
loglevel = os.getenv('GUNICORN_LOG_LEVEL', 'info')
access_log_format = os.getenv(
    'GUNICORN_ACCESS_LOG_FORMAT',
    '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'
)

# Process naming
proc_name = os.getenv('GUNICORN_PROC_NAME', 'healthplus')

# Server mechanics
daemon = False
pidfile = os.getenv('GUNICORN_PID_FILE', None)
user = None
group = None
tmp_upload_dir = None

# SSL (if needed)
keyfile = os.getenv('GUNICORN_KEYFILE', None)
certfile = os.getenv('GUNICORN_CERTFILE', None)

# Security
limit_request_line = int(os.getenv('GUNICORN_LIMIT_REQUEST_LINE', '4094'))
limit_request_fields = int(os.getenv('GUNICORN_LIMIT_REQUEST_FIELDS', '100'))
limit_request_field_size = int(os.getenv('GUNICORN_LIMIT_REQUEST_FIELD_SIZE', '8190'))

# Application-specific
forwarded_allow_ips = os.getenv('GUNICORN_FORWARDED_ALLOW_IPS', '*')
secure_scheme_headers = {
    'X-FORWARDED-PROTOCOL': 'ssl',
    'X-FORWARDED-PROTO': 'https',
    'X-FORWARDED-SSL': 'on'
}

def when_ready(server):
    """Called just after the server is started."""
    server.log.info("Server is ready. Spawning workers")

def worker_int(worker):
    """Called just after a worker has been interrupted."""
    worker.log.info("worker received INT or QUIT signal")

def pre_fork(server, worker):
    """Called just before a worker is forked."""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    """Called just after a worker has been forked."""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def worker_abort(worker):
    """Called when a worker receives the SIGABRT signal."""
    worker.log.info("worker received SIGABRT signal")