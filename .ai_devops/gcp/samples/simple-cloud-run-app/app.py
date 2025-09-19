#!/usr/bin/env python3
"""
Simple Cloud Run Application
A sample Flask application for Google Cloud Run deployment
demonstrating health checks, logging, and monitoring integration.
"""

import os
import json
import time
import logging
from datetime import datetime, timezone
from flask import Flask, request, jsonify, render_template_string
import structlog
from google.cloud import logging as cloud_logging
from google.cloud import error_reporting
from prometheus_client import Counter, Histogram, generate_latest
import requests

app = Flask(__name__)

try:
    cloud_logging_client = cloud_logging.Client()
    cloud_logging_client.setup_logging()
    cloud_error_client = error_reporting.Client()
except Exception as e:
    print(f"Warning: Could not initialize Google Cloud services: {e}")
    cloud_error_client = None

structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger(__name__)

REQUEST_COUNT = Counter('app_requests_total', 'Total number of requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration in seconds', ['method', 'endpoint'])

APPLICATION_CONFIG = {
    'name': 'simple-cloud-run-app',
    'version': '1.0.0',
    'environment': os.getenv('ENVIRONMENT', 'development'),
    'project_id': os.getenv('GOOGLE_CLOUD_PROJECT', 'unknown'),
    'region': os.getenv('GOOGLE_CLOUD_REGION', 'us-central1'),
    'port': int(os.getenv('PORT', 8080)),
    'debug': os.getenv('DEBUG', 'false').lower() == 'true',
    'log_level': os.getenv('LOG_LEVEL', 'info').upper(),
    'deployed_by': os.getenv('DEPLOYED_BY', 'manual'),
    'deployment_time': os.getenv('DEPLOYMENT_TIME', datetime.now(timezone.utc).isoformat()),
    'enable_monitoring': os.getenv('ENABLE_MONITORING', 'true').lower() == 'true'
}

app.config.update(APPLICATION_CONFIG)
app.config['DEBUG'] = APPLICATION_CONFIG['debug']

logging.basicConfig(level=getattr(logging, APPLICATION_CONFIG['log_level']))

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    if hasattr(request, 'start_time'):
        duration = time.time() - request.start_time
        REQUEST_DURATION.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown'
        ).observe(duration)
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown',
            status=response.status_code
        ).inc()
        
        logger.info(
            "Request completed",
            method=request.method,
            path=request.path,
            status_code=response.status_code,
            duration=duration,
            user_agent=request.headers.get('User-Agent', ''),
            remote_addr=request.remote_addr
        )
    
    return response

@app.errorhandler(Exception)
def handle_exception(e):
    if cloud_error_client:
        cloud_error_client.report_exception()
    
    logger.error(
        "Unhandled exception",
        exception=str(e),
        path=request.path,
        method=request.method
    )
    
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'request_id': request.headers.get('X-Request-ID', 'unknown')
    }), 500

@app.route('/')
def home():
    """Main application endpoint"""
    logger.info("Home page accessed")
    
    return jsonify({
        'message': 'Welcome to Simple Cloud Run Application',
        'application': APPLICATION_CONFIG['name'],
        'version': APPLICATION_CONFIG['version'],
        'environment': APPLICATION_CONFIG['environment'],
        'project_id': APPLICATION_CONFIG['project_id'],
        'region': APPLICATION_CONFIG['region'],
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'status': 'running'
    })

@app.route('/health')
def health():
    """Health check endpoint for Cloud Run"""
    health_status = {
        'status': 'healthy',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'application': APPLICATION_CONFIG['name'],
        'version': APPLICATION_CONFIG['version'],
        'environment': APPLICATION_CONFIG['environment'],
        'uptime_seconds': time.time() - app.start_time if hasattr(app, 'start_time') else 0,
        'checks': {
            'application': 'ok',
            'memory': 'ok',
            'disk': 'ok'
        }
    }
    
    try:
        test_response = requests.get('https://httpbin.org/status/200', timeout=5)
        health_status['checks']['external_connectivity'] = 'ok' if test_response.status_code == 200 else 'warning'
    except Exception as e:
        health_status['checks']['external_connectivity'] = 'warning'
        logger.warning("External connectivity check failed", error=str(e))
    
    logger.debug("Health check performed", status=health_status['status'])
    return jsonify(health_status)

@app.route('/startup')
def startup():
    """Startup probe endpoint for Cloud Run"""
    startup_status = {
        'status': 'ready',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'application': APPLICATION_CONFIG['name'],
        'version': APPLICATION_CONFIG['version'],
        'environment': APPLICATION_CONFIG['environment'],
        'initialization': {
            'cloud_logging': 'initialized' if 'cloud_logging_client' in globals() else 'failed',
            'error_reporting': 'initialized' if cloud_error_client else 'failed',
            'structured_logging': 'initialized',
            'metrics': 'initialized'
        }
    }
    
    logger.info("Startup probe performed", status=startup_status['status'])
    return jsonify(startup_status)

@app.route('/ready')
def ready():
    """Readiness probe endpoint"""
    readiness_status = {
        'status': 'ready',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'application': APPLICATION_CONFIG['name'],
        'version': APPLICATION_CONFIG['version'],
        'ready_to_serve': True,
        'dependencies': {
            'google_cloud_services': cloud_error_client is not None
        }
    }
    
    logger.debug("Readiness probe performed", status=readiness_status['status'])
    return jsonify(readiness_status)

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    if not APPLICATION_CONFIG['enable_monitoring']:
        return jsonify({'error': 'Monitoring disabled'}), 404
    
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

