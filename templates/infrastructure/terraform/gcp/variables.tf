# Variables for GCP Infrastructure Template
# AI Agent Development Framework v3.7

# Project Configuration
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Human-readable project name"
  type        = string
  default     = "aiops-project"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "terraform_state_bucket" {
  description = "GCS bucket for Terraform state storage"
  type        = string
}

# Network Configuration
variable "subnet_cidr" {
  description = "CIDR block for the main subnet"
  type        = string
  default     = "10.0.0.0/20"
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "pods_cidr" {
  description = "CIDR block for GKE pods"
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrhost(var.pods_cidr, 0))
    error_message = "Pods CIDR must be a valid IPv4 CIDR block."
  }
}

variable "services_cidr" {
  description = "CIDR block for GKE services"
  type        = string
  default     = "10.2.0.0/20"
  validation {
    condition     = can(cidrhost(var.services_cidr, 0))
    error_message = "Services CIDR must be a valid IPv4 CIDR block."
  }
}

variable "master_cidr" {
  description = "CIDR block for GKE master nodes"
  type        = string
  default     = "10.3.0.0/28"
  validation {
    condition     = can(cidrhost(var.master_cidr, 0))
    error_message = "Master CIDR must be a valid IPv4 CIDR block."
  }
}

# GKE Configuration
variable "node_count" {
  description = "Initial number of nodes per zone"
  type        = number
  default     = 1
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "min_nodes" {
  description = "Minimum number of nodes in the cluster"
  type        = number
  default     = 1
  validation {
    condition     = var.min_nodes >= 1
    error_message = "Minimum nodes must be at least 1."
  }
}

variable "max_nodes" {
  description = "Maximum number of nodes in the cluster"
  type        = number
  default     = 10
  validation {
    condition     = var.max_nodes >= var.min_nodes
    error_message = "Maximum nodes must be greater than or equal to minimum nodes."
  }
}

variable "node_machine_type" {
  description = "GCE machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "node_disk_size" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 100
  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 1000
    error_message = "Node disk size must be between 20 and 1000 GB."
  }
}

variable "use_preemptible" {
  description = "Use preemptible instances for cost savings (not recommended for production)"
  type        = bool
  default     = false
}

# Database Configuration
variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
  validation {
    condition = contains([
      "POSTGRES_13", "POSTGRES_14", "POSTGRES_15"
    ], var.database_version)
    error_message = "Database version must be a supported PostgreSQL version."
  }
}

variable "database_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "database_availability_type" {
  description = "Database availability type (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.database_availability_type)
    error_message = "Database availability type must be ZONAL or REGIONAL."
  }
}

variable "database_disk_size" {
  description = "Database disk size in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.database_disk_size >= 10
    error_message = "Database disk size must be at least 10 GB."
  }
}

variable "database_max_disk_size" {
  description = "Maximum database disk size in GB for auto-resize"
  type        = number
  default     = 100
  validation {
    condition     = var.database_max_disk_size >= var.database_disk_size
    error_message = "Maximum disk size must be greater than or equal to initial disk size."
  }
}

variable "database_name" {
  description = "Name of the application database"
  type        = string
  default     = "app_db"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "database_user" {
  description = "Database username"
  type        = string
  default     = "app_user"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.database_user))
    error_message = "Database user must start with a letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "database_password" {
  description = "Database password (use strong password in production)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.database_password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }
}

# Redis Configuration
variable "enable_redis" {
  description = "Enable Redis instance for caching"
  type        = bool
  default     = true
}

variable "redis_tier" {
  description = "Redis service tier"
  type        = string
  default     = "BASIC"
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.redis_tier)
    error_message = "Redis tier must be BASIC or STANDARD_HA."
  }
}

variable "redis_memory_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
  validation {
    condition     = var.redis_memory_gb >= 1 && var.redis_memory_gb <= 300
    error_message = "Redis memory must be between 1 and 300 GB."
  }
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "REDIS_6_X"
  validation {
    condition     = contains(["REDIS_5_0", "REDIS_6_X", "REDIS_7_0"], var.redis_version)
    error_message = "Redis version must be a supported version."
  }
}

# Monitoring Configuration
variable "alert_emails" {
  description = "Email addresses for monitoring alerts"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for email in var.alert_emails : can(regex("^[\\w\\.-]+@[\\w\\.-]+\\.[\\w]+$", email))
    ])
    error_message = "All emails must be valid email addresses."
  }
}

# AI Agent Configuration
variable "ai_agent_roles" {
  description = "IAM roles for AI agent service account"
  type        = list(string)
  default = [
    "roles/container.developer",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/monitoring.viewer",
    "roles/logging.viewer"
  ]
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for workload identity"
  type        = string
  default     = "default"
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name for workload identity"
  type        = string
  default     = "ai-agents"
}

# Application Configuration
variable "app_name" {
  description = "Application name for container images"
  type        = string
  default     = "app"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "App name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

# Cloud Build Configuration
variable "enable_cloud_build" {
  description = "Enable Cloud Build trigger for CI/CD"
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub repository owner/organization"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "github_branch" {
  description = "GitHub branch to trigger builds"
  type        = string
  default     = "main"
}

# Feature Flags
variable "enable_workload_identity" {
  description = "Enable Workload Identity for secure pod-to-GCP authentication"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policies for enhanced security"
  type        = bool
  default     = true
}

variable "enable_private_cluster" {
  description = "Create private GKE cluster with no public IPs on nodes"
  type        = bool
  default     = true
}

variable "enable_backup_encryption" {
  description = "Enable encryption for database backups"
  type        = bool
  default     = true
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features (preemptible nodes, smaller instances)"
  type        = bool
  default     = false
}

variable "scheduled_scaling" {
  description = "Enable scheduled scaling for predictable workloads"
  type        = bool
  default     = false
}

# Security Configuration
variable "enable_private_google_access" {
  description = "Enable Private Google Access for subnets"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks that can access the GKE master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# Maintenance Configuration
variable "maintenance_start_time" {
  description = "Maintenance window start time in RFC3339 format"
  type        = string
  default     = "02:00"
  validation {
    condition     = can(regex("^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_start_time))
    error_message = "Maintenance start time must be in HH:MM format."
  }
}

variable "maintenance_exclusions" {
  description = "List of maintenance exclusion windows"
  type = list(object({
    exclusion_name = string
    start_time     = string
    end_time       = string
  }))
  default = []
}

# Disaster Recovery
variable "backup_retention_days" {
  description = "Database backup retention period in days"
  type        = number
  default     = 30
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery for database"
  type        = bool
  default     = true
}

# Framework Metadata
variable "framework_version" {
  description = "AI Agent Development Framework version"
  type        = string
  default     = "v3.7"
  validation {
    condition     = can(regex("^v\\d+\\.\\d+$", var.framework_version))
    error_message = "Framework version must be in format vX.Y (e.g., v3.7)."
  }
}

variable "deployment_strategy" {
  description = "Deployment strategy for the application"
  type        = string
  default     = "blue-green"
  validation {
    condition     = contains(["blue-green", "canary", "rolling"], var.deployment_strategy)
    error_message = "Deployment strategy must be one of: blue-green, canary, rolling."
  }
}

variable "enable_ai_optimization" {
  description = "Enable AI-driven infrastructure optimization"
  type        = bool
  default     = true
}