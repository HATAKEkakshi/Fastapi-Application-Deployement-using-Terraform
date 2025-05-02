resource "aws_security_group" "fastapi-sg" {
  name        = "fastapi-sg"
  description = "Fastapi security group"
  tags = {
    Name = "fastapi-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fastapi_ipv4" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv4         = "122.161.49.206/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow SSH access from my IP"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow HTTP access from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}