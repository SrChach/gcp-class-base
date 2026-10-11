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

variable "zone" {
  description = "Zona de GCP donde se desplegará la VM y el disco"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Nombre de la instancia de Compute Engine"
  type        = string
  default     = "chucho-machine"
}

variable "machine_type" {
  description = "Tipo y tamaño de la máquina virtual (ej. e2-micro, e2-small, e2-medium)"
  type        = string
  default     = "e2-small"
}

variable "instance_status" {
  description = "Control de encendido/apagado de la máquina: 'RUNNING' (prendida) o 'TERMINATED' (apagada)"
  type        = string
  default     = "RUNNING"
}
