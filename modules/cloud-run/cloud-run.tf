resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.location
  project  = var.project

  template {
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    max_instance_request_concurrency = var.concurrency

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      ports {
        container_port = var.container_port
      }

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    service_account = var.service_account_email
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count = var.allow_unauthenticated ? 1 : 0

  name     = google_cloud_run_v2_service.service.name
  location = google_cloud_run_v2_service.service.location
  project  = var.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}