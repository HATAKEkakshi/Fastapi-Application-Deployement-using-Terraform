resource "aws_security_group" "Fastapi" {
  name        = "Fastapi"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "Fastapi"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "182.69.180.93/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow SSH Login for my IP"
}
resource "aws_vpc_security_group_ingress_rule" "Insight_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5540
  ip_protocol       = "tcp"
  to_port           = 5540
  description       = "Allow SSH Login for my IP"
}

resource "aws_vpc_security_group_ingress_rule" "Redis_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
  description       = "Allow redis access from the port"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}