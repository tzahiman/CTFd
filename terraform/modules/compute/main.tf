
# 1. Look up the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Automatically generate an SSH Key (No local .pem file needed)
resource "tls_private_key" "ctf_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 3. Register the generated Public Key with AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "ctf-automation-key-${timestamp()}" # Timestamp ensures uniqueness if redeploying
  public_key = tls_private_key.ctf_key.public_key_openssh
}

# 4. Base instance: This runs the setup script
resource "aws_instance" "config_base" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.generated_key.key_name

  # This is the "init" part - it executes scripts/setup_vuln.sh on boot
  user_data = file("${path.root}/scripts/setup_vuln.sh")

  # SSH Connection for the provisioner below
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ctf_key.private_key_pem
    host        = self.public_ip
  }

  tags = {
    Name = "ctf-config-base"
  }
}

# 5. BONUS: Create an AMI from the fully configured instance
resource "aws_ami_from_instance" "ctf_ami" {
  name               = "ctf-vulnerable-ami-${formatdate("YYYYMMDDhhmm", timestamp())}"
  source_instance_id = aws_instance.config_base.id
  
  # Ensure the base instance is completely done before imaging
  depends_on = [aws_instance.config_base]
}

# 6. BONUS: Deploy the ACTUAL CTF target from that new AMI
resource "aws_instance" "ctf_target" {
  ami                    = aws_ami_from_instance.ctf_ami.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "CTF-Target-Final"
  }
}
