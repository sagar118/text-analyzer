variable "ami" {
    description = "AMI to use for the instance"
}

variable "instance_type" {
    description = "Instance type"
}

variable "key_name" {
    description = "SSH key name"
}

variable "name" {
    description = "Name of the EC2 instance"
}

variable "env" {
    description = "Execution Environment"
}

variable "iam_instance_profile" {
    description = "IAM Instance Profile"
}