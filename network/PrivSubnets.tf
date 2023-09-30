# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "PrivateSubnet-${count.index}"
  }
}
