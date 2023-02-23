output "db_endpoint"{
    value = aws_db_instance.wordpress_db.address
}

output "db_name"{
    value = var.db_name
}

output "db_password"{
    value = var.db_password
}