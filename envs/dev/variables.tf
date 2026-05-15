variable "db_password" {
  description = "Master password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret for the application"
  type        = string
  sensitive   = true
}

variable "github_org" { # Added my GitHub username as default value for github_org variable in dev, qa, and prod environments
  description = "GitHub username or organization that owns zen-pharma-frontend and zen-pharma-backend (e.g. john-smith)"
  type        = string
  default     = "Balasai234"
}
