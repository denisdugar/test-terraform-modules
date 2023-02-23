output "vpc_id"{
    value = aws_vpc.test_vpc.id
}

output "public_subnet1_id"{
    value = aws_subnet.test_subnet_public_1.id
}

output "public_subnet2_id"{
    value = aws_subnet.test_subnet_public_2.id
}

output "private_subnet1_id"{
    value = aws_subnet.test_subnet_private_1.id
}

output "private_subnet2_id"{
    value = aws_subnet.test_subnet_private_2.id
}