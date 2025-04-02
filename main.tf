provider "aws" {
  region = "ap-south-1"  # Change to your preferred region
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
  ami           = "ami-0e35ddab05955cf57"  # Replace with a valid AMI ID
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

