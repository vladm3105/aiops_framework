# Google Cloud Platform Infrastructure Template
# AI Agent Development Framework v3.7
# 
# This Terraform configuration creates a complete GCP infrastructure setup
# optimized for AI-first development and zero-downtime deployments

terraform {
  required_version = ">= 1.5"
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
  
  # Configure backend for state management
  backend "gcs" {
    bucket = var.terraform_state_bucket
    prefix = "terraform/state"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local variables for resource naming and tagging
locals {
  common_labels = {
    project             = var.project_name
    environment         = var.environment
    framework_version   = "v3.7"
    managed_by         = "terraform"
    ai_agent_framework = "true"
  }
  
  resource_prefix = "${var.project_name}-${var.environment}"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "sql.googleapis.com",
    "redis.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudsql.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
  
  disable_on_destroy = false
}

# VPC Network Configuration
resource "google_compute_network" "main" {
  name                    = "${local.resource_prefix}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  depends_on = [google_project_service.required_apis]
}

# Regional subnet for primary workloads
resource "google_compute_subnetwork" "main" {
  name          = "${local.resource_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
  
  # Enable private Google access for services
  private_ip_google_access = true
  
  # Secondary ranges for GKE pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Cloud Router for NAT gateway
resource "google_compute_router" "main" {
  name    = "${local.resource_prefix}-router"
  region  = var.region
  network = google_compute_network.main.id
}

# NAT Gateway for outbound internet access
resource "google_compute_router_nat" "main" {
  name                               = "${local.resource_prefix}-nat"
  router                            = google_compute_router.main.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.resource_prefix}-allow-internal"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
  priority      = 1000
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.resource_prefix}-allow-health-checks"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8443"]
  }
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  priority      = 1000
}

# GKE Cluster for container workloads
resource "google_container_cluster" "main" {
  name     = "${local.resource_prefix}-gke"
  location = var.region
  
  # Network configuration
  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.main.name
  
  # IP allocation policy
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Network policy
  network_policy {
    enabled = true
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }
  
  # Enable logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Addons configuration
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  depends_on = [
    google_project_service.required_apis,
    google_compute_subnetwork.main
  ]
}

# Primary node pool for application workloads
resource "google_container_node_pool" "main" {
  name       = "${local.resource_prefix}-primary-pool"
  location   = var.region
  cluster    = google_container_cluster.main.name
  node_count = var.node_count
  
  # Node pool autoscaling
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
  
  # Node pool management
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Upgrade settings
  upgrade_settings {
    strategy      = "SURGE"
    max_surge     = 1
    max_unavailable = 0
  }
  
  # Node configuration
  node_config {
    preemptible  = var.use_preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = "pd-ssd"
    
    # Service account with minimal permissions
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Enable workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    labels = local.common_labels
    
    tags = ["gke-node", "${local.resource_prefix}-node"]
  }
  
  depends_on = [google_container_cluster.main]
}

# Service account for GKE nodes
resource "google_service_account" "gke_nodes" {
  account_id   = "${local.resource_prefix}-gke-nodes"
  display_name = "GKE Nodes Service Account"
  description  = "Service account for GKE cluster nodes"
}

# IAM bindings for GKE node service account
resource "google_project_iam_binding" "gke_nodes" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  
  project = var.project_id
  role    = each.value
  members = [
    "serviceAccount:${google_service_account.gke_nodes.email}",
  ]
}

# Artifact Registry for container images
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "${local.resource_prefix}-images"
  description   = "Container images for ${var.project_name}"
  format        = "DOCKER"
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Cloud SQL instance for application database
resource "google_sql_database_instance" "main" {
  name             = "${local.resource_prefix}-postgres"
  database_version = var.database_version
  region           = var.region
  
  settings {
    tier                        = var.database_tier
    availability_type          = var.database_availability_type
    disk_size                  = var.database_disk_size
    disk_type                  = "PD_SSD"
    disk_autoresize           = true
    disk_autoresize_limit     = var.database_max_disk_size
    
    backup_configuration {
      enabled                        = true
      start_time                    = "02:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 30
      }
    }
    
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                              = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = true
    }
    
    database_flags {
      name  = "log_statement"
      value = "all"
    }
    
    user_labels = local.common_labels
  }
  
  deletion_protection = var.environment == "production"
  
  depends_on = [
    google_project_service.required_apis,
    google_service_networking_connection.private_vpc_connection
  ]
}

# Private service connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${local.resource_prefix}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_project_service.required_apis]
}

# Cloud SQL database
resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
}

# Cloud SQL user
resource "google_sql_user" "main" {
  name     = var.database_user
  instance = google_sql_database_instance.main.name
  password = var.database_password
}

# Redis instance for caching
resource "google_redis_instance" "main" {
  count              = var.enable_redis ? 1 : 0
  name               = "${local.resource_prefix}-redis"
  tier               = var.redis_tier
  memory_size_gb     = var.redis_memory_gb
  region             = var.region
  authorized_network = google_compute_network.main.id
  
  redis_version = var.redis_version
  display_name  = "${var.project_name} Redis Cache"
  
  labels = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Secret Manager secrets
resource "google_secret_manager_secret" "database_password" {
  secret_id = "${local.resource_prefix}-database-password"
  
  labels = local.common_labels
  
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = var.database_password
}

# Load balancer for application
resource "google_compute_global_address" "default" {
  name = "${local.resource_prefix}-lb-ip"
}

# Cloud Monitoring notification channels
resource "google_monitoring_notification_channel" "email" {
  count        = length(var.alert_emails) > 0 ? length(var.alert_emails) : 0
  display_name = "Email - ${var.alert_emails[count.index]}"
  type         = "email"
  
  labels = {
    email_address = var.alert_emails[count.index]
  }
  
  depends_on = [google_project_service.required_apis]
}

# Service account for AI agents
resource "google_service_account" "ai_agents" {
  account_id   = "${local.resource_prefix}-ai-agents"
  display_name = "AI Agents Service Account"
  description  = "Service account for AI agent operations"
}

# IAM bindings for AI agents service account
resource "google_project_iam_binding" "ai_agents" {
  for_each = toset(var.ai_agent_roles)
  
  project = var.project_id
  role    = each.value
  members = [
    "serviceAccount:${google_service_account.ai_agents.email}",
  ]
}

# Workload Identity binding for AI agents
resource "google_service_account_iam_binding" "ai_agents_workload_identity" {
  service_account_id = google_service_account.ai_agents.name
  role              = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]",
  ]
}

# Cloud Build trigger for CI/CD
resource "google_cloudbuild_trigger" "main" {
  count       = var.enable_cloud_build ? 1 : 0
  name        = "${local.resource_prefix}-build-trigger"
  description = "Build trigger for ${var.project_name}"
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = var.github_branch
    }
  }
  
  filename = "cloudbuild.yaml"
  
  substitutions = {
    _PROJECT_ID     = var.project_id
    _REGION        = var.region
    _REPOSITORY    = google_artifact_registry_repository.main.name
    _IMAGE_NAME    = var.app_name
  }
  
  depends_on = [google_project_service.required_apis]
}