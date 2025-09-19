# Cloud Run Module
# AI DevOps Framework v3.7 - GCP Cloud Run Service

resource "google_cloud_run_service" "main" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    metadata {
      labels = var.labels
      annotations = merge({
        "autoscaling.knative.dev/minScale"                     = var.min_instances
        "autoscaling.knative.dev/maxScale"                     = var.max_instances
        "run.googleapis.com/execution-environment"             = "gen2"
        "run.googleapis.com/cpu-throttling"                    = "true"
        "run.googleapis.com/startup-cpu-boost"                 = var.startup_cpu_boost ? "true" : "false"
        "client.knative.dev/user-image"                        = var.image_url
      }, var.vpc_connector_name != "" ? {
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      } : {})
    }

    spec {
      container_concurrency = var.concurrency
      timeout_seconds       = var.timeout
      service_account_name  = var.service_account_email

      containers {
        image = var.image_url

        ports {
          name           = "http1"
          container_port = 8080
          protocol       = "TCP"
        }

        env {
          name  = "PORT"
          value = "8080"
        }

        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }

        env {
          name  = "GOOGLE_CLOUD_REGION"
          value = var.region
        }

        env {
          name  = "DEPLOYED_BY"
          value = "terraform"
        }

        env {
          name  = "DEPLOYMENT_TIME"
          value = timestamp()
        }

        dynamic "env" {
          for_each = var.environment_variables
          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.secret_environment_variables
          content {
            name = env.key
            value_from {
              secret_key_ref {
                name = env.value.secret_name
                key  = env.value.secret_key
              }
            }
          }
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
          requests = {
            cpu    = var.cpu_request != "" ? var.cpu_request : var.cpu_limit
            memory = var.memory_request != "" ? var.memory_request : var.memory_limit
          }
        }

        # Startup probe
        startup_probe {
          http_get {
            path = "/startup"
            port = 8080
            http_headers {
              name  = "User-Agent"
              value = "GoogleCloudRun/startup-probe"
            }
          }
          initial_delay_seconds = 0
          timeout_seconds       = 240
          period_seconds        = 240
          failure_threshold     = 1
        }

        # Liveness probe
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
            http_headers {
              name  = "User-Agent"
              value = "GoogleCloudRun/liveness-probe"
            }
          }
          initial_delay_seconds = 0
          timeout_seconds       = 1
          period_seconds        = 10
          failure_threshold     = 3
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    labels = var.labels
    annotations = merge({
      "run.googleapis.com/ingress"        = var.ingress_settings
      "run.googleapis.com/ingress-status" = var.ingress_settings
    }, var.custom_domains != null ? {
      "run.googleapis.com/custom-audiences" = join(",", var.custom_domains)
    } : {})
  }

  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}

# IAM policy for the service
data "google_iam_policy" "noauth" {
  count = var.allow_unauthenticated ? 1 : 0
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  count = var.allow_unauthenticated ? 1 : 0

  location = google_cloud_run_service.main.location
  project  = google_cloud_run_service.main.project
  service  = google_cloud_run_service.main.name

  policy_data = data.google_iam_policy.noauth[0].policy_data
}

# Custom domain mapping (if specified)
resource "google_cloud_run_domain_mapping" "custom_domain" {
  count    = var.custom_domains != null ? length(var.custom_domains) : 0
  location = var.region
  name     = var.custom_domains[count.index]

  metadata {
    namespace = var.project_id
    labels    = var.labels
  }

  spec {
    route_name = google_cloud_run_service.main.name
  }
}

# Regional Load Balancer (if multiple regions)
resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  count = var.enable_load_balancer ? 1 : 0

  name                  = "${var.service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_service.main.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Service-level SLI configuration
resource "google_monitoring_sli" "cloud_run_sli" {
  count        = var.enable_sli_monitoring ? 1 : 0
  service      = google_monitoring_service.cloud_run_service[0].service_id
  display_name = "${var.service_name} SLI"
  sli_id       = "${var.service_name}-sli"

  request_based_sli {
    good_total_ratio {
      total_service_filter = "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"${var.service_name}\""
      good_service_filter  = "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"${var.service_name}\" protoPayload.response.status_code<500"
    }
  }
}

resource "google_monitoring_service" "cloud_run_service" {
  count        = var.enable_sli_monitoring ? 1 : 0
  service_id   = "${var.service_name}-service"
  display_name = "${var.service_name} Service"

  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      service_name = var.service_name
      location     = var.region
    }
  }
}