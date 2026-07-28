variable "tenancy_ocid" {
  type      = string
  sensitive = true
}
variable "user_ocid" {
  type      = string
  sensitive = true
}
variable "compartment_ocid" {
  type      = string
  sensitive = true
}
variable "fingerprint" {
  type      = string
  sensitive = true
}
variable "private_key_path" {
  type      = string
  sensitive = true
}
variable "region" { type = string }
variable "availability_domain" {
  type    = string
  default = null
}
variable "instance_ocpus" {
  description = "OCPUs for the ARM A1 instance. OCI capacity can be more readily available for smaller requests."
  type        = number
  default     = 2
}
variable "instance_memory_in_gbs" {
  description = "Memory for the ARM A1 instance in GB."
  type        = number
  default     = 12
}
variable "admin_cidr" { type = string }
variable "ssh_public_key_path" { type = string }
variable "deploy_public_key_path" { type = string }
variable "backup_retention_days" {
  type    = number
  default = 30
}
