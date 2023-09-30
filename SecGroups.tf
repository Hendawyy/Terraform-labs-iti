# Create Security Group for SSH from 0.0.0.0/0
resource "aws_security_group" "ssh_from_anywhere" {
  name        = "ssh_from_anywhere"
  description = "Allow SSH from anywhere"
  vpc_id      = module.mynetwork.vpc_id

  ingress {
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

# Create Security Group for SSH and Port 3000 from VPC CIDR
resource "aws_security_group" "ssh_and_port3000_from_vpc" {
  name        = "ssh_and_port3000_from_vpc"
  description = "Allow SSH and Port 3000 from VPC CIDR"
  vpc_id      = module.mynetwork.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.mynetwork.module_vpc_cider]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [module.mynetwork.module_vpc_cider]
  }
}
