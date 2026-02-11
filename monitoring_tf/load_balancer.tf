resource "aws_lb" "monitoring" {
  name               = var.alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.monitoring_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "monitoring" {
  name     = "${var.alb_name}-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.monitoring_vpc.id

  health_check {
    path                = "/"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "${var.alb_name}-prometheus"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = aws_vpc.monitoring_vpc.id

  health_check {
    path                = "/status"
    port                = "9090"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_target_group_attachment" "prometheus" {
  target_group_arn = aws_lb_target_group.prometheus.arn
  target_id        = aws_instance.monitoring.id
  port             = 9090
}

resource "aws_lb_target_group_attachment" "monitoring" {
  target_group_arn = aws_lb_target_group.monitoring.arn
  target_id        = aws_instance.monitoring.id
  port             = 3000
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoring.arn
  }
}

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}
