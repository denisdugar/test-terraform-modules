variable "instance_count"{
    default = 1
}

variable "instance_type"{
    default = ""
}

variable "key"{
    default = ""
}

variable "subnet_id"{
    default = ""
}

variable "user_data"{
    default = ""
}

variable "vpc_sg_ids"{
    default = []
}

variable "http_endpoint"{
    default = "enabled"
}

variable "instance_metadata_tags"{
    default = "enabled"
}

variable "name"{
    default = "test"
}

variable "command"{
    default = <<-EOT
    echo "ec2 is created"
    EOT
}