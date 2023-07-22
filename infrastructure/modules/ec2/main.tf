resource "aws_instance" "mlops_zc_ta_ec2_instance" {
    ami             = var.ami
    instance_type   = var.instance_type
    key_name        = var.key_name
    tags = {
        Name = var.name
    }
}