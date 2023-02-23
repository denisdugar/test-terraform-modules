variable "name_subnet_group"{
    default = "test"
}

variable "subnet_ids"{
    default = []
}

variable "storage"{
    default = 10
}

variable "engine"{
    default = "mysql"
}

variable "engine_version"{
    default = "5.7"
}

variable "instance_class"{
    default = "db.t3.micro"
}

variable "db_name"{
    default = "wordpress"
}

variable "db_username"{
    default = "admin"
}

variable "db_password"{
    default = "admin"
}

variable "parameter_group_name"{
    default = "default.mysql5.7"
}

variable "skip_final_snapshot"{
    default = true
}

variable "backup_retention_period"{
    default = 3 
}

variable "vpc_security_group_ids"{
    default = []
}

variable "name"{
    default = "test"
}