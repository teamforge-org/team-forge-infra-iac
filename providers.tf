terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.48.0"
    }
  }
  backend "gcs" {
    bucket = "team-forge-469021-staging-terraform-state"
    prefix = "team-forge-state/state"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "${var.project}-${terraform.workspace}-terraform-state"
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
