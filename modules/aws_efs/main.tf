resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = var.creation_token

  tags = {
    Name = var.name
  }
}