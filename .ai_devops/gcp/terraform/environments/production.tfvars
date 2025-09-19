# Production Environment Configuration
# AI DevOps Framework v3.7 - GCP Cloud Run

# Basic Configuration
environment = "production"
region      = "us-central1"

# Cloud Run Service Configuration
cpu_limit     = "2"
memory_limit  = "2Gi"
min_instances = 1
max_instances = 100
concurrency   = 100
timeout       = 900

# Environment Variables
environment_variables = {
  "DEBUG"                = "false"
  "LOG_LEVEL"           = "warn"
  "ENABLE_PROFILING"    = "false"
  "ENABLE_MONITORING"   = "true"
  "DATABASE_POOL_SIZE"  = "20"
  "CACHE_TTL_SECONDS"   = "3600"
  "HEALTH_CHECK_GRACE"  = "30"
  "REQUEST_TIMEOUT"     = "60"
}

# Security Configuration
allow_unauthenticated = false
ingress_settings     = "internal-and-cloud-load-balancing"

# Networking (Enable VPC for production)
enable_vpc             = true
vpc_cidr_range        = "10.1.0.0/16"
private_subnet_cidr   = "10.1.1.0/24"
connector_cidr_range  = "10.1.2.0/28"

# Cloud Build Configuration
build_timeout      = "1200s"
build_machine_type = "e2-standard-4"
branch_pattern     = "^main$"

build_env_vars = {
  "ENVIRONMENT" = "production"
  "BUILD_TYPE"  = "release"
  "OPTIMIZE"    = "true"
}

# Monitoring Configuration
create_monitoring_dashboard = true

alert_policies = [
  {
    display_name = "Critical Error Rate - Production"
    combiner     = "OR"
    conditions = [
      {
        display_name = "Error rate > 1%"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 0.01
        duration     = "60s"
      }
    ]
  },
  {
    display_name = "High Latency - Production"
    combiner     = "OR"
    conditions = [
      {
        display_name = "95th percentile > 1s"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 1000
        duration     = "120s"
      }
    ]
  },
  {
    display_name = "Service Down - Production"
    combiner     = "OR"
    conditions = [
      {
        display_name = "Service availability < 99.9%"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_LESS_THAN"
        threshold    = 0.999
        duration     = "180s"
      }
    ]
  },
  {
    display_name = "High CPU Usage - Production"
    combiner     = "OR"
    conditions = [
      {
        display_name = "CPU utilization > 80%"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 0.8
        duration     = "300s"
      }
    ]
  },
  {
    display_name = "High Memory Usage - Production"
    combiner     = "OR"
    conditions = [
      {
        display_name = "Memory utilization > 85%"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 0.85
        duration     = "300s"
      }
    ]
  }
]

# Logging Configuration
log_retention_days = 90

log_sinks = [
  {
    name                   = "production-errors"
    destination           = "logging.googleapis.com/projects/${var.project_id}/logs/production-errors"
    filter                = "severity >= ERROR"
    unique_writer_identity = true
  },
  {
    name                   = "production-audit"
    destination           = "logging.googleapis.com/projects/${var.project_id}/logs/production-audit"
    filter                = "protoPayload.serviceName=\"run.googleapis.com\""
    unique_writer_identity = true
  },
  {
    name                   = "production-security"
    destination           = "logging.googleapis.com/projects/${var.project_id}/logs/production-security"
    filter                = "protoPayload.authenticationInfo.principalEmail!=\"\" OR labels.security_event=\"true\""
    unique_writer_identity = true
  }
]

# Security Configuration
enable_binary_authorization     = true
enable_vulnerability_scanning   = true
binary_auth_policy             = "production-policy"

# Labels
additional_labels = {
  "cost-center"    = "production"
  "team"           = "sre"
  "criticality"    = "high"
  "backup-policy"  = "enterprise"
  "compliance"     = "required"
  "sla"           = "99.9"
}