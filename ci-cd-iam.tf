locals {
  required_apis = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com"
  ]
}

resource "google_service_account" "terraform_cicd_sa" {
  description  = "Service Account for ${terraform.workspace} CICD pipeline"
  account_id   = "terraform-cicd-${terraform.workspace}-sa"
  display_name = "Terraform CICD ${title(terraform.workspace)} Service Account"
  project      = var.project
}

resource "google_project_service" "required_apis_cicd" {
  for_each           = toset(local.required_apis)
  project            = var.project
  service            = each.value
  disable_on_destroy = false
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


resource "google_project_iam_member" "terraform_cicd_sa_key_admin" {
  project = var.project
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = google_service_account.terraform_cicd_sa.member
}


resource "google_project_iam_member" "gcs_admin_iam" {
  project = var.project
  role    = "roles/storage.admin"
  member  = google_service_account.terraform_cicd_sa.member
}

resource "google_service_account_key" "terraform_cicd_sa_key" {
  service_account_id = google_service_account.terraform_cicd_sa.id
  public_key_type    = "TYPE_X509_PEM_FILE"
}