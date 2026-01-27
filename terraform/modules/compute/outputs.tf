output "target_public_ip" {
  value = aws_instance.ctf_target.public_ip
}

output "target_instance_id" {
  value = aws_instance.ctf_target.id
}

output "ctf_ami_id" {
  value = aws_ami_from_instance.ctf_ami.id
}