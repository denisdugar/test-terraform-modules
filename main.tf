terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  common_tags = {
    owner = "Denis Dugar"
    email = "denisdugar@gmail.com"
    env   = "prod"
  }
}

resource "null_resource" "ansible_config" {
  provisioner "local-exec" {
    command = <<-EOT
  echo "$(aws ec2 describe-instances --region us-east-1 --instance-ids $(aws autoscaling describe-auto-scaling-instances --region us-east-1 --output text \
--query "AutoScalingInstances[?AutoScalingGroupName=='${module.aws_wordpress.name}'].InstanceId") --query "Reservations[].Instances[].PrivateIpAddress" --output text)" > ./ansible/hosts.txt
  sed -i.bak 's/\t/\n/g' ./ansible/hosts.txt
  sed -i 's/-q ubuntu@.* -o I/-q ubuntu@${module.aws_ec2_bastion.public_ip} -o I/' ./ansible/group_vars/all
  echo "${module.aws_ec2_master[0].private_ip}
  ${module.aws_ec2_master[1].private_ip}
  ${module.aws_ec2_nodes[0].private_ip}
  ${module.aws_ec2_nodes[1].private_ip}
  ${module.aws_ec2_nodes[2].private_ip}
  ${module.aws_ec2_nodes[3].private_ip}
  ${module.aws_ec2_logstash[0].private_ip}
  ${module.aws_ec2_logstash[1].private_ip}
  ${module.aws_ec2_kibana.public_ip}" > ./ansible/hosts.txt
  echo "127.0.0.1 localhost
  ${module.aws_ec2_master[0].private_ip}  ${module.aws_ec2_master[0].tag_Name}
  ${module.aws_ec2_master[1].private_ip}  ${module.aws_ec2_master[1].tag_Name}
  ${module.aws_ec2_nodes[0].private_ip}  ${module.aws_ec2_nodes[0].tag_Name}
  ${module.aws_ec2_nodes[1].private_ip}  ${module.aws_ec2_nodes[1].tag_Name}
  ${module.aws_ec2_nodes[2].private_ip}  ${module.aws_ec2_nodes[2].tag_Name}
  ${module.aws_ec2_nodes[3].private_ip}  ${module.aws_ec2_nodes[3].tag_Name}
  ::1     ip6-localhost ip6-loopback 
  fe00::0 ip6-localnet 
  ff00::0 ip6-mcastprefix 
  ff02::1 ip6-allnodes 
  ff02::2 ip6-allrouters" > ./ansible/conf/hosts
  EOT
  }
}

############################################## EC2 INSTANCES ##############################################
module "aws_wordpress" {
  source        = "./modules/aws_autoscaling"
  sg_id         = [module.aws_sg_wordpress.sg_id]
  key           = "wordpress-key"
  instance_type = "t2.micro"
  user_data     = module.aws_user_data_wordpress.user_data
  subnet_ids    = [module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id]
}

module "aws_ec2_bastion" {
  source        = "./modules/aws_ec2"
  instance_type = "t2.micro"
  key           = "bastion-key"
  subnet_id     = module.aws_network.public_subnet1_id
  user_data     = module.aws_user_data_bastion.user_data
  vpc_sg_ids    = [module.aws_sg_bastion.sg_id]
  name          = "bastion"
  owner         = local.common_tags.owner
  email         = local.common_tags.email
  env           = local.common_tags.env
}

module "aws_ec2_kibana" {
  source                 = "./modules/aws_ec2"
  instance_type          = "t2.micro"
  key                    = "wordpress-key"
  subnet_id              = module.aws_network.public_subnet1_id
  user_data              = module.aws_user_data_kibana.user_data
  vpc_sg_ids             = [module.aws_sg_kibana.sg_id]
  name                   = "kibana"
  owner                  = local.common_tags.owner
  email                  = local.common_tags.email
  env                    = local.common_tags.env
}

module "aws_ec2_logstash" {
  source                 = "./modules/aws_ec2"
  count                  = 2
  instance_type          = "t2.micro"
  key                    = "wordpress-key"
  subnet_id              = element([module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id], count.index)
  user_data              = module.aws_user_data_logstash.user_data
  vpc_sg_ids             = [module.aws_sg_es.sg_id]
  name                   = "logstash"
  owner                  = local.common_tags.owner
  email                  = local.common_tags.email
  env                    = local.common_tags.env
}

module "aws_ec2_master" {
  source                 = "./modules/aws_ec2"
  count                  = 2
  instance_type          = "t2.medium"
  key                    = "wordpress-key"
  subnet_id              = element([module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id], count.index)
  user_data              = module.aws_user_data_master.user_data
  vpc_sg_ids             = [module.aws_sg_es.sg_id]
  name                   = "master${count.index}"
  owner                  = local.common_tags.owner
  email                  = local.common_tags.email
  env                    = local.common_tags.env
}

