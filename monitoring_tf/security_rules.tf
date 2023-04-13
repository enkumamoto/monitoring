resource "aws_security_group" "monitoring_sg" {
  name        = "allow_grafana"
  description = "Allow grafana"
  vpc_id      = "vpc-e3591d84"

  tags = {
    Name = "allow grafana"
  }
}

resource "aws_security_group_rule" "monitoring-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.30.0.0/16"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "monitoring-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.30.0.0/16"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "monitoring-prometheus" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["10.30.0.0/16"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}


resource "aws_security_group_rule" "monitoring-egress" {
  type              = "egress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["10.30.0.0/16"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "prometheus-egress" {
  type              = "egress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["10.30.0.0/16"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

