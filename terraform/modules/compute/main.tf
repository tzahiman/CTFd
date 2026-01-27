data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter { name = "name"; values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] }
}

# 1. Base instance to run the configuration
resource "aws_instance" "config_base" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data     = file("${path.root}/scripts/setup_vuln.sh")

  tags = { Name = "ctf-base-config" }

  # Sychronization: Wait for cloud-init to finish before Terraform continues
  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/ctf-key.pem")
      host        = self.public_ip
    }
  }
}

# 2. Bonus: Create AMI from the configured instance
resource "aws_ami_from_instance" "ctf_ami" {
  name               = "ctf-vulnerable-ami-${formatdate("YYYYMMDDhhmm", timestamp())}"
  source_instance_id = aws_instance.config_base.id
  depends_on         = [aws_instance.config_base]
}

# 3. Bonus: Deploy the FINAL target from that AMI
resource "aws_instance" "ctf_target" {
  ami           = aws_ami_from_instance.ctf_ami.id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]

  tags = { Name = "CTF-Target-Final" }
}

output "target_public_ip" { value = aws_instance.ctf_target.public_ip }
output "target_instance_id" { value = aws_instance.ctf_target.id }