A barebones infrastructure setup for a LoadBalancer-Application-Database framework, where your application will live in some sort of EC2 instance. 

Ok, maybe a bit more than barebones as there's an Autoscaling Group in the mix.

This will use the credentials from your AWS CLI configuration.
You will still need to run `terraform init` prior to running `terraform apply`.

The default behaviour will expect a public key file to be in the same directory as the plan.
However in the `variables.tf` file you can change that to be anywhere, eg. `~/.ssh/id_rsa.pub`.

Essentially, this creates a loadbalancer in place to receive traffic on port 80 and routes it to port 8080 in an EC2 instance that's part of an autoscaling group, along with a Postgres database, for, whatever. 

The database is the most straighforward component, requiring only a single resource block. On the other hand, the loadbalancer and auto scaling group require a bit more.

The loadbalancer's configuration could have been a single resource block if I were using a classic Elastic Load Balancer. However, since we're in the 21st Century, I've opted to go with using an Applicaiton Load Balancer. 

The ALB resources are managed over three blocks. The sequencing is sorta important, but not really if you're clever with adding a few well placed 'depends_on' parameters:
1. The main ALB configuration.
2. The ALB target group.
3. The ALB listener.

The Auto Scaling Group configuration is divided across three resource blocks:
1. A launch template which is used by the ASG to spin up new resources (where your application will live). 
2. The main ASG configuration.
3. A resource block that connects the ASG with our previously defined ALB. 

You my have noticed that in addition to a few blocks for security groups at the top, there are two 'data' blocks. Mostly to get environmental variables such as the VPC id, the CIDR blocks for defined availablity zones along with their unique subnet id. 


`example.tf`:
1. Defines a data resource to reference some environmental data (VPC and Subnets).
2. Creates security groups for our ALB, EC2 instances, and Database.
3. Creates an PostgreSQL database.
4. Creates an ALB.
5. Creates an ASG.
6. Outputs a URL to reach your ALB endpoint as well as the database endpoint.

`install_httpd.sh`:
1. Updates the package management system. 
2. Installs HTTPD and a postgres client (for testing).
3. Creates a basic page so that we can return a status code of 200.
4. Starts the HTTPD service.

`variables.tf`:
1. Sets the location for the rsa public key that will be added to the EC2 instances.
2. Sets the location for the `install_hpptds.sh` file. 
3. Sets the CIDR block(s) for inbound access over ports 22 and 80.
4. Sets a list of availability zones that the instances will be provisioned in.