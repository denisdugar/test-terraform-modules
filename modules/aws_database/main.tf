resource "aws_db_subnet_group" "test_db_subnet_group" {
  name       = var.name_subnet_group
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage          = var.storage
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  name                       = var.db_name 
  username                   = var.db_username
  password                   = var.db_password
  parameter_group_name       = var.parameter_group_name
  skip_final_snapshot        = var.skip_final_snapshot
  backup_retention_period    = var.backup_retention_period
  vpc_security_group_ids     = var.vpc_security_group_ids
  db_subnet_group_name       = aws_db_subnet_group.test_db_subnet_group.name

  tags = {
    Name = var.name
  }
}