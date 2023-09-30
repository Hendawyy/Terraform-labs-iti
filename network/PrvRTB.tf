# Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = module.mynetwork.nat_gateway_id
  # }
  tags = {
    Name = "PrivateRouteTable"
  }
}
