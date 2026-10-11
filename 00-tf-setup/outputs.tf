# -----------------------------------------------------------------------------
# outputs.tf - Salidas informativas de la infraestructura
# -----------------------------------------------------------------------------

output "instance_name" {
  description = "Nombre de la instancia de Compute Engine"
  value       = google_compute_instance.small_vm.name
}

output "instance_zone" {
  description = "Zona donde está desplegada la máquina"
  value       = google_compute_instance.small_vm.zone
}

output "instance_public_ip" {
  description = "Dirección IP pública asignada a la máquina virtual"
  value       = google_compute_instance.small_vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_connection_command" {
  description = "Comando gcloud para conectarse mediante OS Login"
  value       = "gcloud compute ssh ${google_compute_instance.small_vm.name} --zone=${google_compute_instance.small_vm.zone}"
}
