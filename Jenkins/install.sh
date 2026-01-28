#!/bin/bash

# Update system and install OpenJDK 17 (Required for Jenkins)
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Add Jenkins repository and key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y && echo "Jenkins installed successfully"

# Ensure Jenkins starts on boot
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Terraform 
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform && echo "Terraform installed successfully"

# Install awscli
sudo apt install unzip -y
wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip awscli-exe-linux-x86_64.zip
sudo ./aws/install
echo "Awscli installed successfully"
# configure awscli
echo "Configuring awscli, please enter the following information: \
    AWS Access Key ID: <your_access_key_id> \
    AWS Secret Access Key: <your_secret_access_key> \
    Region: us-east-1 \
    Output Format: json"

aws configure && echo "Awscli configured successfully"