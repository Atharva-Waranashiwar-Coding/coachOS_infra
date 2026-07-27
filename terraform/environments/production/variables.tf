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
variable "namespace" { type = string }
variable "availability_domain" {
  type    = string
  default = null
}
variable "admin_cidr" { type = string }
variable "ssh_public_key_path" { type = string }
variable "deploy_public_key_path" { type = string }
variable "backup_retention_days" {
  type    = number
  default = 30
}
