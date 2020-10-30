# Notes on Terraform

- While launching the EC2 instance, we have the option to pass a shell script that will get executed during the EC2 instance boot. That option is in the form of `user_data` argument.

## Things to keep in mind or are required while creating ASG (AutoScaling Group)

1. aws_launch_configuration
    - Similar to instance creation code
    - lifecycle rule (any change in this config resource will be immutable replace and as asg resource refers to this, there will be problem in replacing. Hence, `create_before_destroy` attribute is required in launch configuration)

2. aws_autoscaling_group
    - References launch configuration
    - here we give min and max size

3. vpc_zone_identifier
    - it's better to keep your instances in different subnets as they reside in different AZs to be safe from any data outage in one subnet/AZ
    - to put your instances in different subnets we use `data` sources to get info
