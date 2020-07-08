A collection of files to get a basic Jenkins instance up and running.

This terraform plan sets up an EC2 instance, SSH Key pair and a security group to allow
access over ports 22 and 8080 from anywhere. 

This will use the credentials from your AWS CLI configuration.
You will still need to run `terraform init` prior to running `terraform apply`.

The default behaviour will expect a public key file to be in the same directory as the plan.
However in the `variables.tf` file you can change that to be anywhere, eg. `~/.ssh/id_rsa.pub`.

Terraform simply handles the cloud assets, whereas jenkins is installed from `install_jenkins.sh`.
when the EC2 instance starts up. It will report completion once the AWS assets are created, however the Jenkins installation process will still need a few minutes to complete.

The Jenkins install script disables the startup wizard and creates an admin user "admin" with 
password "admin-pass" from the script. 


`example.tf`:
1. Creates a key pair for ssh access.
2. Creates a security group allowing inbound traffic on ports 22 and 8080, and allows all outbound.
3. Creates an EC2 instance with the previously configured key pair and security group.
4. Adds the contents of `install_jenkins.sh` to the instance USER DATA which will be run on startup. 
5. Provides the public IP address for the EC2 instance as well as the URL string to access Jenkins (when it eventually starts up, approximately 2-3 minutes).

`install_jenkins.sh`:
1. Updates the package management system, adds the Jenkins repository.
2. Installs Jenkins.
3. Disables the startup wizard and creates a new user 'admin' with password 'admin-pass'.
4. Starts the Jenkins instance and enables it to auto start after reboot.

`variables.tf`:
1. Sets the location for the rsa public key that will be added to the EC2 instance.
2. Sets the location for the `install_jenkins.sh` file. 
3. Sets the CIDR block(s) for inbound access over ports 22 and 8080.
