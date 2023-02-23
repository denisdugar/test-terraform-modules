output "instance_id"{
    value = join("", aws_instance.app_server[*].id)
}

output "public_ip"{
    value = join("", aws_instance.app_server[*].public_ip)
}

output "private_ip"{
    value = join("", aws_instance.app_server[*].private_ip)
}

output "tag_Name"{
    value = join("", aws_instance.app_server[*].tags.Name)
}