region = "us-east-1"

vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

ami_id        = "ami-XYZ"
instance_type = "t3.micro"

monitoring_sg_id = "sg-XYZ"
subnet_id        = "subnet-a"

availability_zone = "us-east-1b"

key_pair_name   = "monitoring"
public_key_path = "../ssh_keys/monitoring.pub"

alb_name = "monitoring-production"

public_subnet_ids = [
  "subnet-aaaaaaa",
  "subnet-bbbbbbb"
]
