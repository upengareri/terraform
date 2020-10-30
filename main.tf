provider "aws" {
    region = "us-east-2"
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
                nohup busybox httpd -f -p 8080 &
                EOF

    tags = {
        Name = "terraform-instance-1"
    }
}

# create security group
resource "aws_security_group" "instance-1-sg" {
    name = "terraform-example-1-sg"

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # allow any public ip address
    }
}