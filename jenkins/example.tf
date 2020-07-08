provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_key_pair" "dave"{
    key_name = "daves-windows-rsa"
    public_key = file(var.private_key_path)
}

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

resource "aws_instance" "example" {
    ami             = "ami-09d95fab7fff3776c"
    instance_type   = "t2.micro"
    user_data       = file(var.user_data_file)
    key_name        = "daves-windows-rsa"
    security_groups = ["allow_jenkins_all_sources"]
}

output "Public_IP" {
    value = aws_instance.example.public_ip
}