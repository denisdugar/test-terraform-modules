output "autoscaling_id"{
    value = aws_autoscaling_group.wordpress_autoscaling.id
}

output "name" {
    value = aws_autoscaling_group.wordpress_autoscaling.name
}