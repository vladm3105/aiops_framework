# Development Environment Configuration
# AI DevOps Framework v3.7 - GCP Cloud Run

# Basic Configuration
environment = "development"
region      = "us-central1"

# Cloud Run Service Configuration
cpu_limit     = "1"
memory_limit  = "512Mi"
min_instances = 0
max_instances = 10
concurrency   = 10
timeout       = 300

# Environment Variables
environment_variables = {
  "DEBUG"                = "true"
  "LOG_LEVEL"           = "debug"
  "ENABLE_PROFILING"    = "true"
  "ENABLE_MONITORING"   = "true"
  "DATABASE_POOL_SIZE"  = "5"
  "CACHE_TTL_SECONDS"   = "300"
}

# Security Configuration
allow_unauthenticated = true
ingress_settings     = "all"

# Networking
enable_vpc          = false
vpc_connector_name  = ""

# Cloud Build Configuration
build_timeout      = "600s"
build_machine_type = "e2-standard-2"
branch_pattern     = "^(main|develop|feature/.*)$"

build_env_vars = {
  "ENVIRONMENT" = "development"
  "BUILD_TYPE"  = "debug"
}

# Monitoring Configuration
create_monitoring_dashboard = true

alert_policies = [
  {
    display_name = "High Error Rate - Development"
    combiner     = "OR"
    conditions = [
      {
        display_name = "Error rate > 5%"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 0.05
        duration     = "300s"
      }
    ]
  },
  {
    display_name = "High Latency - Development"
    combiner     = "OR"
    conditions = [
      {
        display_name = "Response time > 2s"
        filter       = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""
        comparison   = "COMPARISON_GREATER_THAN"
        threshold    = 2000
        duration     = "180s"
      }
    ]
  }
]

# Logging Configuration
log_retention_days = 7

log_sinks = [
  {
    name                   = "development-errors"
    destination           = "logging.googleapis.com/projects/${var.project_id}/logs/development-errors"
    filter                = "severity >= ERROR"
    unique_writer_identity = true
  }
]

# Security Configuration
enable_binary_authorization     = false
enable_vulnerability_scanning   = true

# Labels
additional_labels = {
  "cost-center"    = "development"
  "team"           = "engineering"
  "auto-shutdown"  = "enabled"
  "backup-policy"  = "basic"
}