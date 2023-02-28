#!/bin/bash
terraform apply --auto-approve
export TT="$(aws --region us-east-1 ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=key-name,Values=bastion-key" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text)"
sed -i -r 's/-q ubuntu@.* -o I/-q ubuntu@'"$TT"' -o I/g' ansible/group_vars/all
cd ansible
ansible -m ping all
ansible-playbook playbook_send_conf.yml
