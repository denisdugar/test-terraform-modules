data "aws_ami" "latest_ubuntu_linux" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "app_server" {
  count                  = var.instance_count
  ami                    = data.aws_ami.latest_ubuntu_linux.id
  instance_type          = var.instance_type
  key_name               = var.key
  subnet_id              = var.subnet_id
  user_data              = var.user_data
  vpc_security_group_ids = var.vpc_sg_ids
  tags = {
    Name = var.name
    Owner = var.owner
    email = var.email
    env = var.env
  }
}