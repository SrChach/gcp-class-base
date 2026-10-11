variable "project_id" {
  description = "El ID del proyecto de GCP donde se darán de alta los accesos"
  type        = string
}

variable "user_roles" {
  description = "Mapa de correos con sus respectivos roles asignados"
  type        = map(string)
  default     = {
    "avavilas@liverpool.com.mx"  = "roles/owner"
    "gsikmo@gmail.com"           = "roles/owner"
    "rserranom@liverpool.com.mx" = "roles/owner"
    "jigudinoh@liverpool.com.mx"  = "roles/owner"
  }
}
