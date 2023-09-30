# Create Bastion EC2 Instance in the Public Subnet
resource "aws_instance" "bastion" {
  count                       = length(var.availability_zones)
  ami                         = var.bastion_ami_id
  instance_type               = "t2.micro"
  subnet_id                   = module.mynetwork.public_subnets[count.index].id
  vpc_security_group_ids      = [aws_security_group.ssh_from_anywhere.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key-pair.id

  provisioner "local-exec" {
    command = "echo 'Bastion Public IP: ${self.public_ip}'"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo '${tls_private_key.rsa-key.private_key_pem}' > /home/ec2-user/private-key.pem
    chmod 400 /home/ec2-user/private-key.pem
    EOF

  tags = {
    Name = "Bastion"
  }
}
