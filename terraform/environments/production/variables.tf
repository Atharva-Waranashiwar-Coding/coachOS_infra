variable "aws_region" {
  type = string
}
variable "project" {
  type    = string
  default = "coachos"
}
variable "environment" {
  type    = string
  default = "production"
}
variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}
variable "availability_zones" {
  type = list(string)
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.large"
}
variable "ssh_key_name" {
  type      = string
  sensitive = true
}
variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}
variable "root_volume_gib" {
  type    = number
  default = 80
}
variable "cloud_init_path" {
  type    = string
  default = "../../../cloud-init/cloud-init.yaml"
}
