resource "aws_autoscaling_group" "hometap" {
 desired_capacity     = 2
 max_size             = 3
 min_size             = 1
 vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.samuel.id
    version = "$Latest"
  }
}


resource "aws_launch_template" "samuel" {
  name_prefix   = "sam"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]

}


resource "aws_autoscaling_policy" "scale_up" {
 name                   = "scale_up"
 autoscaling_group_name = aws_autoscaling_group.hometap.name
 adjustment_type        = "ChangeInCapacity"
 scaling_adjustment     = 1
 cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_down" {
 name                   = "scale_down"
 autoscaling_group_name = aws_autoscaling_group.hometap.name
 adjustment_type        = "ChangeInCapacity"
 scaling_adjustment     = -1
 cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
 alarm_name          = "high_cpu"
 comparison_operator = "GreaterThanOrEqualToThreshold"
 evaluation_periods = "2"
 metric_name         = "CPUUtilization"
 namespace           = "AWS/EC2"
 period              = "120"
 statistic           = "Average"
 threshold           = "70"
 alarm_description   = "This metric checks cpu utilization"
 alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hometap.name
 }

}
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
 alarm_name          = "low_cpu"
 comparison_operator = "LessThanOrEqualToThreshold"
 evaluation_periods = "2"
 metric_name         = "CPUUtilization"
 namespace           = "AWS/EC2"
 period              = "120"
 statistic           = "Average"
 threshold           = "30"
 alarm_description   = "This metric checks cpu utilization"
 alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hometap.name
 }
}



resource "aws_security_group" "sg" {
 name        = "allow_traffic"
 description = "Allow inbound traffic on port 80 and 443"

 ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

 
