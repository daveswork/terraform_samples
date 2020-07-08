This terraform plan sets up an EC2 instance, SSH Key pair and a security group to allow
access over port 8080 from anywhere. 
You can customize the source location of the SSH public key, the CIDR blocks for inbound access
as well as the location of the jenkins provisioning script in terraform.tf
Authentication is handled by the AWS CLI config. 

Terraform simply handles the cloud assets, whereas jenkins is installed from install_jenkins.sh
when the EC2 instance starts up. 

Terraform will report completion once the AWS assets are created, however the script will still 
need a few minutes to complete the Jenkins install. 

The Jenkins install script disables the startup wizard and creates an admin user "admin" with 
password "admin-pass" from the script. 
This is more about getting Jenkins up and running than it is locking it down.