@app.route('/config')
def config():
    """Application configuration endpoint"""
    config_data = APPLICATION_CONFIG.copy()
    
    safe_config = {k: v for k, v in config_data.items() if 'password' not in k.lower() and 'secret' not in k.lower()}
    
    logger.info("Configuration accessed")
    return jsonify({
        'configuration': safe_config,
        'timestamp': datetime.now(timezone.utc).isoformat()
    })

@app.route('/info')
def info():
    """Application information and diagnostics"""
    info_data = {
        'application': {
            'name': APPLICATION_CONFIG['name'],
            'version': APPLICATION_CONFIG['version'],
            'environment': APPLICATION_CONFIG['environment'],
            'deployed_by': APPLICATION_CONFIG['deployed_by'],
            'deployment_time': APPLICATION_CONFIG['deployment_time']
        },
        'runtime': {
            'python_version': os.sys.version,
            'pid': os.getpid(),
            'uptime_seconds': time.time() - app.start_time if hasattr(app, 'start_time') else 0
        },
        'environment': {
            'project_id': APPLICATION_CONFIG['project_id'],
            'region': APPLICATION_CONFIG['region'],
            'port': APPLICATION_CONFIG['port'],
            'debug': APPLICATION_CONFIG['debug']
        },
        'google_cloud': {
            'logging_enabled': 'cloud_logging_client' in globals(),
            'error_reporting_enabled': cloud_error_client is not None,
            'monitoring_enabled': APPLICATION_CONFIG['enable_monitoring']
        },
        'timestamp': datetime.now(timezone.utc).isoformat()
    }
    
    logger.info("Application info accessed")
    return jsonify(info_data)

@app.route('/test-error')
def test_error():
    """Test endpoint to trigger error for testing error reporting"""
    if APPLICATION_CONFIG['environment'] == 'production':
        return jsonify({'error': 'Test error endpoint disabled in production'}), 403
    
    logger.warning("Test error endpoint accessed")
    raise Exception("This is a test error for Cloud Error Reporting")

@app.route('/test-log')
def test_log():
    """Test endpoint to generate different log levels"""
    if APPLICATION_CONFIG['environment'] == 'production':
        return jsonify({'error': 'Test log endpoint disabled in production'}), 403
    
    logger.debug("Debug level log message")
    logger.info("Info level log message")
    logger.warning("Warning level log message")
    logger.error("Error level log message")
    
    return jsonify({
        'message': 'Test logs generated',
        'levels': ['debug', 'info', 'warning', 'error'],
        'timestamp': datetime.now(timezone.utc).isoformat()
    })

@app.route('/dashboard')
def dashboard():
    """Simple HTML dashboard for the application"""
    dashboard_html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>{{app_name}} Dashboard</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
            .header { background: #4285f4; color: white; padding: 20px; margin: -20px -20px 20px -20px; border-radius: 8px 8px 0 0; }
            .status { padding: 10px; margin: 10px 0; border-radius: 4px; }
            .healthy { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }
            .info-card { background: #f8f9fa; padding: 15px; border-radius: 4px; border-left: 4px solid #4285f4; }
            .endpoint-list { list-style: none; padding: 0; }
            .endpoint-list li { margin: 5px 0; }
            .endpoint-list a { color: #4285f4; text-decoration: none; }
            .endpoint-list a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>{{app_name}} Dashboard</h1>
                <p>Version {{version}} | Environment: {{environment}}</p>
            </div>
            
            <div class="status healthy">
                <strong>Status:</strong> Application is running healthy
            </div>
            
            <div class="info-grid">
                <div class="info-card">
                    <h3>Application Info</h3>
                    <p><strong>Project:</strong> {{project_id}}</p>
                    <p><strong>Region:</strong> {{region}}</p>
                    <p><strong>Deployed:</strong> {{deployment_time}}</p>
                </div>
                
                <div class="info-card">
                    <h3>Available Endpoints</h3>
                    <ul class="endpoint-list">
                        <li><a href="/">/</a> - Home</li>
                        <li><a href="/health">/health</a> - Health Check</li>
                        <li><a href="/startup">/startup</a> - Startup Probe</li>
                        <li><a href="/ready">/ready</a> - Readiness Probe</li>
                        <li><a href="/config">/config</a> - Configuration</li>
                        <li><a href="/info">/info</a> - Application Info</li>
                        <li><a href="/metrics">/metrics</a> - Prometheus Metrics</li>
                    </ul>
                </div>
            </div>
            
            <div class="info-card">
                <h3>Quick Health Check</h3>
                <p id="health-status">Checking...</p>
                <button onclick="checkHealth()">Refresh Health Status</button>
            </div>
        </div>
        
        <script>
            function checkHealth() {
                fetch('/health')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('health-status').innerHTML = 
                            `Status: ${data.status} | Uptime: ${Math.round(data.uptime_seconds)}s | Last check: ${new Date().toLocaleTimeString()}`;
                    })
                    .catch(error => {
                        document.getElementById('health-status').innerHTML = 'Health check failed';
                    });
            }
            
            checkHealth();
            setInterval(checkHealth, 30000);
        </script>
    </body>
    </html>
    """
    
    return render_template_string(
        dashboard_html,
        app_name=APPLICATION_CONFIG['name'],
        version=APPLICATION_CONFIG['version'],
        environment=APPLICATION_CONFIG['environment'],
        project_id=APPLICATION_CONFIG['project_id'],
        region=APPLICATION_CONFIG['region'],
        deployment_time=APPLICATION_CONFIG['deployment_time']
    )

if __name__ == '__main__':
    app.start_time = time.time()
    
    logger.info(
        "Starting application",
        **APPLICATION_CONFIG
    )
    
    app.run(
        host='0.0.0.0',
        port=APPLICATION_CONFIG['port'],
        debug=APPLICATION_CONFIG['debug']
    )