variable "region" {
  type        = string
  description = "Região AWS"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}
