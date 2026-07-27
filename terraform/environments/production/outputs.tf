output "instance_id" { value = oci_core_instance.coachos.id }
output "public_ip" { value = oci_core_instance.coachos.public_ip }
output "backup_bucket" { value = oci_objectstorage_bucket.backups.name }
output "data_volume_id" { value = oci_core_volume.coachos_data.id }
