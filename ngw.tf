# # Create NAT Gateway
# resource "aws_nat_gateway" "my_nat" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.public_subnet[0].id
#   tags = {
#     Name : "NAT"
#   }
# }
