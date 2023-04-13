resource "aws_lb" "monitoring-production" {
  name               = "monitoring-production"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.monitoring_sg.id]
  subnets            = ["subnet-a", "subnet-b"]

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "monitoring" {
  name     = "monitoring-production"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "your_vpc"

  health_check {
    path                = "/"
    port                = 3000
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "prometheus-production"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "your_vpc"

  health_check {
    path                = "/status"
    port                = 9090
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}


resource "aws_lb_target_group_attachment" "prometheus" {
  target_group_arn = aws_lb_target_group.prometheus.arn
  target_id        = data.aws_instance.prometheus.id
  port             = 9090
  depends_on = [aws_instance.monitoring-server-prometheus]
}

resource "aws_lb_target_group_attachment" "monitoring" {
  count = length(aws_instance.monitoring-server)
  target_group_arn = aws_lb_target_group.monitoring.arn
  target_id        = aws_instance.monitoring-server[count.index].id
  port             = 3000
}


resource "aws_lb_listener" "monitoring-listener" {
  load_balancer_arn = aws_lb.monitoring-production.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    target_group_arn = aws_lb_target_group.monitoring.arn
    redirect {
      port           = "443"
      protocol       = "HTTPS"
      status_code    = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.monitoring-production.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:XXXXXXXXXXXX"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoring.arn
  }
}

resource "aws_lb_listener" "prometheus-listener" {
  load_balancer_arn = aws_lb.monitoring-production.arn
  port              = "9090"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

