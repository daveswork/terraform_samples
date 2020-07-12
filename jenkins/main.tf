provider "aws" {
    profile = "default"
    region = "us-east-1"
}

# Creates a key pair in aws from a local public RSA key
resource "aws_key_pair" "dave"{
    key_name = "daves-windows-rsa"
    public_key = file(var.public_key_path)
}

# Creates a security group for our EC2 instance. 
# Allows SSH access and opens up port 8080 from anywhere.
resource "aws_security_group" "allow_all_jenkins" {
    name    = "allow_jenkins_all_sources"
    description = "allows ssh ingress from all sources"
    ingress {
        description = "SSH access from all sources."
        cidr_blocks = var.inbound_ssh
        from_port = 22
        to_port = 22
        protocol =  "tcp"
    }
    ingress {
        description = "Allow port 8080 for Jenkins."
        cidr_blocks = var.inbound_jenkins
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
    }
    egress {
        description = "Allow all outbound access"
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  
    } 
}

# Finally, this creates an EC2 instance that will install Jenkins on startup using the 
# specified shell script.
resource "aws_instance" "example" {
    ami             = "ami-09d95fab7fff3776c"
    instance_type   = "t2.micro"
    user_data       = file(var.user_data_file)
    key_name        = "daves-windows-rsa"
    security_groups = ["allow_jenkins_all_sources"]
}

# This just gives us the public IP of the instance so we can connect to it.
output "Public_IP" {
    value = aws_instance.example.public_ip
}

output "Jenkins_URL" {
    value = "http://${aws_instance.example.public_ip}:8080"
}