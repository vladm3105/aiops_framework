# Terraform Variables for GCP Cloud Run Deployment
# AI DevOps Framework v3.7

# Basic Configuration
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production"
  }
}

variable "deployment_id" {
  description = "Unique deployment identifier"
  type        = string
  default     = ""
}

# Cloud Run Service Configuration
variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "image_url" {
  description = "Container image URL for Cloud Run service"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = 80
}

variable "timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

# Environment Variables
variable "environment_variables" {
  description = "Environment variables for the Cloud Run service"
  type        = map(string)
  default     = {}
}

# Security Configuration
variable "allow_unauthenticated" {
  description = "Allow unauthenticated access to the service"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Service account email for Cloud Run service"
  type        = string
  default     = ""
}

variable "custom_iam_roles" {
  description = "Custom IAM roles for the service account"
  type        = list(string)
  default     = []
}

# Network Configuration
variable "enable_vpc" {
  description = "Enable VPC networking"
  type        = bool
  default     = false
}

variable "vpc_connector_name" {
  description = "VPC connector name for Cloud Run"
  type        = string
  default     = ""
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "connector_cidr_range" {
  description = "CIDR range for VPC connector"
  type        = string
  default     = "10.0.2.0/28"
}

variable "ingress_settings" {
  description = "Ingress settings for Cloud Run service"
  type        = string
  default     = "all"
  validation {
    condition     = contains(["all", "internal", "internal-and-cloud-load-balancing"], var.ingress_settings)
    error_message = "Ingress settings must be one of: all, internal, internal-and-cloud-load-balancing"
  }
}

# Cloud Build Configuration
variable "repository_name" {
  description = "Container repository name"
  type        = string
  default     = ""
}

variable "build_timeout" {
  description = "Cloud Build timeout"
  type        = string
  default     = "600s"
}

variable "build_machine_type" {
  description = "Cloud Build machine type"
  type        = string
  default     = "e2-standard-2"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "branch_pattern" {
  description = "Branch pattern for Cloud Build triggers"
  type        = string
  default     = "^main$"
}

variable "build_env_vars" {
  description = "Environment variables for Cloud Build"
  type        = map(string)
  default     = {}
}

# Monitoring Configuration
variable "notification_channels" {
  description = "Notification channels for alerts"
  type        = list(string)
  default     = []
}

variable "alert_policies" {
  description = "Alert policies configuration"
  type = list(object({
    display_name = string
    combiner     = string
    conditions = list(object({
      display_name = string
      filter       = string
      comparison   = string
      threshold    = number
      duration     = string
    }))
  }))
  default = []
}

variable "create_monitoring_dashboard" {
  description = "Create monitoring dashboard"
  type        = bool
  default     = true
}

# Logging Configuration
variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "log_sinks" {
  description = "Log sink configurations"
  type = list(object({
    name                 = string
    destination          = string
    filter               = string
    unique_writer_identity = bool
  }))
  default = []
}

# Security Configuration
variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = false
}

variable "binary_auth_policy" {
  description = "Binary Authorization policy"
  type        = string
  default     = "default"
}

variable "enable_vulnerability_scanning" {
  description = "Enable container vulnerability scanning"
  type        = bool
  default     = true
}

variable "secrets" {
  description = "Secret Manager secrets"
  type = list(object({
    secret_id = string
    data      = string
  }))
  default   = []
  sensitive = true
}

# Labels and Metadata
variable "additional_labels" {
  description = "Additional labels for resources"
  type        = map(string)
  default     = {}
}