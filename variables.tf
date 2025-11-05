variable "project" {
  description = "Project ID from google"
  type        = string
  default     = ""
}

variable "port" {
  description = "Port the container listens on"
  type        = number
  default     = 3030
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "docker_image" {
  description = "Docker image URL (Docker Hub or other registry)"
  type        = string
}

variable "auth_secret" {
  description = "Auth secret for application"
  type        = string
}

variable "database_url" {
  description = "Application database url"
  type        = string
}

variable "openai_api_key" {
  description = "openai API Key"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name for storing images and documents"
  type        = string
}

variable "bucket_access_key" {
  description = "Bucket access key"
  type        = string
}
