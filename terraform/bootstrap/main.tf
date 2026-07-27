terraform {
  required_version = ">= 1.8.0"
  required_providers {
    oci = { source = "oracle/oci", version = "~> 6.0" }
  }
}
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
data "oci_objectstorage_namespace" "current" {
  compartment_id = var.compartment_ocid
}
resource "oci_objectstorage_bucket" "terraform_state" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.current.namespace
  name           = "coachos-terraform-state"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"
  auto_tiering   = "Disabled"
}
