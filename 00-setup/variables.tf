variable "project_id" {
  description = "El ID del proyecto de GCP donde se darán de alta los accesos"
  type        = string
}

variable "role" {
  description = "El rol de IAM básico que se le asignará a los miembros"
  type        = string
  default     = "roles/viewer"
}

variable "users" {
  description = "Lista de correos institucionales de los miembros del equipo"
  type        = list(string)
  default     = [
    "afmontiela@liverpool.com.mx",
    "avavilas@liverpool.com.mx",
    "cbautistac02@liverpool.com.mx",
    "ccabrerag01@liverpool.com.mx",
    "ezununp@liverpool.com.mx",
    "jigudinoh@liverpool.com.mx",
    "lrlopezg@liverpool.com.mx",
    "panchopistolasgru@gmail.com",
    "rarreolas@liverpool.com.mx",
    "rserranom@liverpool.com.mx"
  ]
}
