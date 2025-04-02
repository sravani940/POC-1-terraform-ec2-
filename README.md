# POC-1-terraform-ec2
## *Objective:*
The goal of this PoC is to demonstrate the ability to automate the creation of an AWS EC2 instance using Terraform, configure it using Ansible, and deploy a Docker container. Additionally, generate an SSH RSA key pair inside the EC2 instance and add it to the authorized_keys file.

## *Tasks to be Completed:*

1. *Create an EC2 Instance on AWS using Terraform:*
   - Write a Terraform script to provision an EC2 instance.
   - Ensure the Terraform script generates a PEM key for SSH access during the EC2 creation process.

2. *Configure the EC2 Instance using Ansible:*
   - Write an Ansible playbook to:
     - Log in to the EC2 instance using the generated PEM key.
     - Install Docker on the EC2 instance.
     - Run the hello-world Docker container to verify Docker installation.

3. *Generate an SSH RSA Key Pair inside the EC2 Instance:*
   - Log in to the EC2 instance and generate an SSH RSA key pair with a specified name and email ID.
   - Add the generated public key to the authorized_keys file on the EC2 instance.
  
**Step 1: Create an EC2 Instance on AWS using Terraform**
Tasks:
✅ Write a Terraform script to provision an EC2 instance.
✅ Ensure Terraform generates a PEM key for SSH access during the EC2 creation process.

Steps to Implement:
**Install Terraform**
Download and install Terraform from Terraform official website. Or Below are the steps to install terraform.
sudo apt update
sudo apt install -y wget
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y
Verify installation using: terraform -v

**Configure AWS CLI**
sudo apt update
sudo apt install awscli -y
aws configure
You'll be prompted to enter:

AWS Access Key ID → Found in your AWS IAM credentials 

AWS Secret Access Key → Found in your AWS IAM credentials

Default region name (e.g., us-east-1)

Output format (leave it blank or type json) 

To verify configuration, run:aws sts get-caller-identity
If successful, it will show your AWS account details.
Now, let’s create an EC2 instance.
 Create a Working Directory
mkdir terraform-aws
cd terraform-aws
Create a new file named main.tf:
nano main.tf
Copy and paste the following Terraform script in main.tf:
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Generate an SSH key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "my-key.pem"
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "generated_key" {
  key_name   = "my-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Create an EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name

  tags = {
    Name = "Terraform-EC2"
  }
}

# Output the Public IP of the Instance
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

 Deploy the Terraform Script
Now, let’s execute Terraform.
terraform init
This downloads necessary plugins and prepares Terraform.


