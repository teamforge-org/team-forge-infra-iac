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

resource "google_service_account" "terraform_cicd_sa" {
  description  = "Service Account for ${terraform.workspace} CICD pipeline"
  account_id   = "terraform-cicd-${terraform.workspace}-sa"
  display_name = "Terraform CICD ${title(terraform.workspace)} Service Account"
  project      = var.project
}

resource "google_project_iam_member" "terraform_cicd_sa_usage_admin" {
  project = var.project
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_project_iam_member" "terraform_cicd_sa_account_admin" {
  project = var.project
  role    = "roles/iam.serviceAccountAdmin"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_project_iam_member" "terraform_cicd_sa_cloud_run_admin" {
  project = var.project
  role    = "roles/run.admin"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_project_iam_member" "terraform_cicd_sa_account_user" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_project_iam_member" "terraform_cicd_sa_IAM_admin" {
  project = var.project
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_service_account_key" "terraform_cicd_sa_key" {
  service_account_id = google_service_account.terraform_cicd_sa.id
  public_key_type    = "TYPE_X509_PEM_FILE"
}