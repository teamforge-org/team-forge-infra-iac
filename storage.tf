resource "google_storage_bucket" "team-forge-bucket" {
  name          = "${var.project}-${terraform.workspace}-team-forge"
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

resource "google_storage_bucket_iam_member" "public_reader" {
  bucket = google_storage_bucket.team-forge-bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_service_account" "writer_service_account" {
  account_id   = "${terraform.workspace}-bucket-writer"
  display_name = "Service Account with write access to the team-forge bucket"
}

resource "google_storage_bucket_iam_member" "writer_iam" {
  bucket = google_storage_bucket.team-forge-bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.writer_service_account.email}"
}