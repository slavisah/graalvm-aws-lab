#!/usr/bin/env bash

set -eo pipefail

# GCC toolchain
sudo yum groupinstall "Development Tools"

# GIT
git --version || sudo yum install git

# Python Pip
python --version
sudo yum install python-pip && sudo pip install --upgrade pip

# ZIP, UnZIP (needed by Terraform and SDKMAN)
sudo yum install -y zip unzip

# Terraform
(cd ~ && rm -rf terraform-download && mkdir terraform-download && cd terraform-download && curl -O https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip
sudo rm -rf /bin/terraform && sudo mkdir /bin/terraform
sudo unzip terraform_0.11.2_linux_amd64.zip -d /bin/terraform)
echo "export PATH=$PATH:/bin/terraform" >> ~/.bash_profile
source "$HOME/.bash_profile"
terraform --version

# AWS CLI
sudo pip install awscli --upgrade
aws --version

# SDKMAN (GraalVM + Maven)
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
sdk install java 19.2.1-grl
java -version
sdk install maven 3.5.4
mvn --version
gu install native-image
