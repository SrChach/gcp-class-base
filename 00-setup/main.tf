terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

# Usamos 'google_project_iam_member' para garantizar un comportamiento aditivo.
# Esto asegura que los nuevos usuarios se agreguen a la lista existente de permisos
# y evita sobreescribir o eliminar los roles de otros usuarios/servicios del proyecto.
resource "google_project_iam_member" "team_members" {
  for_each = toset(var.users)

  project = var.project_id
  role    = var.role
  member  = "user:${each.value}"
}