module "aws_ec2_nodes" {
  source        = "./modules/aws_ec2"
  count         = 4
  instance_type = "t2.medium"
  key           = "wordpress-key"
  subnet_id     = element([module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id, module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id], count.index)
  user_data     = module.aws_user_data_nodes.user_data
  vpc_sg_ids    = [module.aws_sg_es.sg_id]
  name          = "node${count.index}"
  owner         = local.common_tags.owner
  email         = local.common_tags.email
  env           = local.common_tags.env
}
############################################################################################


############################################## NETWORK ##############################################
module "aws_network" {
  source = "./modules/aws_network"
  owner         = local.common_tags.owner
  email         = local.common_tags.email
  env           = local.common_tags.env
}
############################################################################################

############################################## USER DATA ##############################################
module "aws_user_data_bastion" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_bastion.sh"
}

module "aws_user_data_wordpress" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_wordpress.sh"
  data_vars = {
    db_endpoint  = "${module.aws_database.db_endpoint}"
    efs_endpoint = "${module.aws_efs.efs_endpoint}"
    db_username  = "${module.db_secrets.secret.username}"
    db_password  = "${module.db_secrets.secret.password}"
    ip_logstash0 = "${module.aws_ec2_logstash[0].private_ip}"
    ip_logstash1 = "${module.aws_ec2_logstash[1].private_ip}"
  }
}

module "aws_user_data_kibana" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_kibana.sh"
}

module "aws_user_data_logstash" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_logstash.sh"
}

module "aws_user_data_master" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_master.sh"
}

module "aws_user_data_nodes" {
  source    = "./modules/aws_user_data"
  user_data = "user_data_nodes.sh"
}
############################################################################################


############################################## SECURITY GROUPS ##############################################
module "aws_sg_es" {
  source        = "./modules/aws_sg"
  name          = "es"
  description   = "sg for es ec2"
  vpc_id        = module.aws_network.vpc_id
  ingress_ports = ["80", "9200", "9300", "9600", "5044"]
  sg_ids        = [module.aws_sg_bastion.sg_id]
}

module "aws_sg_bastion" {
  source        = "./modules/aws_sg"
  vpc_id        = module.aws_network.vpc_id
  name          = "bastion"
  description   = "sg for bastion ec2"
  ingress_ports = ["22"]
}

module "aws_sg_kibana" {
  source        = "./modules/aws_sg"
  name          = "kibana"
  description   = "sg for kibana ec2"
  vpc_id        = module.aws_network.vpc_id
  ingress_ports = ["22", "80", "5601", "4180"]
  sg_ids        = [module.aws_sg_bastion.sg_id]
}

module "aws_sg_rds" {
  source        = "./modules/aws_sg"
  name          = "rds"
  description   = "sg for mysql rds"
  vpc_id        = module.aws_network.vpc_id
  ingress_ports = ["3306"]
  sg_ids        = [module.aws_sg_bastion.sg_id]
}

module "aws_sg_wordpress" {
  source        = "./modules/aws_sg"
  name          = "wordpress"
  description   = "sg for wordpress"
  vpc_id        = module.aws_network.vpc_id
  ingress_ports = ["80", "5044"]
  sg_ids        = [module.aws_sg_bastion.sg_id]
}

module "aws_sg_alb" {
  source        = "./modules/aws_sg"
  name          = "alb"
  description   = "sg for load balancer"
  vpc_id        = module.aws_network.vpc_id
  ingress_ports = ["80", "443"]
  sg_ids        = [module.aws_sg_bastion.sg_id]
}
############################################################################################


############################################## DATABASE ##############################################
module "aws_database" {
  source                 = "./modules/aws_database"
  name                   = "wordpress"
  db_username            = module.db_secrets.secret.username
  db_password            = module.db_secrets.secret.password
  subnet_ids             = [module.aws_network.private_subnet1_id, module.aws_network.private_subnet2_id]
  vpc_security_group_ids = [module.aws_sg_rds.sg_id]
}

module "db_secrets" {
  source    = "./modules/aws_secrets_data"
  secret_id = "db_creds"
}
############################################################################################

############################################## EFS ##############################################
module "aws_efs" {
  source = "./modules/aws_efs"
}
############################################################################################

############################################## LOAD BALANCER ##############################################
module "aws_alb" {
  source         = "./modules/aws_lb"
  sg_id          = [module.aws_sg_alb.sg_id]
  subnet_ids     = [module.aws_network.public_subnet1_id, module.aws_network.public_subnet2_id]
  vpc_id         = module.aws_network.vpc_id
  autoscaling_id = module.aws_wordpress.autoscaling_id
}
############################################################################################

############################################## OUTPUT ##############################################
output "kibana_ip" {
  value = module.aws_ec2_kibana.public_ip
}
############################################################################################