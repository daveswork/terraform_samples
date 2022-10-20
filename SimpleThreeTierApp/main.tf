provider "aws" {
    profile = "default"
    region = "us-east-1"
}

#Creates needed data nodes.
data "aws_vpc" "current" {  
}

data "aws_subnet" "collection" {
    for_each            = toset(var.az)
    availability_zone   = each.value
}

#Creates a key pair in aws from a local public RSA key.
resource "aws_key_pair" "dave"{
    key_name = "daves-windows-rsa"
    public_key = file(var.public_key_path)
}

#Creates the needed Security Groups.
resource "aws_security_group" "allow_http"{
    name        = "allow_http_access"
    description = "Allows http (insecure) access from specified sources"
    ingress {
        description = "Inbound http"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.inbound_http
    }
}

resource "aws_security_group" "allow_outbound" {
    name        = "allow_outbound_everywhere"
    description = "Allows all outbound traffic"
    egress {
        description = "Allows everything outbound."
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.all_networks
    }
}

resource "aws_security_group" "allow_8080" {
    name        = "allow_inbound_8080"
    description = "Allows inbound traffic on port 808"
    ingress{
        description = "Allows everything inbound on port 8080"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = [for subnet in data.aws_subnet.collection: subnet.cidr_block]
    }
  
}

resource "aws_security_group" "allow_ssh" {
    name          = "allow_inbound_ssh"
    description   = "Allows inbound SSH connections."
    ingress{
        description = "Allows inbound ssh connection"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.all_networks  
  }
}

resource "aws_security_group" "allow_psql_connections" {
    name          = "allow_inbound_psql_connections"
    description   = "Allows inbound PSQL connections."
    ingress{
        description = "Allows inbound ssh connection"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = [for subnet in data.aws_subnet.collection: subnet.cidr_block]
  }
}

#Creates a PostgreSQL database.
#Several different ways to handle secrets, but wanted to keep this flat, with minimal input.
resource "aws_db_instance" "my_db"{
    allocated_storage   = 20
    storage_type        = "gp2"
    engine              = "postgres"
    engine_version      = "13.7"
    instance_class      = "db.t3.micro"
    db_name             = "stuffit"
    username            = "pgme"
    password            = "notthisplease"
    skip_final_snapshot = true
    identifier          = "myappdb"
    vpc_security_group_ids  = [aws_security_group.allow_psql_connections.id]
}

#Creates an Application Load Balancer.
resource "aws_lb" "my_alb"{
    name                = "my-sample-alb"
    internal            = false
    load_balancer_type  = "application"
    subnets             = [for subnet in data.aws_subnet.collection: subnet.id]
    security_groups     = [aws_security_group.allow_http.id, aws_security_group.allow_outbound.id]
}

#Creates an ALB target group.
resource "aws_alb_target_group" "my_alb" {
    name        = "my-alb-targetgroup"
    port        = 8080
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.current.id
    slow_start  = 120
    stickiness {
      type              = "lb_cookie"
      cookie_duration   = 1800
    }
    health_check {
      interval  = 10
      path      = "/"
      healthy_threshold     = 3
      unhealthy_threshold   = 10
      matcher   = "200"
    }
}

#Creates an ALB Listener.
#To keep the config simple, there's no SSL config, which would require a few more resource nodes.
resource "aws_lb_listener" "my_alb" {
    load_balancer_arn   = aws_lb.my_alb.arn
    port        = 80
    protocol    = "HTTP"
    default_action {
      type              = "forward"
      target_group_arn  = aws_alb_target_group.my_alb.arn
    }
}

#Creates a launch template for use by the Auto Scaling Group.
resource "aws_launch_template" "my_app"{
    name            = "custom-app"
    image_id        = "ami-09d95fab7fff3776c"
    instance_type   = "t2.micro"
    key_name        = "daves-windows-rsa"
    user_data       = filebase64(var.user_data_file)
    security_group_names = ["allow_inbound_8080", "allow_inbound_ssh", "allow_outbound_everywhere"]
}

#Creates an Auto Scaling Group.
resource "aws_autoscaling_group" "our_app" {
    name                = "sample-auto-scaling-group"
    availability_zones  = var.az
    desired_capacity    = 2
    max_size            = 3
    min_size            = 1
    default_cooldown    = 300
    health_check_type   = "ELB"
    launch_template {
        id      = aws_launch_template.my_app.id
        version = "$Default"
    }
}

#Creates an ASG attachment.
resource "aws_autoscaling_attachment" "our_app" {
  autoscaling_group_name    = aws_autoscaling_group.our_app.name
  alb_target_group_arn      = aws_alb_target_group.my_alb.arn
}

#Here's the publicly accessible URL.
output "Your_website_is_here" {
    value = "http://${aws_lb.my_alb.dns_name}"
}

output "db_connection_string" {
    value = aws_db_instance.my_db.endpoint
}