region                      = "eu-central-1"
vpc_cidr_block              = "10.1.0.0/16"
public_subnets_cidr_blocks  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets_cidr_blocks = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones          = ["eu-central-1a", "eu-central-1b"]
bastion_ami_id              = "ami-01342111f883d5e4e"
application_ami_id          = "ami-01342111f883d5e4e"
