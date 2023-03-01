variable "instance_count"{
    default = 1
}

variable "instance_type"{
    default = "t2.micro"
}

variable "key"{
    type = string
}

variable "subnet_id"{
    type = string
}

variable "user_data"{
    type = string
}

variable "vpc_sg_ids"{
    type = list
}

variable "name"{
    default = "test"
}

variable "owner"{
    type = string
}

variable "email"{
    type = string
}

variable "env"{
    type = string
}