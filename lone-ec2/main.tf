provider "aws" {
    profile = "default"
    region = "us-east-1"
}

#  aws ec2 run-instances 
# --image-id ami-037b65db6204dd201 
# --count 1 --instance-type t2.micro 
# --key-name djodhan-macbook-pro 
# --placement AvailabilityZone=us-east-1b'

resource "aws_instance" "sample-ec2" {
    ami                 = "ami-037b65db6204dd201"
    instance_type       = "t2.micro"
    key_name            = "djodhan-macbook-pro"
    availability_zone   = "us-east-1b"
}