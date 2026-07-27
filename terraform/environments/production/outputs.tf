output "deployment_host_public_ip" { value = module.compute.public_ip }
output "deployment_host_id" { value = module.compute.instance_id }
output "backup_bucket_name" { value = module.object_storage.backup_bucket_name }
