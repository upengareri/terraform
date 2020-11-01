provider "aws" {
    region = "us-east-2"  # Ohio
}

# provide_type name { attributes }
resource "aws_instance" "example_terra" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    # add security group (implicit dependency)
    vpc_security_group_ids = [aws_security_group.instance-1-sg.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, world" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    tags = {
        Name = "terraform-instance-1"
    }
}

# create security group
resource "aws_security_group" "instance-1-sg" {
    name = "terraform-example-1-sg"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # allow any public ip address
    }
}

# input variable
variable "server_port" {
    description = "To access the server, use this port"
    type = number
    default = 8080
}

# output variable
output "public_ip" {
    value = aws_instance.example_terra.public_ip
    description = "Public ip address of the server"
    
}

# -------------- AUTOSCALING GROUP -------------

# # 1. LAUNCH CONFIGURATION
# resource "aws_launch_configuration" "example" {
#     image_id = ""
#     instance_type = "t2.micro"

#     security_groups = [aws_security_group.instance-1-sg.id]

#     user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, world" > index.html
#                 nohup busybox httpd -f -p ${var.server_port} &
#                 EOF
#     lifecycle {
#         create_before_destroy = true
#     }
# }

# # 2. ASG
# resource "aws_autoscaling_group" "example" {
#     launch_configuration = aws_launch_configuration.example.name
#     vpc_zone_identifier = data.aws_subnet_ids.default.ids

# #     If ASG is part of ELB
#     target_group_arns = [aws_lb_target_group.asg.arn]
#     health_check_type = "ELB"

#     min_size = 2
#     max_size = 10

#     tag {
#         key = "Name"
#         value = "terraform-asg-example"
#         propagate_at_launch = true
#     }

# }

# # 3. DATA SOURCES

# # vpc
# data "aws_vpc" "default" {
#     default = true  # only filter
# }

# # subnets
# data "aws_subnet_ids" "default" {
#     vpc_id = data.aws_vpc.default.id
# }

# # -------------- LOAD BALANCER --------------

# # 1. Create LB
# resource "aws_lb" "example" {
#     name = "terraform-asg-example"
#     load_balancer_type = "application"
#     subnets = [data.aws_subnet_ids.default.ids]
#     security_groups = [aws_security_group.elb.id]
# }

# # 2. Create LB Listener
# resource "aws_lb_listener" "http" {
#     load_balancer_arn = aws_lb.example.arn
#     port = 80
#     protocol = "HTTP"
#     # By default, return a simple 404 page
#     default_action {
#         type = "fixed-response"
#         fixed_response {
#             content_type = "text/plain" 
#             message_body = "404: page not found"
#             status_code = 404
#         }
#     }
# }

# # 3. Create Security Group for LB
# resource "aws_security_group" "elb" {
#     name = "terraform-elb-sg"

#     ingress {
#         from_port = 80
#         to_port = 80
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }

# # 4. Create Target Group
# resource "aws_lb_target_group" "asg" {
#     name = "terraform-asg-tg"
#     port = var.server_port
#     protocol = "HTTP"
#     vpc_id = data.aws_vpc.default.id

#     health_check {
#         path = "/"
#         protocol = "HTTP"
#         matcher = "200"
#         interval = 15
#         timeout = 3
#         healthy_threshold = 2
#         unhealthy_threshold = 2
#     }
# }

# # 5. Create Listener Rule
# resource "aws_lb_listener_rule" "asg" {
#     listener_arn = aws_lb_listener.http.arn
#     priority = 100
#     condition {
#         field = "path-pattern"
#         values = ["*"]
#     }
#     action {
#         type = "forward"
#         target_group_arn = aws_lb_target_group.asg.arn
#     }
# }