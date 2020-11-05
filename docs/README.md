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

## Load Balancer

> Contains 3 parts: Listener, Listener Rule and Target Group

1. Create ALB(Application), NLB(Network) or CLB(Classic) 
`aws_lb`
    - here, we define the type of lb we'll use
2. Create a listener for the LB in step 1
`aws_lb_listener`
    - here, we define which port and protocol we'll use to listen
3. Security group of the LB in step 1.
`aws_security_group`
    - here, we define the ip and port for both inbound and outbound traffic
4. Target group
`aws_lb_target_group`
    - we define the `health_check` rule
5. Add target group to asg resource created in step 2 of asg above
6. Listener Rule
`aws_lb_listener_rule`
    - ties all the pieces together i.e connects listener to listener_target_group

## Terraform state

- Collaboration and isolation
- To solve collaboration problem we can use backend and locking (using S3 and Dynamodb)

### Saving Terraform state in backend server (for collaboration)

1. Create s3 bucket
`aws_s3_bucket`
    - has versioning, encryption
2. Create dynamodb table
`aws_dynamodb_table`
    - for locking
3. Create terraform backend
`terraform {    backend "s3" {  config  }   }`
    - so that terraform can automatically pull and push for `tfstate` after each `terraform plan` respectively

> We can use Terragrunt for backend configuration settings to keep it DRY (Don't Repeat Yourself)

### Isolation of tfstate

- so that our different environments such as staging(for preproduction testing), production remain isolated from each other (like docker containers)

1. via workspace 
2. via file layout (RECOMMENDED)

#### Isolation via File Layout

- Use of separate folders for each environment
  - It can further be separated by using components (for different services/resource) within each environment

Although modularity saves us from mishaps like accidently destroying the entire infrastructure, it has a pitfall that now as the code is not in a single file, we need to run terraform apply for each configuration/module separately.

> This is resolved by terragrunt by using `apply-all`

It also has the disadvantage that referencing of a resource within the same file was easy. For e.g `aws_db_instance.foo.address` but with modules it has to be done using `terraform_remote_state`.

