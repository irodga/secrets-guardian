output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Lista de subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Lista de subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID de la route table pública"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID de la route table privada"
  value       = aws_route_table.private.id
}

output "private_nacl_id" {
  description = "ID del NACL asociado a subnets privadas"
  value       = aws_network_acl.main.id
}

output "public_nacl_id" {
  description = "ID del NACL asociado a subnets públicas"
  value       = aws_network_acl.public.id
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "fsx_sg_id" {
  description = "ID del Security Group dedicado para FSx"
  value       = aws_security_group.fsx_sg.id
}

output "fsx_security_group_id" {
  description = "ID del Security Group usado por FSx"
  value       = aws_security_group.fsx_sg.id
}