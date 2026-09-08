terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "8bitcitychamp-tfstate-bitcitychamp-project"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
  billing_project       = var.project_id
}
