variable "name"{
    default = "wordpress-alb"
}

variable "type" {
    default = "application"
}

variable "sg_id" {
    default = []  
}

variable "subnet_ids" {
    default = []
}

variable "vpc_id" {
    default = ""
}

variable "autoscaling_id" {
    default = ""
}
