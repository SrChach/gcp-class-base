# -----------------------------------------------------------------------------
# compute.tf - Máquina virtual pequeña y disco persistente en GCP
# -----------------------------------------------------------------------------

# 1. Disco persistente adicional pequeño
resource "google_compute_disk" "extra_disk" {
  name = "disk-datos-pequeno"
  type = "pd-standard" # Opciones: "pd-standard" (económico), "pd-balanced", "pd-ssd"
  size = 10            # Tamaño en Gigabytes (10 GB)
  zone = var.zone

  labels = {
    environment = "lab"
  }
}

# 2. Máquina virtual pequeña (Compute Engine)
resource "google_compute_instance" "small_vm" {
  name                      = var.instance_name
  machine_type              = var.machine_type
  zone                      = var.zone
  desired_status            = var.instance_status # "RUNNING" o "TERMINATED" para prender/apagar desde Terraform
  allow_stopping_for_update = true                # Permite detener la máquina para cambiar tamaño o estado

  # Disco de arranque (Boot Disk con sistema operativo)
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10 # 10 GB para el sistema operativo
      type  = "pd-standard"
    }
  }

  # Interfaz de red conectada a la VPC por defecto
  network_interface {
    network = "default"

    # IP pública efímera para conexión externa / SSH
    access_config {
      // Ephemeral public IP
    }
  }

  # Metadatos para facilitar acceso seguro vía OS Login / Consola de GCP
  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = ["ssh-access", "http-server"]
}

# 3. Adjuntar el disco persistente adicional a la máquina virtual
resource "google_compute_attached_disk" "attached_disk" {
  disk     = google_compute_disk.extra_disk.id
  instance = google_compute_instance.small_vm.id
}
