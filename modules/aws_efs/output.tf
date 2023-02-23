output "efs_endpoint" {
    value = aws_efs_file_system.wordpress_efs.dns_name
}