# Aws security group for SSH access
resource "aws_security_group" "mlops_zc_ta_ec2_sg" {
    name        = "mlops-zc-text-analyszer-ec2-sg"
    description = "Allow SSH access"

    ingress {
        description = "SSH from VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "mlops_zc_ta_ec2_instance" {
    ami             = var.ami
    instance_type   = var.instance_type
    key_name        = var.key_name
    tags = {
        Name = var.name
        Environment = var.env
    }
    security_groups = [aws_security_group.mlops_zc_ta_ec2_sg.name]
    lifecycle {
        prevent_destroy = true
    }
    iam_instance_profile = var.iam_instance_profile
}