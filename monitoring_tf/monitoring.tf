resource "aws_key_pair" "monitoring" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "monitoring" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name               = aws_key_pair.monitoring.key_name

  associate_public_ip_address = true
  monitoring                  = true

  tags = {
    Name = "monitoring-server"
  }
}
