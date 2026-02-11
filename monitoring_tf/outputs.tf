output "monitoring_public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "vpc_id" {
  value = aws_vpc.monitoring_vpc.id
}
