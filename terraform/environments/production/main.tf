data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
data "oci_objectstorage_namespace" "current" {
  compartment_id = var.compartment_ocid
}
locals {
  availability_domain = coalesce(var.availability_domain, data.oci_identity_availability_domains.ads.availability_domains[0].name)
  tags                = { Project = "CoachOS", Environment = "production", ManagedBy = "Terraform" }
}
resource "oci_core_vcn" "coachos" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.20.0.0/16"
  display_name   = "coachos-production"
  dns_label      = "coachos"
  freeform_tags  = local.tags
}
resource "oci_core_internet_gateway" "coachos" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.coachos.id
  display_name   = "coachos-internet-gateway"
  enabled        = true
  freeform_tags  = local.tags
}
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.coachos.id
  display_name   = "coachos-public-routes"
  route_rules {
    network_entity_id = oci_core_internet_gateway.coachos.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  freeform_tags = local.tags
}
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.coachos.id
  cidr_block                 = "10.20.10.0/24"
  display_name               = "coachos-public-app"
  dns_label                  = "app"
  route_table_id             = oci_core_route_table.public.id
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.tags
}
resource "oci_core_network_security_group" "coachos" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.coachos.id
  display_name   = "coachos-production"
  freeform_tags  = local.tags
}
resource "oci_core_network_security_group_security_rule" "ssh" {
  network_security_group_id = oci_core_network_security_group.coachos.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.admin_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}
resource "oci_core_network_security_group_security_rule" "http" {
  network_security_group_id = oci_core_network_security_group.coachos.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}
resource "oci_core_network_security_group_security_rule" "https" {
  network_security_group_id = oci_core_network_security_group.coachos.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
resource "oci_core_instance" "coachos" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "coachos-production"
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.coachos.id]
    hostname_label   = "coachos"
  }
  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu.images[0].id
    boot_volume_size_in_gbs = 100
  }
  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data           = base64encode(templatefile("${path.module}/../../../cloud-init/cloud-init.yaml", { deploy_user_public_key = file(pathexpand(var.deploy_public_key_path)) }))
  }
  freeform_tags = local.tags
}
resource "oci_core_volume" "coachos_data" {
  availability_domain = oci_core_instance.coachos.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "coachos-data"
  size_in_gbs         = 100
  freeform_tags       = local.tags
}
resource "oci_core_volume_attachment" "coachos_data" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.coachos.id
  volume_id       = oci_core_volume.coachos_data.id
}
resource "oci_objectstorage_bucket" "backups" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.current.namespace
  name           = "coachos-backups"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"
  auto_tiering   = "Disabled"
  freeform_tags  = local.tags
}
resource "oci_objectstorage_object_lifecycle_policy" "backups" {
  namespace = data.oci_objectstorage_namespace.current.namespace
  bucket    = oci_objectstorage_bucket.backups.name
  rules {
    name        = "expire-old-backups"
    action      = "DELETE"
    is_enabled  = true
    target      = "objects"
    time_amount = var.backup_retention_days
    time_unit   = "DAYS"
  }
}
