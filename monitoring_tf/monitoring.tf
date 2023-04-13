resource "aws_key_pair" "monitoring" {
  key_name   = "monitoring"
  public_key = file("../ssh_keys/monitoring.pub")
}

resource "aws_instance" "monitoring-server" {
  count         = 2
  ami           = "ami-XYZ"
  instance_type = "t3.small"
  associate_public_ip_address = false
  key_name = "monitoring"
  monitoring = true
  vpc_security_group_ids = ["sg-XYZ"]
  subnet_id = "subnet-a"
  availability_zone = "us-east-1b"

  root_block_device {
     volume_size = 100
     volume_type = "gp3"
  }

  tags = {
    Name = "monitoring-server-${count.index}"
  }
}

resource "aws_instance" "monitoring-server-prometheus" {
  count         = 1
  ami           = "ami-XYZ"
  instance_type = "t3.medium"
  associate_public_ip_address = false
  key_name = "monitoring"
  monitoring = true
  vpc_security_group_ids = ["sg-XYZ"]
  subnet_id = "subnet-XYZ"
  availability_zone = "us-east-1b"

  root_block_device {
     volume_size = 100
     volume_type = "gp3"
  }

  tags = {
    Name = "monitoring-server-prometheus-${count.index}"
  }
}

data "aws_instance" "prometheus" {
  filter {
    name   = "tag:Name"
    values = ["monitoring-server-prometheus-0"]
    
  }
  depends_on = [aws_instance.monitoring-server-prometheus]

}


resource "aws_db_instance" "monitoring" {
  allocated_storage     = 100
  max_allocated_storage = 110
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.micro"
  name                 = "grafana"
  username             = "grafana"
  password             = "password"
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  vpc_security_group_ids = ["sg-XYZ"]
  db_subnet_group_name = "db-name-private"
  identifier = "grafana-production"
}


resource "aws_route53_record" "teste01" {
  zone_id = "XYZ" 
  name    = "monitoring.io" 
  type    = "A"

  alias {
    name                   = aws_lb.monitoring-production.dns_name
    zone_id                = aws_lb.monitoring-production.zone_id
  evaluate_target_health = true
  }
 }


output "loadbalancer-endpoint" {
  value = aws_lb.monitoring-production.dns_name
}

output "database-endpoint" {
  value = aws_db_instance.monitoring.endpoint
}

output "monitoring-instances-ips" {
  value = aws_instance.monitoring-server.*.private_ip
}

output "prometheus-instance-ip" {
  value = data.aws_instance.prometheus.private_ip
}

output "monitoring-instances-prometheus-ip" {
  value = aws_instance.monitoring-server-prometheus.*.private_ip
}