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

# # launch configuration
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

# # asg
# resource "aws_autoscaling_group" "example" {
#     launch_configuration = aws_launch_configuration.example.name
#     vpc_zone_identifier = data.aws_subnet_ids.default.ids

#     min_size = 2
#     max_size = 10

#     tag {
#         key = "Name"
#         value = "terraform-asg-example"
#         propagate_at_launch = true
#     }

# }

# # data sources

# # vpc
# data "aws_vpc" "default" {
#     default = true  # only filter
# }

# # subnets
# data "aws_subnet_ids" "default" {
#     vpc_id = data.aws_vpc.default.id
# }