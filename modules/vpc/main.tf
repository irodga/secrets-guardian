resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "guardian-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "guardian-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "guardian-nat"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "guardian-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = "${var.region}a"

  tags = {
    Name = "guardian-private-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "guardian-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "guardian-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "guardian-nacl-private"
  }
}

# Reglas NACL privadas
resource "aws_network_acl_rule" "inbound_allow_internal" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "outbound_allow_internal" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "inbound_allow_internet" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 110
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "outbound_allow_internet" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 110
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# NFS y Portmapper
resource "aws_network_acl_rule" "inbound_nfs_tcp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 120
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 2049
  to_port        = 2049
}

resource "aws_network_acl_rule" "outbound_nfs_tcp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 120
  egress         = true
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 2049
  to_port        = 2049
}

resource "aws_network_acl_rule" "inbound_nfs_udp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 121
  egress         = false
  protocol       = "17"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 2049
  to_port        = 2049
}

resource "aws_network_acl_rule" "outbound_nfs_udp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 121
  egress         = true
  protocol       = "17"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 2049
  to_port        = 2049
}

resource "aws_network_acl_rule" "inbound_portmapper_tcp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 122
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 111
  to_port        = 111
}

resource "aws_network_acl_rule" "outbound_portmapper_tcp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 122
  egress         = true
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 111
  to_port        = 111
}

resource "aws_network_acl_rule" "inbound_portmapper_udp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 123
  egress         = false
  protocol       = "17"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 111
  to_port        = 111
}

resource "aws_network_acl_rule" "outbound_portmapper_udp" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 123
  egress         = true
  protocol       = "17"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 111
  to_port        = 111
}

resource "aws_network_acl_rule" "inbound_metadata" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 130
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "169.254.169.254/32"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "outbound_metadata" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 130
  egress         = true
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "169.254.169.254/32"
  from_port      = 80
  to_port        = 80
}

# NACL pública
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "guardian-nacl-public"
  }
}

resource "aws_network_acl_rule" "public_in" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_out" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# ✅ SG para interfaces de red de FSx
resource "aws_security_group" "fsx_sg" {
  name        = "fsx-endpoint-sg"
  description = "Security group para las interfaces de FSx"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    description     = "NFS desde red interna"
  }

  ingress {
    from_port       = 111
    to_port         = 111
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    description     = "Portmapper TCP"
  }

  ingress {
    from_port       = 111
    to_port         = 111
    protocol        = "udp"
    cidr_blocks     = ["10.0.0.0/16"]
    description     = "Portmapper UDP"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "guardian-fsx-sg"
  }
}
