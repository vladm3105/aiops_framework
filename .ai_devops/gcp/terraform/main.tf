# Google Cloud Platform Infrastructure - Main Configuration
# AI DevOps Framework v3.7 - GCP Cloud Run Deployment

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  common_labels = {
    environment    = var.environment
    managed_by     = "terraform"
    framework      = "ai-devops-v3.7"
    deployment_id  = var.deployment_id
    created_by     = "gcp-terraform-module"
  }
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy        = false
}

# Cloud Run Service
module "cloud_run_service" {
  source = "./modules/cloud-run"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  
  service_name = var.service_name
  image_url    = var.image_url
  
  # Resource configuration
  cpu_limit         = var.cpu_limit
  memory_limit      = var.memory_limit
  min_instances     = var.min_instances
  max_instances     = var.max_instances
  concurrency       = var.concurrency
  timeout           = var.timeout
  
  # Environment variables
  environment_variables = var.environment_variables
  
  # Security configuration
  allow_unauthenticated = var.allow_unauthenticated
  service_account_email = var.service_account_email
  
  # Network configuration
  vpc_connector_name = var.vpc_connector_name
  ingress_settings   = var.ingress_settings
  
  # Labels
  labels = merge(local.common_labels, var.additional_labels)
  
  depends_on = [google_project_service.required_apis]
}

# IAM Service Account for Cloud Run
module "service_account" {
  source = "./modules/iam"
  
  project_id   = var.project_id
  environment  = var.environment
  service_name = var.service_name
  
  # Custom roles for the service account
  custom_roles = var.custom_iam_roles
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Cloud Build configuration for CI/CD
module "cloud_build" {
  source = "./modules/cloud-build"
  
  project_id          = var.project_id
  repository_name     = var.repository_name
  service_name        = var.service_name
  environment         = var.environment
  
  # Build configuration
  build_timeout       = var.build_timeout
  machine_type        = var.build_machine_type
  
  # Trigger configuration
  github_owner        = var.github_owner
  github_repo         = var.github_repo
  branch_pattern      = var.branch_pattern
  
  # Environment-specific build settings
  build_env_vars      = var.build_env_vars
  
  labels = local.common_labels
  
  depends_on = [
    google_project_service.required_apis,
    module.service_account
  ]
}

# Monitoring and Alerting
module "monitoring" {
  source = "./modules/monitoring"
  
  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment
  region       = var.region
  
  # Alerting configuration
  notification_channels = var.notification_channels
  alert_policies       = var.alert_policies
  
  # Dashboard configuration
  create_dashboard = var.create_monitoring_dashboard
  
  labels = local.common_labels
  
  depends_on = [
    google_project_service.required_apis,
    module.cloud_run_service
  ]
}

# Logging configuration
module "logging" {
  source = "./modules/logging"
  
  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment
  
  # Log retention and routing
  log_retention_days = var.log_retention_days
  log_sinks         = var.log_sinks
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# VPC and Networking (optional)
module "networking" {
  count  = var.enable_vpc ? 1 : 0
  source = "./modules/networking"
  
  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  service_name = var.service_name
  
  # VPC configuration
  vpc_cidr_range        = var.vpc_cidr_range
  private_subnet_cidr   = var.private_subnet_cidr
  
  # Cloud Run VPC connector
  connector_name        = var.vpc_connector_name
  connector_cidr_range  = var.connector_cidr_range
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Security configuration
module "security" {
  source = "./modules/security"
  
  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment
  
  # Binary Authorization
  enable_binary_authorization = var.enable_binary_authorization
  binary_auth_policy         = var.binary_auth_policy
  
  # Secret Manager
  secrets = var.secrets
  
  # Security scanning
  enable_vulnerability_scanning = var.enable_vulnerability_scanning
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}