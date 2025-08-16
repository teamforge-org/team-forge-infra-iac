output "service_url" {
  description = "URL of the Cloud Run service"
  value       = module.nodejs_api.service_url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = module.nodejs_api.service_name
}

output "environment" {
  description = "Current Terraform workspace/environment"
  value       = terraform.workspace
}

output "service_account_email" {
  description = "Email of the service account used by Cloud Run"
  value       = google_service_account.cloud_run_sa.email
}

output "service_account_cicd_email" {
  description = "Email of the service account used by cicd pipeline"
  value       = google_service_account.terraform_cicd_sa.email
}

output "terraform_cicd_sa_key" {
  value     = base64decode(google_service_account_key.terraform_cicd_sa_key.private_key)
  sensitive = true
}