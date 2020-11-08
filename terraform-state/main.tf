provider "aws" {
    region = "us-east-2"
}

# create s3 bucket

# create dynamodb table

# create terraform backend for s3

# practice code snippets

# 1. COUNT and array lookup
variable "user_names" {
    description = "Create IAM users with these names"
    type = list(string)
    default = ["neo", "morpheus", "trinity"]
}

# usage of above variable to create 3 users
resource "aws_iam_user" "matrix" {
    count = length(var.user_names)
    name = var.user_names[count.index]
}

# to output one of the users arn, let's say neo 
output "neo_arn" {
    value = aws_iam_user.matrix[0].arn
    description = "The ARN of user neo"
}

# to output all of the users arn
output "all_users_arn" {
    value = aws_iam_user.matrix[*].arn
    description = "ARNs of all the users"
}
# OUTPUT CONSOLE
# neo_arn = arn:aws:iam::123456789012:user/neo
# all_users_arn = [
#      "arn:aws:iam::123456789012:user/neo",
#      "arn:aws:iam::123456789012:user/trinity",
#      "arn:aws:iam::123456789012:user/morpheus",
# ]

# 2. FOR-EACH (can iterate only set and map)
# for-each creates a map of resource
resource "aws_iam_user" "for_each_example" {
    # for_each = Collection (here Collection can be either set or map)
    for_each = toset(var.user_names)
    name = each.value
}

# to see the value of each users ARN
output "for_each_all_users_arn" {
    value = aws_iam_user.for_each_example
}

# OUTPUT CONSOLE
# returns a map of all the users (remember: count returns array)

# ----- SUMMARIZE COUNT AND FOR-EACH AGAIN ------
# count makes the resource as LIST
# meaning when we access the resource that has count in it then we treat it as list
# e.g see the above code that uses IAM resource with count
# similarly, for-each makes the resource as MAP
