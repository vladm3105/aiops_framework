# Cloud Run Module Outputs
# AI DevOps Framework v3.7

output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_service.main.status[0].url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_service.main.name
}

output "service_id" {
  description = "ID of the Cloud Run service"
  value       = google_cloud_run_service.main.id
}

output "location" {
  description = "Location of the Cloud Run service"
  value       = google_cloud_run_service.main.location
}

output "status" {
  description = "Status of the Cloud Run service"
  value       = google_cloud_run_service.main.status
}

output "latest_revision_name" {
  description = "Latest revision name"
  value       = google_cloud_run_service.main.status[0].latest_ready_revision_name
}

output "traffic_allocation" {
  description = "Traffic allocation"
  value       = google_cloud_run_service.main.status[0].traffic
}

output "ready_condition" {
  description = "Ready condition of the service"
  value       = google_cloud_run_service.main.status[0].conditions
}

output "custom_domain_mappings" {
  description = "Custom domain mappings"
  value       = var.custom_domains != null ? google_cloud_run_domain_mapping.custom_domain[*].status : []
}

output "neg_id" {
  description = "Network Endpoint Group ID (if load balancer enabled)"
  value       = var.enable_load_balancer ? google_compute_region_network_endpoint_group.cloud_run_neg[0].id : null
}

output "sli_id" {
  description = "SLI ID (if SLI monitoring enabled)"
  value       = var.enable_sli_monitoring ? google_monitoring_sli.cloud_run_sli[0].sli_id : null
}