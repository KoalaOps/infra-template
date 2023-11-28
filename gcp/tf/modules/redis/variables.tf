variable "project_id" {
  type        = string
  description = "The project ID to deploy the Redis instance in"
}
variable "region" {
  type        = string
  description = "The region to deploy the Redis instance in"
}
variable "tier" {
  type        = string
  description = "Redis tier, BASIC or STANDARD"
}
variable "memory_size_gb" {
  type        = number
  description = "Redis memory size in GB"
}
variable "authorized_network_name" {
  type        = string
  description = "The name of the network to allow access to the Redis instance from"
}
variable "redis_version" {
  type        = string
  description = "The version of Redis to deploy"
}
