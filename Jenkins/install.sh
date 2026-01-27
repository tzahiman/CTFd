# Update system and install OpenJDK 17 (Required for Jenkins)
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Add Jenkins repository and key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Install Terraform , docker and docker-compose
sudo apt install terraform docker docker-compose -y

# NOTE: Ensure the 'jenkins' user has permissions for Docker
sudo usermod -aG docker jenkins

# Ensure Jenkins starts on boot
sudo systemctl enable jenkins
sudo systemctl start jenkins
