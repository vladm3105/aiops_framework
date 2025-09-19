# Cloud Run Module Variables
# AI DevOps Framework v3.7

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "image_url" {
  description = "Container image URL"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for the service"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for the service"
  type        = string
  default     = "512Mi"
}

variable "cpu_request" {
  description = "CPU request for the service"
  type        = string
  default     = ""
}

variable "memory_request" {
  description = "Memory request for the service"
  type        = string
  default     = ""
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

variable "startup_cpu_boost" {
  description = "Enable startup CPU boost"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables for the service"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret environment variables from Secret Manager"
  type = map(object({
    secret_name = string
    secret_key  = string
  }))
  default = {}
}

variable "service_account_email" {
  description = "Service account email for the Cloud Run service"
  type        = string
  default     = ""
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access"
  type        = bool
  default     = false
}

variable "ingress_settings" {
  description = "Ingress settings for the service"
  type        = string
  default     = "all"
  validation {
    condition     = contains(["all", "internal", "internal-and-cloud-load-balancing"], var.ingress_settings)
    error_message = "Ingress settings must be one of: all, internal, internal-and-cloud-load-balancing"
  }
}

variable "vpc_connector_name" {
  description = "VPC connector name"
  type        = string
  default     = ""
}

variable "custom_domains" {
  description = "Custom domains for the service"
  type        = list(string)
  default     = null
}

variable "enable_load_balancer" {
  description = "Enable load balancer configuration"
  type        = bool
  default     = false
}

variable "enable_sli_monitoring" {
  description = "Enable SLI monitoring"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}