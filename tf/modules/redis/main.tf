resource "random_id" "redis_name_suffix" {
  byte_length = 4
}

resource "google_redis_instance" "main" {
  name               = "main-instance-${random_id.redis_name_suffix.hex}"
  region             = var.region
  tier               = var.tier
  memory_size_gb     = var.memory_size_gb
  authorized_network = var.authorized_network_name
  redis_version      = var.redis_version
  connect_mode       = "DIRECT_PEERING"

}