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
Download and install Terraform from Terraform official website. Or Below are the steps to install terraform in your local machine.
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
configure aws credentials
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
Save and exit (CTRL + X, then Y, then ENTER).
 Deploy the Terraform Script
Now, let’s execute Terraform.
terraform init
This downloads necessary plugins and prepares Terraform.
terraform validate
terraform apply -auto-approve
This will: ✅ Generate an SSH key
✅ Create an AWS Key Pair
✅ Launch an EC2 instance

Once completed, Terraform will output the public IP address of the instance.
**Connect to the EC2 Instance**
Change the file permissions for the PEM key:
chmod 400 my-key.pem
SSH into the instance:
ssh -i my-key.pem ubuntu@instance public ip 
Replace <INSTANCE_PUBLIC_IP> with the actual IP from the Terraform output.

 STEP 2. Configure EC2 Using Ansible
This Ansible playbook will:
✅ SSH into the instance
✅ Install Docker
✅ Run the hello-world container
install ansible on your local machine
sudo apt update
sudo apt install -y ansible
Create a file called inventory.ini in your working directory: nano inventory.ini
[ec2]
INSTANCE_IP ansible_user=ubuntu ansible_private_key_file=terraform-key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
To check if Ansible can connect to the instance, run:
ansible -i inventory.ini all -m ping
Expected Output:
13.201.188.241 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
If you see "pong", the connection is successful!
Now, let’s create the Ansible Playbook to install Docker.
Create a new file called setup.yml:
nano setup.yml
Paste the following content in setup.yml
---
- name: Configure EC2 Instance
  hosts: ec2
  become: true
  tasks:

    - name: Update system packages
      apt:
        update_cache: yes

    - name: Install required dependencies
      apt:
        name: ["apt-transport-https", "ca-certificates", "curl", "software-properties-common"]
        state: present

    - name: Add Docker’s official GPG key
      shell: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    - name: Add Docker repository
      shell: add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    - name: Install Docker
      apt:
        name: docker-ce
        state: present

    - name: Run Docker hello-world container
      shell: docker run hello-world
Save and exit (CTRL + X, then Y, then ENTER).
Now, execute the playbook to configure your EC2 instance:
ansible-playbook -i inventory.ini setup.yml
Verify docker installation on ec2
Now, SSH into the EC2 instance:
ssh -i terraform-key.pem ubuntu@13.201.188.241
check docker version: docker --version
Check if the hello-world container ran successfully:
docker ps -a
Expected Output:
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                     NAMES
b6d123a4a2d4   hello-world   "/hello"   2 minutes ago    Exited (0) 1 minute ago    dreamy_gates

Step 3: Generate an SSH RSA Key Pair Inside the EC2 Instance
In this step, we will:
✅ SSH into the EC2 instance
✅ Generate an SSH RSA key pair inside the EC2 instance
✅ Add the public key to the authorized_keys file for authentication

Run the following command from your local machine:
ssh-i my-key.pem ubuntu@public ip
Once inside the EC2 instance, run:
ssh-keygen -t rsa -b 2048 -C "user@example.com" -f ~/.ssh/custom_rsa
Expected Output:
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ubuntu/.ssh/custom_rsa.
Your public key has been saved in /home/ubuntu/.ssh/custom_rsa.pub.
Now, add the newly generated public key to the authorized_keys file:
cat ~/.ssh/custom_rsa.pub >> ~/.ssh/authorized_keys
Set correct permissions:
chmod 600 ~/.ssh/custom_rsa
chmod 644 ~/.ssh/custom_rsa.pub
chmod 600 ~/.ssh/authorized_keys
Test SSH Login with the New Key
Exit the EC2 instance:use exit command
Copy the private key from EC2 to your local machine:
scp -i terraform-key.pem ubuntu@13.201.188.241:/home/ubuntu/.ssh/custom_rsa .
This will copy the key file to your local system.
Change permissions on your local machine:
chmod 400 custom_rsa
Test SSH login using the new key:
ssh -i custom_rsa ubuntu@13.201.188.241
If you can log in successfully, the setup is working!







