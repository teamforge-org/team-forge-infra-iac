variable "project" {
  description = "Project ID from google"
  type        = string
  default     = ""
}

variable "port" {
  description = "Port the container listens on"
  type = number
  default = 8080
}

variable "region" {
  description = "GCP region"
  type = string
  default = "us-central1"
}

variable "docker_image" {
  description = "Docker image URL (Docker Hub or other registry)"
  type = string
}