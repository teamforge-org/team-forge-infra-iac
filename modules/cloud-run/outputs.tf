output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.name
}

output "service_id" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.id
}

output "latest_ready_revision" {
  description = "Name of the latest ready revision"
  value       = google_cloud_run_v2_service.service.latest_ready_revision
}