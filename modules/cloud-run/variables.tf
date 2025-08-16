variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "location" {
  description = "Location for the Cloud Run service"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "min_instances" {
  description = "Minimun number of instances (0 for scale-to-zero)"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "concurrency" {
  description = "Maximum number of concurrency requests per container"
  type        = number
  default     = 80
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "128Mi"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "service_account_email" {
  description = "Service account email for the Cloud Run service"
  type        = string
  default     = null
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access to the service"
  type        = bool
  default     = true
}