variable "project_resource_prefix" {
    type        = string
    description = "Prefix for resources in the project"
}
variable "primary_location" {
    type        = string
    description = "Primary location for the network"
}
variable "locations" {
    type        = list(string)
    description = "Locations for the network"
}