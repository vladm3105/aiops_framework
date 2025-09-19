# Terraform Outputs for GCP Cloud Run Deployment
# AI DevOps Framework v3.7

# Cloud Run Service Outputs
output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = module.cloud_run_service.service_url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = module.cloud_run_service.service_name
}

output "service_id" {
  description = "ID of the Cloud Run service"
  value       = module.cloud_run_service.service_id
}

output "service_location" {
  description = "Location of the Cloud Run service"
  value       = module.cloud_run_service.location
}

output "service_status" {
  description = "Status of the Cloud Run service"
  value       = module.cloud_run_service.status
}

output "latest_revision_name" {
  description = "Latest revision name of the service"
  value       = module.cloud_run_service.latest_revision_name
}

output "traffic_allocation" {
  description = "Traffic allocation for the service"
  value       = module.cloud_run_service.traffic_allocation
}

# Service Account Outputs
output "service_account_email" {
  description = "Email of the service account"
  value       = module.service_account.service_account_email
}

output "service_account_id" {
  description = "ID of the service account"
  value       = module.service_account.service_account_id
}

output "service_account_unique_id" {
  description = "Unique ID of the service account"
  value       = module.service_account.service_account_unique_id
}

# Cloud Build Outputs
output "cloud_build_trigger_id" {
  description = "ID of the Cloud Build trigger"
  value       = module.cloud_build.trigger_id
}

output "cloud_build_trigger_name" {
  description = "Name of the Cloud Build trigger"
  value       = module.cloud_build.trigger_name
}

output "repository_url" {
  description = "Container repository URL"
  value       = module.cloud_build.repository_url
}

# Monitoring Outputs
output "monitoring_dashboard_url" {
  description = "URL of the monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "alert_policy_ids" {
  description = "IDs of created alert policies"
  value       = module.monitoring.alert_policy_ids
}

output "notification_channel_ids" {
  description = "IDs of notification channels"
  value       = module.monitoring.notification_channel_ids
}

# Logging Outputs
output "log_sink_names" {
  description = "Names of created log sinks"
  value       = module.logging.log_sink_names
}

output "log_metrics" {
  description = "Created log-based metrics"
  value       = module.logging.log_metrics
}

# Network Outputs (when VPC is enabled)
output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = var.enable_vpc ? module.networking[0].vpc_network_id : null
}

output "vpc_connector_id" {
  description = "ID of the VPC connector"
  value       = var.enable_vpc ? module.networking[0].vpc_connector_id : null
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = var.enable_vpc ? module.networking[0].private_subnet_id : null
}

# Security Outputs
output "binary_authorization_policy" {
  description = "Binary Authorization policy"
  value       = module.security.binary_authorization_policy
}

output "secret_manager_secrets" {
  description = "Secret Manager secret names"
  value       = module.security.secret_names
  sensitive   = true
}

# Project Information
output "project_id" {
  description = "Google Cloud project ID"
  value       = var.project_id
}

output "region" {
  description = "Google Cloud region"
  value       = var.region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Resource Labels
output "common_labels" {
  description = "Common labels applied to resources"
  value       = local.common_labels
}

# Health Check URLs
output "health_check_urls" {
  description = "Health check endpoints"
  value = {
    health    = "${module.cloud_run_service.service_url}/health"
    startup   = "${module.cloud_run_service.service_url}/startup"
    ready     = "${module.cloud_run_service.service_url}/ready"
    metrics   = "${module.cloud_run_service.service_url}/metrics"
    dashboard = "${module.cloud_run_service.service_url}/dashboard"
  }
}

# Deployment Information
output "deployment_info" {
  description = "Deployment information"
  value = {
    deployment_id   = var.deployment_id
    service_name    = var.service_name
    image_url       = var.image_url
    cpu_limit       = var.cpu_limit
    memory_limit    = var.memory_limit
    min_instances   = var.min_instances
    max_instances   = var.max_instances
    concurrency     = var.concurrency
    timeout         = var.timeout
    ingress         = var.ingress_settings
    vpc_enabled     = var.enable_vpc
    deployed_at     = timestamp()
  }
}

# Cost Estimation (approximate)
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    cloud_run_minimum = var.min_instances * 24 * 30 * 0.00002400  # $0.000024/vCPU-hour
    cloud_run_memory  = var.min_instances * 24 * 30 * tonumber(replace(var.memory_limit, "Mi", "")) / 1024 * 0.00000250  # $0.0000025/GB-hour
    build_estimate    = 10 * 0.003  # Assuming 10 builds per month at $0.003/build-minute (10 minutes average)
    logging_estimate  = 5.0  # Estimated $5/month for logging
    monitoring_estimate = 3.0  # Estimated $3/month for monitoring
    total_estimated  = var.min_instances * 24 * 30 * 0.00002400 + var.min_instances * 24 * 30 * tonumber(replace(var.memory_limit, "Mi", "")) / 1024 * 0.00000250 + 10 * 0.003 + 5.0 + 3.0
  }
}

# Terraform State Information
output "terraform_workspace" {
  description = "Terraform workspace"
  value       = terraform.workspace
}

output "terraform_version" {
  description = "Terraform version used"
  value       = "~> 1.0"
}

# API Endpoints for Management
output "management_endpoints" {
  description = "Management and API endpoints"
  value = {
    cloud_console_service = "https://console.cloud.google.com/run/detail/${var.region}/${var.service_name}?project=${var.project_id}"
    cloud_build_console   = "https://console.cloud.google.com/cloud-build/builds?project=${var.project_id}"
    monitoring_console    = "https://console.cloud.google.com/monitoring?project=${var.project_id}"
    logging_console       = "https://console.cloud.google.com/logs/query?project=${var.project_id}"
    container_registry    = "https://console.cloud.google.com/gcr/images/${var.project_id}?project=${var.project_id}"
  }
}