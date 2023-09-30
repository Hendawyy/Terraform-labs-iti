# Create Application EC2 Instance in a Private Subnet
resource "aws_instance" "application" {
  count                        = length(var.availability_zones)
  ami                          = var.application_ami_id
  instance_type                = "t2.micro"
  subnet_id                    = module.mynetwork.private_subnets[count.index].id
  vpc_security_group_ids       = [aws_security_group.ssh_and_port3000_from_vpc.id]
  associate_public_ip_address  = false
  key_name                    = aws_key_pair.tf-key-pair.id

  tags = {
    Name = "PrvEC2"
  }
}