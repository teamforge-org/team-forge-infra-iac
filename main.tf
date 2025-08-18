locals {
  environments = {
    staging = {
      service_name  = "team-forge-nodejs"
      cpu_limit     = "0.5"
      memory_limit  = "256Mi"
      concurrency   = 1
      max_instances = 3
      min_instances = 0
      log_level     = "info"
      domain_name   = null
    }

    # production TODO
  }

  env = local.environments[terraform.workspace]


  environment_variables = {
    NODE_ENV  = terraform.workspace
    LOG_LEVEL = local.env.log_level

    BETTER_AUTH_SECRET = var.auth_secret
    BETTER_AUTH_URL    = "https://team-forge-nodejs-g7cvmcelfa-uc.a.run.app"
    DATABASE_URL       = var.database_url
  }
}

resource "google_project_service" "required_apis" {
  for_each = toset(concat(
    ["run.googleapis.com"],
    terraform.workspace == "production" ? ["compute.googleapis.com"] : []
  ))

  project = var.project
  service = each.value

  disable_on_destroy = false
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-${terraform.workspace}-sa"
  display_name = "Cloud Run ${title(terraform.workspace)} Service Account"
  description  = "Service account for Cloud Run ${terraform.workspace} environment"
  project      = var.project
}

resource "google_project_iam_member" "cloud_run_sa_logging" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = google_service_account.cloud_run_sa.member
}

resource "google_project_iam_member" "cloud_run_sa_monitoring" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.cloud_run_sa.member
}

resource "google_project_iam_member" "cloud_run_sa_trace" {
  project = var.project
  role    = "roles/cloudtrace.agent"
  member  = google_service_account.cloud_run_sa.member
}

module "nodejs_api" {
  source = "./modules/cloud-run"

  service_name = local.env.service_name
  location     = var.region
  project      = var.project
  image        = var.docker_image

  cpu_limit     = local.env.cpu_limit
  memory_limit  = local.env.memory_limit
  concurrency   = local.env.concurrency
  max_instances = local.env.max_instances
  min_instances = local.env.min_instances

  container_port = var.port

  environment_variables = local.environment_variables
  service_account_email = google_service_account.cloud_run_sa.email
  allow_unauthenticated = true

  depends_on = [google_project_service.required_apis]
}
