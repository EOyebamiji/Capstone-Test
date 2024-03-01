#!/bin/bash

# Set -e for immediate script exit on error
set -e

# Define a function to allow for colored output
print_colored() {
  CYAN='\033[1;36m'
  NO_COLOR='\033[0m'
  printf "${CYAN}== $1 ${NO_COLOR}\n"
}

print_colored "=== This script is to automate the provisioning of the server for the purpose of this project, installing every project dependencies ==="

# Update the Ubuntu server
print_colored "=== Updating the Ubuntu Server ==="
sudo apt-get update -y
sudo apt-get upgrade -y

# Install unzip
sudo apt-get install unzip -y

# Install Terraform
print_colored "=== Installing Terraform ==="
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform -y

## Verify Terraform installation
terraform --version

# Install kubectl
print_colored "=== Installing Kubernetes Kubectl ==="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl 
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

## Clean up kubectl files
rm kubectl.sha256

# Install AWS CLI
print_colored "=== Installing AWS CLI ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update

## Clean up AWS CLI files
rm -rf awscliv2.zip aws

# Install Helm
print_colored "=== Installing Helm ==="
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Install Jenkins
print_colored "=== Installing Jenkins ==="
sudo apt install fontconfig openjdk-17-jre -y
java -version
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Clean up unnecessary files
print_colored "=== Cleaning up unnecessary files ==="
sudo apt-get autoremove -y
sudo apt-get clean

# Configure UFW
print_colored "=== Configuring UFW ==="
sudo ufw allow OpenSSH 
sudo ufw enable
sudo ufw allow 8080
sudo ufw status