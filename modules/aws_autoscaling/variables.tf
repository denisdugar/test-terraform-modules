variable "autoscaling_name"{
    default = "wordpress"
}

variable "instance_type"{
    default = "t2.micro"
}
variable "sg_id"{
    default = []
}
variable "key"{
    default = ""
}
variable "user_data"{
    default = ""
}
variable "min"{
    default = 2
}
variable "max"{
    default = 3
}
variable "cap"{
    default = 2
}
variable "health_check_type"{
    default = "EC2"
}
variable "subnet_ids"{
    default = []
}