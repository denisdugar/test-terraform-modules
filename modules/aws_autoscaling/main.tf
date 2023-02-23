data "aws_ami" "latest_ubuntu_linux" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "wordpress_conf" {
  image_id        = data.aws_ami.latest_ubuntu_linux.id
  instance_type   = var.instance_type
  security_groups = var.sg_id
  key_name        = var.key
  user_data       = var.user_data
}

resource "aws_autoscaling_group" "wordpress_autoscaling" {
  name                 = var.autoscaling_name
  launch_configuration = aws_launch_configuration.wordpress_conf.name
  min_size             = var.min
  max_size             = var.max
  min_elb_capacity     = var.cap
  health_check_type    = var.health_check_type
  vpc_zone_identifier  = var.subnet_ids
}