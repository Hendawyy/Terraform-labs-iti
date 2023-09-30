output "vpc_id" {
  value = aws_vpc.my_vpc.id
}
output "module_vpc_cider" {
  value = aws_vpc.my_vpc.cidr_block
}
output "private_subnets" {
  value = aws_subnet.private_subnet
}
output "public_subnets" {
  value = aws_subnet.public_subnet
}
