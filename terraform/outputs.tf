output "target_ip" {
  description = "Public IP of the final vulnerable CTF target"
  value       = module.compute.target_public_ip
}

output "target_instance_id" {
  description = "Instance ID of the final target"
  value       = module.compute.target_instance_id
}

output "vulnerable_ami_id" {
  description = "The ID of the AMI created from the configured base"
  value       = module.compute.ctf_ami_id # Ensure this is exported in the compute module
}